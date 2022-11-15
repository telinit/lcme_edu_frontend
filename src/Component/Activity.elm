module Component.Activity exposing (..)

import Api exposing (task, withToken)
import Api.Data exposing (Activity, ActivityContentType(..), activityFinalTypeDecoder, stringFromActivityFinalType)
import Api.Request.Activity exposing (activityRead)
import Component.Select as SEL
import Css exposing (active)
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onCheck, onClick, onInput)
import Json.Decode as JD
import Markdown.Option
import Markdown.Render
import Page.CourseListPage exposing (empty_to_nothing)
import Ports exposing (initDropdown, scrollIdIntoView)
import Process
import Random
import Task
import Time exposing (utc)
import Util exposing (finalTypeToStr, httpErrorToString, isoDateToPosix, posixToDDMMYYYY, posixToFullDate, posixToISODate, task_to_cmd)
import Uuid exposing (Uuid, uuidGenerator)


type ControlsUpDown
    = ControlsUpDown Bool Bool


type Field
    = FieldTitle
    | FieldKeywords
    | FieldSci
    | FieldGroup
    | FieldHours
    | FieldLimit
    | FieldFGOS
    | FieldHidden
    | FieldDate
    | FieldLessonType


type Msg
    = MsgFetchCompleted Activity
    | MsgFetchFailed String
    | MsgFinTypeSelect SEL.Msg
    | MsgSetField Field String
    | MsgOnClickDelete
    | MsgMoveUp
    | MsgMoveDown
    | MsgInitUI
    | MsgNoop
    | MsgSetInternalID Uuid
    | MsgMarkdownMsg Markdown.Render.MarkdownMsg
    | MsgGotTZ Time.Zone


type State
    = StateLoading
    | StateActivity Activity
    | StateCreatingNew
    | StateError String


type alias Model =
    { state : State
    , token : String
    , tz : Maybe Time.Zone
    , editable : Bool
    , up_down : ControlsUpDown
    , internal_id : Maybe Uuid
    , component_fin_type : Maybe SEL.Model
    }


doFetch : String -> Uuid -> Cmd Msg
doFetch token id =
    task_to_cmd (httpErrorToString >> MsgFetchFailed) MsgFetchCompleted <|
        task <|
            withToken (Just token) <|
                activityRead <|
                    Uuid.toString id


doGenID =
    Random.generate MsgSetInternalID uuidGenerator


doGetTZ =
    Task.perform MsgGotTZ Time.here


init_creator : String -> ( Model, Cmd Msg )
init_creator token =
    ( { state = StateCreatingNew
      , token = token
      , editable = False
      , up_down = ControlsUpDown False False
      , internal_id = Nothing
      , component_fin_type = Nothing
      , tz = Nothing
      }
    , Cmd.batch [ doGenID, doGetTZ ]
    )


init_from_id : String -> Uuid -> ( Model, Cmd Msg )
init_from_id token id =
    ( { state = StateLoading
      , token = token
      , editable = False
      , up_down = ControlsUpDown False False
      , internal_id = Nothing
      , component_fin_type = Nothing
      , tz = Nothing
      }
    , Cmd.batch [ doFetch token id, doGenID, doGetTZ ]
    )


init_from_activity : String -> Activity -> ( Model, Cmd Msg )
init_from_activity token act =
    case act.contentType of
        Just ActivityContentTypeFIN ->
            let
                ( m, c ) =
                    SEL.init "Тип итогового контроля" True <|
                        Dict.fromList
                            [ ( "Q1", "1 четверть" )
                            , ( "Q2", "2 четверть" )
                            , ( "Q3", "3 четверть" )
                            , ( "Q4", "4 четверть" )
                            , ( "H1", "1 полугодие" )
                            , ( "H2", "2 полугодие" )
                            , ( "Y", "Годовая" )
                            , ( "E", "Экзамен" )
                            , ( "F", "Итоговая" )
                            ]
            in
            ( { state =
                    StateActivity act
              , token = token
              , editable = False
              , up_down = ControlsUpDown False False
              , internal_id = Nothing
              , tz = Nothing
              , component_fin_type =
                    Just <|
                        SEL.doSelect
                            (Maybe.withDefault "" <|
                                Maybe.map stringFromActivityFinalType act.finalType
                            )
                            m
              }
            , Cmd.batch [ Cmd.map MsgFinTypeSelect c, doGenID, doGetTZ ]
            )

        _ ->
            ( { state = StateActivity act
              , token = token
              , editable = False
              , up_down = ControlsUpDown False False
              , internal_id = Nothing
              , component_fin_type = Nothing
              , tz = Nothing
              }
            , Cmd.batch [ doGenID, doGetTZ ]
            )


setError : String -> Model -> Model
setError err model =
    { model | state = StateError err }


setEditable : Bool -> Model -> Model
setEditable editable model =
    { model | editable = editable }


getOrder : Model -> Int
getOrder model =
    case model.state of
        StateLoading ->
            -1

        StateActivity activity ->
            activity.order

        StateCreatingNew ->
            -1

        StateError _ ->
            -1


setOrder : Int -> Model -> Model
setOrder ord model =
    let
        new_state =
            case model.state of
                StateActivity activity ->
                    StateActivity { activity | order = ord }

                _ ->
                    model.state
    in
    { model | state = new_state }


getID : Model -> Maybe Uuid
getID model =
    case model.state of
        StateActivity activity ->
            activity.id

        _ ->
            Nothing


getActivity : Model -> Maybe Activity
getActivity model =
    case model.state of
        StateActivity activity ->
            Just activity

        _ ->
            Nothing


setUpDownControls : Bool -> Bool -> Model -> Model
setUpDownControls up down model =
    { model | up_down = ControlsUpDown up down }


doScrollInto : Model -> Cmd any
doScrollInto model =
    Maybe.withDefault Cmd.none <|
        Maybe.map (Uuid.toString >> scrollIdIntoView) model.internal_id


subscriptions : Model -> Sub Msg
subscriptions model =
    Maybe.withDefault Sub.none <|
        Maybe.map (\sel -> Sub.map MsgFinTypeSelect <| SEL.subscriptions sel) <|
            model.component_fin_type


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.state ) of
        ( MsgFetchCompleted act, _ ) ->
            init_from_activity model.token act

        ( MsgFetchFailed err, _ ) ->
            ( setError ("Загрузка активности не удалась: " ++ err) model, Cmd.none )

        ( MsgMoveUp, _ ) ->
            ( model, Cmd.none )

        ( MsgMoveDown, _ ) ->
            ( model, Cmd.none )

        ( MsgNoop, _ ) ->
            ( model, Cmd.none )

        ( MsgInitUI, _ ) ->
            --( model, initDropdown ".ui.dropdown" )
            ( model, Cmd.none )

        ( MsgFinTypeSelect msg_, StateActivity act ) ->
            Maybe.withDefault ( model, Cmd.none ) <|
                Maybe.map
                    (\model_ft ->
                        let
                            ( m, c ) =
                                SEL.update msg_ model_ft
                        in
                        case msg_ of
                            SEL.MsgItemSelected k ->
                                let
                                    res =
                                        JD.decodeString activityFinalTypeDecoder <| "\"" ++ k ++ "\""
                                in
                                case res of
                                    Ok t ->
                                        ( { model
                                            | state =
                                                StateActivity
                                                    { act
                                                        | finalType = Just t
                                                        , title = finalTypeToStr { finalType = Just t }
                                                    }
                                            , component_fin_type = Just m
                                          }
                                        , Cmd.map MsgFinTypeSelect c
                                        )

                                    _ ->
                                        ( { model
                                            | state = StateActivity act
                                            , component_fin_type = Just m
                                          }
                                        , Cmd.map MsgFinTypeSelect c
                                        )

                            _ ->
                                ( { model
                                    | state = StateActivity act
                                    , component_fin_type = Just m
                                  }
                                , Cmd.map MsgFinTypeSelect c
                                )
                    )
                    model.component_fin_type

        ( MsgSetField f v, state ) ->
            let
                new_act act =
                    case f of
                        FieldTitle ->
                            { act | title = v }

                        FieldKeywords ->
                            { act | keywords = empty_to_nothing <| Just <| String.trim v }

                        FieldSci ->
                            { act | scientificTopic = empty_to_nothing <| Just <| String.trim v }

                        FieldGroup ->
                            { act | group = empty_to_nothing <| Just <| String.trim v }

                        FieldHours ->
                            { act | hours = String.toInt v }

                        FieldLimit ->
                            { act | marksLimit = String.toInt v }

                        FieldFGOS ->
                            { act | fgosComplient = Just <| v == "1" }

                        FieldHidden ->
                            { act | isHidden = Just <| v == "1" }

                        FieldDate ->
                            case isoDateToPosix v of
                                Just d ->
                                    { act | date = d }

                                Nothing ->
                                    act

                        FieldLessonType ->
                            { act | lessonType = empty_to_nothing <| Just <| String.trim v }
            in
            case state of
                StateActivity act ->
                    ( { model | state = StateActivity (new_act act) }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        ( MsgSetInternalID id, _ ) ->
            ( { model | internal_id = Just id }, Cmd.none )

        ( MsgGotTZ tz, _ ) ->
            ( { model | tz = Just tz }, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )


viewRead : Model -> Html Msg
viewRead model =
    let
        view_with_label label bg fg body =
            div
                ([ class "row mb-10", style "max-width" "100vw" ]
                    ++ List.map (Uuid.toString >> id) (List.filterMap identity [ model.internal_id ])
                )
                [ div
                    [ class "text container segment ui"
                    , style "padding" "10px 15px"
                    , style "background-color" bg
                    , style "overflow" "hidden"
                    ]
                    [ div [ class "row middle-xs" ]
                        [ div [ class "col-xs" ]
                            ([ div [ class "ui top left attached label", style "background-color" fg ]
                                [ text label
                                ]
                             ]
                                ++ body
                            )
                        ]
                    ]
                ]
    in
    case model.state of
        StateLoading ->
            div
                ([ class "ui message" ]
                    ++ List.map (Uuid.toString >> id) (List.filterMap identity [ model.internal_id ])
                )
                [ div [ class "ui active inline loader small", style "margin-right" "1em" ] []
                , text "Загружаем активность"
                ]

        StateActivity activity ->
            case activity.contentType of
                Just ActivityContentTypeGEN ->
                    view_with_label "Тема"
                        "#EEF6FFFF"
                        "#B6C6D5FF"
                        [ h3 [ class "row start-xs pl-10 pt-10" ]
                            [ text activity.title ]
                        , div [ class "row between-xs middle-xs", style "font-size" "smaller" ]
                            [ div [ class "col-xs-12 col-sm start-xs center-sm" ]
                                [ strong [ class "mr-10 activity-property-label" ]
                                    [ i [ class "calendar alternate outline icon", style "color" "rgb(102, 119, 153)" ] []
                                    , text "Дата:"
                                    ]
                                , text <| posixToDDMMYYYY utc activity.date
                                ]
                            , div [ class "col-xs-12 col-sm start-xs start-sm" ]
                                [ strong [ class "mr-10 activity-property-label" ]
                                    [ i [ class "clock outline icon", style "color" "rgb(102, 119, 153)" ] []
                                    , text "Количество часов:"
                                    ]
                                , text <|
                                    Maybe.withDefault "Н/Д" <|
                                        Maybe.map
                                            String.fromInt
                                            activity.hours
                                ]
                            , div [ class "col-xs-12 col-sm start-xs start-sm" ] <|
                                Maybe.withDefault [] <|
                                    Maybe.map
                                        (\lt ->
                                            [ strong [ class "mr-10 activity-property-label" ]
                                                [ i [ class "object ungroup outline icon", style "color" "rgb(102, 119, 153)" ] []
                                                , text "Тип:"
                                                ]
                                            , text lt
                                            ]
                                        )
                                    <|
                                        empty_to_nothing <|
                                            activity.lessonType
                            ]
                        ]

                Just ActivityContentTypeFIN ->
                    view_with_label "Итоговый контроль"
                        "#FFEFE2FF"
                        "#D9C6C1FF"
                        [ h3 [ class "row start-xs pl-10 pt-10" ]
                            [ text <| finalTypeToStr activity
                            ]
                        , div [ class "row between-xs middle-xs", style "font-size" "smaller" ]
                            [ div [ class "col-xs-12 col-sm-4 start-xs center-sm" ]
                                [ strong [ class "mr-10 activity-property-label" ]
                                    [ i [ class "calendar alternate outline icon", style "color" "rgb(102, 119, 153)" ] []
                                    , text "Дата:"
                                    ]
                                , text <| posixToDDMMYYYY utc activity.date
                                ]
                            , div [ class "col-xs-12 col-sm-4 start-xs center-sm" ]
                                []
                            , div [ class "col-xs-12 col-sm-4 start-xs center-sm" ]
                                [ strong [ class "mr-10 activity-property-label" ]
                                    [ i [ class "chart bar outline icon", style "color" "rgb(102, 119, 153)" ] []
                                    , text
                                        "Лимит оценок: "
                                    ]
                                , text <|
                                    Maybe.withDefault "Н/Д" <|
                                        Maybe.map
                                            String.fromInt
                                            activity.marksLimit
                                ]
                            ]
                        ]

                Just ActivityContentTypeTXT ->
                    view_with_label "Материал"
                        "#EEF6FFFF"
                        "#B6C6D5FF"
                        [ h3 [ class "row start-xs pl-10 pt-10" ]
                            [ text activity.title ]
                        , div []
                            [ Maybe.withDefault (text "") <|
                                Maybe.map
                                    (\b ->
                                        Html.map MsgMarkdownMsg <|
                                            Markdown.Render.toHtml Markdown.Option.ExtendedMath b
                                    )
                                    activity.body
                            ]
                        , div [ class "row between-xs middle-xs", style "font-size" "smaller" ]
                            [ div [ class "col-xs-12 col-sm start-xs center-sm" ]
                                [ strong [ class "mr-10 activity-property-label" ]
                                    [ i [ class "calendar alternate outline icon", style "color" "rgb(102, 119, 153)" ] []
                                    , text "Дата:"
                                    ]
                                , text <| posixToDDMMYYYY utc activity.date
                                ]
                            , div [ class "col-xs-12 col-sm start-xs start-sm" ]
                                []
                            , div [ class "col-xs-12 col-sm start-xs start-sm" ] []
                            ]
                        ]

                Just ActivityContentTypeTSK ->
                    view_with_label "Задание"
                        "#EEF6FFFF"
                        "#B6C6D5FF"
                        [ h3 [ class "row start-xs pl-10 pt-10" ]
                            [ text activity.title ]
                        , div
                            []
                            [ Maybe.withDefault (text "") <|
                                Maybe.map
                                    (\b ->
                                        Html.map MsgMarkdownMsg <|
                                            Markdown.Render.toHtml Markdown.Option.ExtendedMath b
                                    )
                                    activity.body
                            ]
                        , div [] <|
                            Maybe.withDefault [] <|
                                Maybe.map
                                    (\d ->
                                        [ strong [] [ text "Срок сдачи: " ]
                                        , span []
                                            [ text <|
                                                posixToFullDate (Maybe.withDefault Time.utc model.tz) d
                                            ]
                                        ]
                                    )
                                    activity.dueDate
                        , div [ class "row between-xs middle-xs", style "font-size" "smaller" ]
                            [ div [ class "col-xs-12 col-sm start-xs center-sm" ]
                                [ strong [ class "mr-10 activity-property-label" ]
                                    [ i [ class "calendar alternate outline icon", style "color" "rgb(102, 119, 153)" ] []
                                    , text "Дата:"
                                    ]
                                , text <| posixToDDMMYYYY utc activity.date
                                ]
                            , div [ class "col-xs-12 col-sm start-xs start-sm" ]
                                [ strong [ class "mr-10 activity-property-label" ]
                                    [ i [ class "clock outline icon", style "color" "rgb(102, 119, 153)" ] []
                                    , text "Количество часов:"
                                    ]
                                , text <|
                                    Maybe.withDefault "Н/Д" <|
                                        Maybe.map
                                            String.fromInt
                                            activity.hours
                                ]
                            , div [ class "col-xs-12 col-sm start-xs start-sm" ] []
                            ]
                        ]

                Just ActivityContentTypeLNK ->
                    view_with_label "Ссылка"
                        "#EEF6FFFF"
                        "#B6C6D5FF"
                        [ h3 [ class "row start-xs pl-10 pt-10" ]
                            [ text activity.title ]
                        , div
                            []
                            [ h2 []
                                [ a
                                    [ href <| Maybe.withDefault "#" activity.link
                                    ]
                                    [ i [ class "linkify icon" ] []
                                    , text <| Maybe.withDefault "(пустая ссылка)" activity.link
                                    ]
                                ]
                            ]
                        , div [ class "row between-xs middle-xs", style "font-size" "smaller" ]
                            [ div [ class "col-xs-12 col-sm start-xs center-sm" ]
                                []
                            , div [ class "col-xs-12 col-sm start-xs start-sm" ]
                                []
                            , div [ class "col-xs-12 col-sm start-xs start-sm" ]
                                []
                            ]
                        ]

                Just ActivityContentTypeMED ->
                    text "TODO"

                Nothing ->
                    text ""

        StateError err ->
            div
                ([ class "ui text container negative message" ]
                    ++ List.map (Uuid.toString >> id) (List.filterMap identity [ model.internal_id ])
                )
                [ div [ class "header" ] [ text "Ошибка" ]
                , p [] [ text err ]
                ]

        StateCreatingNew ->
            text ""


viewWrite : Model -> Html Msg
viewWrite model =
    let
        view_with_label label bg fg body =
            case model.up_down of
                ControlsUpDown u d ->
                    div
                        ([ class "row mb-10", style "max-width" "100vw" ]
                            ++ List.map (Uuid.toString >> id) (List.filterMap identity [ model.internal_id ])
                        )
                        [ div
                            [ class "text container segment ui form"
                            , style "padding" "10px 15px"
                            , style "background-color" bg
                            ]
                            [ div [ class "row middle-xs" ]
                                [ div [ class "col-xs" ]
                                    ([ div
                                        [ class "ui top left attached label"
                                        , style "background-color" fg
                                        ]
                                        [ text label ]
                                     ]
                                        ++ body
                                    )
                                , div
                                    [ class "col ml-10"
                                    ]
                                  <|
                                    List.filterMap identity
                                        [ if u then
                                            Just <|
                                                div [ class "row mb-10" ]
                                                    [ button
                                                        [ class "ui button"
                                                        , style "background-color" fg
                                                        , onClick MsgMoveUp
                                                        ]
                                                        [ i [ class "angle up icon", style "margin" "0" ] []
                                                        ]
                                                    ]

                                          else
                                            Nothing
                                        , if d then
                                            Just <|
                                                div [ class "row" ]
                                                    [ button
                                                        [ class "ui button"
                                                        , style "background-color" fg
                                                        , onClick MsgMoveDown
                                                        ]
                                                        [ i [ class "angle down icon", style "margin" "0" ] []
                                                        ]
                                                    ]

                                          else
                                            Nothing
                                        ]
                                ]
                            ]
                        ]
    in
    case model.state of
        StateLoading ->
            div ([ class "ui message" ] ++ List.map (Uuid.toString >> id) (List.filterMap identity [ model.internal_id ]))
                [ div [ class "ui active inline loader small", style "margin-right" "1em" ] []
                , text "Загружаем активность"
                ]

        StateActivity activity ->
            case activity.contentType of
                Just ActivityContentTypeGEN ->
                    view_with_label "Тема"
                        "#EEF6FFFF"
                        "#B6C6D5FF"
                        [ div [ class "row mt-10" ]
                            [ div [ class "field start-xs col-xs-12" ]
                                [ label [] [ text "Название" ]
                                , input
                                    [ placeholder "Основное название темы"
                                    , type_ "text"
                                    , value activity.title
                                    , onInput (MsgSetField FieldTitle)
                                    ]
                                    []
                                ]
                            ]
                        , div [ class "row mt-10" ]
                            [ div [ class "field start-xs col-xs-12" ]
                                [ label [] [ text "Метки" ]
                                , input
                                    [ placeholder "Отображаются наверху таблицы"
                                    , type_ "text"
                                    , value <| Maybe.withDefault "" activity.keywords
                                    , onInput (MsgSetField FieldKeywords)
                                    ]
                                    []
                                ]
                            ]
                        , div [ class "row mt-10" ]
                            [ div [ class "field start-xs col-xs-12" ]
                                [ label [] [ text "Тип занятия" ]
                                , input
                                    [ placeholder "Лекция, Лабораторная работа, Контрольная работа, ..."
                                    , type_ "text"
                                    , value <| Maybe.withDefault "" activity.lessonType
                                    , onInput (MsgSetField FieldLessonType)
                                    ]
                                    []
                                ]
                            ]
                        , div [ class "row mt-10" ]
                            [ div [ class "field start-xs col-xs-12 col-sm-6" ]
                                [ label [] [ text "Научный раздел" ]
                                , input
                                    [ placeholder ""
                                    , type_ "text"
                                    , value <| Maybe.withDefault "" activity.scientificTopic
                                    , onInput (MsgSetField FieldSci)
                                    ]
                                    []
                                ]
                            , div [ class "field start-xs col-xs-12 col-sm-6" ]
                                [ label [] [ text "Группа" ]
                                , input
                                    [ placeholder "Для объединения в разделы"
                                    , type_ "text"
                                    , value <| Maybe.withDefault "" activity.group
                                    , onInput (MsgSetField FieldGroup)
                                    ]
                                    []
                                ]
                            ]
                        , div [ class "row mt-10" ]
                            [ div [ class "field start-xs col-xs-12 col-sm-6" ]
                                [ label [] [ text "Количество часов" ]
                                , input
                                    [ placeholder ""
                                    , type_ "number"
                                    , Html.Attributes.min "0"
                                    , value <| String.fromInt <| Maybe.withDefault 1 activity.hours
                                    , onInput (MsgSetField FieldHours)
                                    ]
                                    []
                                ]
                            , div [ class "field start-xs col-xs-12 col-sm-6" ]
                                [ label [] [ text "Лимит оценок" ]
                                , input
                                    [ placeholder ""
                                    , type_ "number"
                                    , Html.Attributes.min "0"
                                    , value <| String.fromInt <| Maybe.withDefault 1 activity.marksLimit
                                    , onInput (MsgSetField FieldLimit)
                                    ]
                                    []
                                ]
                            ]
                        , div [ class "row mt-10" ]
                            [ div [ class "field start-xs col-xs-12 col-sm-6" ]
                                [ label [] [ text "Соответствие ФГОС" ]
                                , div [ class "ui checkbox ml-20", style "scale" "1.25" ]
                                    [ input
                                        [ attribute "tabindex" "0"
                                        , type_ "checkbox"
                                        , checked <| Maybe.withDefault False activity.fgosComplient
                                        , onCheck
                                            (\c ->
                                                MsgSetField FieldFGOS <|
                                                    if c then
                                                        "1"

                                                    else
                                                        "0"
                                            )
                                        ]
                                        []
                                    , label []
                                        [ text "Соответствует" ]
                                    ]
                                ]
                            , div [ class "field start-xs col-xs-12 col-sm-6" ]
                                [ label [] [ text "Видимость для учащихся" ]
                                , div [ class "ui checkbox ml-15", style "scale" "1.25" ]
                                    [ input
                                        [ attribute "tabindex" "0"
                                        , type_ "checkbox"
                                        , checked <| Maybe.withDefault False activity.isHidden
                                        , onCheck
                                            (\c ->
                                                MsgSetField FieldHidden <|
                                                    if c then
                                                        "1"

                                                    else
                                                        "0"
                                            )
                                        ]
                                        []
                                    , label []
                                        [ text "Скрыта" ]
                                    ]
                                ]
                            ]
                        , div [ class "row mt-10" ]
                            [ div [ class "field start-xs col-xs-12 col-sm-6" ]
                                [ label [] [ text "Дата проведения" ]
                                , div [ class "ui input" ]
                                    [ input
                                        [ placeholder ""
                                        , type_ "date"
                                        , value <| Maybe.withDefault "" <| posixToISODate activity.date
                                        , onInput (MsgSetField FieldDate)
                                        ]
                                        []
                                    ]
                                ]
                            , div [ class "field start-xs col-xs-12 col-sm-3" ]
                                [ label [] [ text "Номер в списке" ]
                                , h1 [ style "margin" "10px 0 0 10px" ] [ text <| String.fromInt activity.order ]
                                ]
                            , div [ class "field start-xs col-xs-12 col-sm-3" ]
                                [ div [ class "row middle-xs end-md center-xs", style "height" "100%" ]
                                    [ button
                                        [ class "ui button red"
                                        , style "position" "relative"

                                        --, style "left" "50px"
                                        , style "top" "5px"
                                        , onClick MsgOnClickDelete
                                        ]
                                        [ i [ class "icon trash" ] []
                                        , text "Удалить"
                                        ]
                                    ]
                                ]
                            ]
                        ]

                Just ActivityContentTypeFIN ->
                    case model.component_fin_type of
                        Just s ->
                            view_with_label "Итоговый контроль"
                                "#FFEFE2FF"
                                "#D9C6C1FF"
                                [ div [ class "row mt-10" ]
                                    [ div [ class "field start-xs col-xs-12" ]
                                        [ label [] [ text "Тип контроля" ]
                                        , Html.map MsgFinTypeSelect <| SEL.view s
                                        ]
                                    ]
                                , div [ class "row mt-10" ]
                                    [ div [ class "field start-xs col-xs-12 col-sm-6" ]
                                        [ label [] [ text "Лимит оценок" ]
                                        , input
                                            [ placeholder ""
                                            , type_ "number"
                                            , Html.Attributes.min "0"
                                            , value <| String.fromInt <| Maybe.withDefault 1 activity.marksLimit
                                            , onInput (MsgSetField FieldLimit)
                                            ]
                                            []
                                        ]
                                    , div [ class "field start-xs col-xs-12 col-sm-6" ]
                                        [ label [] [ text "Видимость для учащихся" ]
                                        , div [ class "row middle-xs ml-10", style "height" "43px" ]
                                            [ div [ class "ui checkbox", style "scale" "1.25" ]
                                                [ input
                                                    [ attribute "tabindex" "0"
                                                    , type_ "checkbox"
                                                    , checked <| Maybe.withDefault False activity.isHidden
                                                    , onInput (MsgSetField FieldHidden)
                                                    ]
                                                    []
                                                , label []
                                                    [ text "Скрыт" ]
                                                ]
                                            ]
                                        ]
                                    ]
                                , div [ class "row mt-10" ]
                                    [ div [ class "field start-xs col-xs-12 col-sm-6" ]
                                        [ label [] [ text "Дата выставления" ]
                                        , div [ class "ui input" ]
                                            [ input
                                                [ placeholder ""
                                                , type_ "date"
                                                , value <| Maybe.withDefault "" <| posixToISODate activity.date
                                                , onInput (MsgSetField FieldDate)
                                                ]
                                                []
                                            ]
                                        ]
                                    , div [ class "field start-xs col-xs-12 col-sm-3" ]
                                        [ label [] [ text "Номер в списке" ]
                                        , h1 [ style "margin" "10px 0 0 10px" ] [ text <| String.fromInt activity.order ]
                                        ]
                                    , div [ class "field start-xs col-xs-12 col-sm-3" ]
                                        [ div [ class "row middle-xs end-md center-xs", style "height" "100%" ]
                                            [ button
                                                [ class "ui button red"
                                                , style "position" "relative"

                                                --, style "left" "50px"
                                                , style "top" "5px"
                                                , onClick MsgOnClickDelete
                                                ]
                                                [ i [ class "icon trash" ] []
                                                , text "Удалить"
                                                ]
                                            ]
                                        ]
                                    ]
                                ]

                        Nothing ->
                            text ""

                Just ActivityContentTypeTXT ->
                    text "TODO"

                Just ActivityContentTypeTSK ->
                    text "TODO"

                Just ActivityContentTypeLNK ->
                    text "TODO"

                Just ActivityContentTypeMED ->
                    text "TODO"

                Nothing ->
                    text ""

        StateError err ->
            div ([ class "ui text container negative message" ] ++ List.map (Uuid.toString >> id) (List.filterMap identity [ model.internal_id ]))
                [ div [ class "header" ] [ text "Ошибка" ]
                , p [] [ text err ]
                ]

        StateCreatingNew ->
            text ""


view : Model -> Html Msg
view model =
    if model.editable then
        viewWrite model

    else
        viewRead model

module Page.CourseListPage exposing (..)

import Api exposing (ext_task)
import Api.Data exposing (Course, EducationSpecialization, File)
import Api.Request.Course exposing (courseList)
import Api.Request.Education exposing (educationSpecializationList)
import Component.MultiTask as MT
import Component.UI.Select as Select
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Http
import Time exposing (utc)
import Util exposing (dictGroupBy, get_id_str, httpErrorToString, monthToInt)
import Uuid exposing (Uuid)


type FilterField
    = FilterFieldText
    | FilterFieldClass
    | FilterFieldGroup


type Msg
    = MsgCourseListFetchFailed String
    | MsgFetch (MT.Msg Http.Error FetchedData)
    | MsgFilterSpec Select.Msg
    | MsgFilterGroupBy Select.Msg
    | MsgOnInputFilter FilterField String


type FetchedData
    = FetchedCourses (List Course)
    | FetchedSpecs (List EducationSpecialization)


type alias Filter =
    { text : String
    , class : String
    , group : String
    , spec : Select.Model
    , groupBy : Select.Model
    , archived : Bool
    }


type State
    = StateLoading (MT.Model Http.Error FetchedData)
    | StateCompleted (List Course) (Dict String EducationSpecialization)
    | StateError String


type GroupBy
    = GroupByNone
    | GroupByClass
    | GroupByYear


type alias Model =
    { state : State
    , token : String
    , filter : Filter
    }


getCourseAcademicYear : Course -> Maybe ( Int, Int )
getCourseAcademicYear course =
    case course.createdAt of
        Nothing ->
            Nothing

        Just createdAt ->
            let
                m : Time.Month
                m =
                    Time.toMonth utc createdAt

                y : Int
                y =
                    Time.toYear utc createdAt

                y_ : Int
                y_ =
                    if monthToInt m < 6 then
                        y - 1

                    else
                        y
            in
            Just ( y_, y_ + 1 )


empty_to_nothing : Maybe String -> Maybe String
empty_to_nothing x =
    case x of
        Just "" ->
            Nothing

        _ ->
            x


getGroupBy : Model -> GroupBy
getGroupBy model =
    case model.filter.groupBy.selected of
        Just s ->
            case s of
                "class" ->
                    GroupByClass

                "year" ->
                    GroupByYear

                _ ->
                    GroupByNone

        Nothing ->
            GroupByNone


filterCourses : Filter -> List Course -> List Course
filterCourses filter courses =
    let
        filterCourse c =
            let
                text =
                    c.title ++ " " ++ Maybe.withDefault "" c.description

                filter_text =
                    String.contains (String.toLower filter.text) (String.toLower text)

                filter_spec =
                    Maybe.withDefault True <|
                        Maybe.map
                            (\fs ->
                                Maybe.withDefault False <|
                                    Maybe.map (\cs -> fs == Uuid.toString cs) c.forSpecialization
                            )
                        <|
                            empty_to_nothing filter.spec.selected

                filter_group =
                    String.contains (String.toLower filter.group) (String.toLower <| Maybe.withDefault "" c.forGroup)

                filter_class =
                    String.contains (String.toLower filter.class) (String.toLower <| Maybe.withDefault "" c.forClass)
            in
            filter_text && filter_spec && filter_group && filter_class
    in
    List.filter filterCourse courses


groupBy : GroupBy -> List Course -> Dict String EducationSpecialization -> Dict String (List Course)
groupBy group_by courses specs =
    case group_by of
        GroupByNone ->
            Dict.fromList [ ( "", courses ) ]

        GroupByClass ->
            let
                key course =
                    case ( empty_to_nothing course.forClass, course.forSpecialization ) of
                        ( Nothing, _ ) ->
                            "Остальное"

                        ( Just class, Nothing ) ->
                            class

                        ( Just class, Just spec_id ) ->
                            class
                                ++ " ("
                                ++ (Maybe.withDefault "Неизвестное" <|
                                        Maybe.map .name <|
                                            Dict.get (Uuid.toString spec_id) specs
                                   )
                                ++ " направление)"
            in
            dictGroupBy key courses

        GroupByYear ->
            let
                key course =
                    case getCourseAcademicYear course of
                        Nothing ->
                            "Год неизвестен"

                        Just ( a, b ) ->
                            String.fromInt a ++ " - " ++ String.fromInt b ++ " год"
            in
            dictGroupBy key courses


init : String -> Bool -> ( Model, Cmd Msg )
init token archived =
    let
        ( m, c ) =
            MT.init
                [ ( ext_task FetchedCourses
                        token
                        [ ( "archived__isnull"
                          , if archived then
                                "False"

                            else
                                "True"
                          )
                        ]
                        courseList
                  , "Получаем список курсов"
                  )
                , ( ext_task FetchedSpecs token [] educationSpecializationList, "Получаем список специализаций" )
                ]

        ( sm, sc ) =
            Select.init "Направление" True <| Dict.fromList []

        ( gm, gc ) =
            Select.init "Группировать" True <|
                Dict.fromList
                    [ ( "", "Без группировки" )
                    , ( "class", "По классам" )
                    ]
    in
    ( { state = StateLoading m
      , token = token
      , filter =
            { text = ""
            , class = ""
            , group = ""
            , spec = sm
            , groupBy = Select.doSelect "" gm
            , archived = archived
            }
      }
    , Cmd.batch
        [ Cmd.map MsgFetch c
        , Cmd.map MsgFilterSpec sc
        , Cmd.map MsgFilterGroupBy gc
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.state ) of
        ( MsgCourseListFetchFailed err, _ ) ->
            ( { model | state = StateError err }, Cmd.none )

        ( MsgFetch msg_, StateLoading model_ ) ->
            let
                ( m, c ) =
                    MT.update msg_ model_
            in
            case msg_ of
                MT.TaskFinishedAll [ Ok (FetchedCourses courses), Ok (FetchedSpecs specs) ] ->
                    let
                        new_filter old =
                            { old
                                | spec =
                                    Select.updateMany ([ ( "", "Все" ) ] ++ List.map (\s -> ( get_id_str s, s.name )) specs) old.spec
                            }
                    in
                    ( { model
                        | state =
                            StateCompleted courses <|
                                Dict.fromList <|
                                    List.filterMap (\s -> Maybe.map (\id_ -> ( Uuid.toString id_, s )) s.id) specs
                        , filter = new_filter model.filter
                      }
                    , Cmd.map MsgFetch c
                    )

                _ ->
                    ( { model | state = StateLoading m }, Cmd.map MsgFetch c )

        ( MsgFilterSpec msg_, StateCompleted courses specs ) ->
            let
                ( m, c ) =
                    Select.update msg_ model.filter.spec

                set_filter ({ filter } as model_) x =
                    { model_ | filter = { filter | spec = x } }
            in
            ( set_filter model m, Cmd.map MsgFilterSpec c )

        ( MsgFilterGroupBy msg_, StateCompleted courses specs ) ->
            let
                ( m, c ) =
                    Select.update msg_ model.filter.groupBy

                set_gb ({ filter } as model_) x =
                    { model_ | filter = { filter | groupBy = x } }
            in
            ( set_gb model m, Cmd.map MsgFilterSpec c )

        ( MsgOnInputFilter f v, _ ) ->
            let
                old_filter =
                    model.filter

                new_filter =
                    case f of
                        FilterFieldText ->
                            { old_filter | text = v }

                        FilterFieldClass ->
                            { old_filter | class = v }

                        FilterFieldGroup ->
                            { old_filter | group = v }
            in
            ( { model | filter = new_filter }, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )


courseImg : Maybe Uuid -> Html Msg
courseImg mb =
    case mb of
        Just file ->
            --TODO: Change with an actual URL
            img [ src ("/file/" ++ Uuid.toString file ++ "/download") ] []

        Nothing ->
            img [ src "/img/course.jpg" ] []


viewFilter : Filter -> Html Msg
viewFilter filter =
    div [ class "ui segment middle-xs", style "background-color" "#EEE" ]
        [ div [ class "row middle-xs" ]
            [ div [ class "ui fluid input col-xs-12" ]
                [ input
                    [ type_ "text"
                    , value filter.text
                    , placeholder "Название, описание"
                    , onInput (MsgOnInputFilter FilterFieldText)
                    ]
                    []
                ]
            ]
        , div [ class "row middle-xs" ]
            [ div [ class "ui fluid input col-xs-12 col-md-4 mt-10" ]
                [ input
                    [ type_ "text"
                    , value filter.class
                    , placeholder "Класс"
                    , onInput (MsgOnInputFilter FilterFieldClass)
                    ]
                    []
                ]
            , div [ class "ui fluid input col-xs-12 col-md-4 mt-10" ]
                [ input
                    [ type_ "text"
                    , value filter.group
                    , placeholder "Уч. группа"
                    , onInput (MsgOnInputFilter FilterFieldGroup)
                    ]
                    []
                ]
            , div [ class "ui fluid input col-xs-12 col-md-4 mt-10" ]
                [ Html.map MsgFilterSpec <| Select.view filter.spec
                ]
            ]
        , div [ class "row middle-xs" ] []
        ]


viewCourse : Dict String EducationSpecialization -> Course -> Html Msg
viewCourse specs course =
    let
        mbSpec =
            Dict.get (Maybe.withDefault "" <| Maybe.map Uuid.toString course.forSpecialization) specs
    in
    a [ class "card", href (Maybe.withDefault "" <| Maybe.map (\id -> "/course/" ++ Uuid.toString id) course.id) ]
        [ div [ class "image" ] [ courseImg course.logo ]
        , div [ class "content" ]
            [ div [ class "header" ]
                [ text course.title
                ]
            , div [ class "meta" ]
                [ text <|
                    Maybe.withDefault "" <|
                        Maybe.map (\spec -> spec.name ++ " направление") mbSpec
                ]
            , div
                [ class "description"
                , style "max-height" "150px"
                , style "overflow" "hidden"
                ]
                [ text <| String.trim <| Maybe.withDefault "" course.description
                ]
            ]
        , div [ class "extra content row around-xs" ] <|
            List.filterMap identity
                [ Maybe.map
                    (\c ->
                        div [ class "col-xs" ]
                            [ i [ class "users icon" ] []
                            , text (c ++ " класс")
                            ]
                    )
                    course.forClass
                , Maybe.map
                    (\g ->
                        div [ class "col-xs" ]
                            [ i [ class "list ol icon" ] []
                            , text <| "Группа: " ++ g
                            ]
                    )
                  <|
                    empty_to_nothing course.forGroup
                ]
        ]


view : Model -> Html Msg
view model =
    let
        view_courses dSpecs cs =
            let
                filtered =
                    List.map (viewCourse dSpecs) <|
                        List.sortBy
                            (\c ->
                                let
                                    mbClassNumStr : Maybe String
                                    mbClassNumStr =
                                        Maybe.map (String.filter Char.isDigit) c.forClass

                                    toIntOrZero : Maybe String -> Int
                                    toIntOrZero =
                                        Maybe.withDefault 0
                                            << Maybe.andThen String.toInt
                                in
                                ( c.title
                                , toIntOrZero mbClassNumStr
                                )
                            )
                        <|
                            filterCourses model.filter cs
            in
            [ div
                [ class "ui link cards center-xs"
                , style "display" "inline-flex"
                , style "margin" "0 -50px"
                ]
                (case filtered of
                    [] ->
                        [ h2 [] [ text "Нет курсов по вашему фильтру." ] ]

                    _ ->
                        filtered
                )
            ]

        body =
            case model.state of
                StateCompleted [] _ ->
                    [ div [ class "row center-xs" ]
                        [ h2 [] [ text "У вас нет курсов" ] ]
                    ]

                StateCompleted courses specs ->
                    let
                        gb =
                            if model.filter.archived then
                                GroupByYear

                            else
                                GroupByNone

                        -- getGroupBy model
                    in
                    case gb of
                        GroupByNone ->
                            view_courses specs courses

                        _ ->
                            let
                                grouped =
                                    groupBy gb courses specs
                            in
                            List.concat <|
                                List.map (\( g, cs ) -> [ h2 [] [ text g ] ] ++ view_courses specs cs) <|
                                    Dict.toList grouped

                StateError err ->
                    [ div [ class "ui negative message" ]
                        [ div [ class "header" ] [ text "Ошибка при попытке получения списка предметов" ]
                        , p [] [ text err ]
                        ]
                    ]

                StateLoading m ->
                    [ Html.map MsgFetch <| MT.view (always "OK") httpErrorToString m ]
    in
    div [ class "center-xs" ] <|
        [ div [ class "row between-xs middle-xs" ]
            [ h1 [ class "m-0" ]
                [ text <|
                    if model.filter.archived then
                        "Архив курсов"

                    else
                        "Доступные предметы"
                ]
            , a
                [ href <|
                    if model.filter.archived then
                        "/courses"

                    else
                        "/courses/archive"
                ]
                [ button [ class "ui button" ]
                    [ text <|
                        if model.filter.archived then
                            "Актуальные"

                        else
                            "Архив"
                    ]
                ]
            ]
        , viewFilter model.filter
        ]
            ++ body

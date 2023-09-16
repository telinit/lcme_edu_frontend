module Page.Course.CourseHeader exposing (..)

import Api exposing (ext_task)
import Api.Data exposing (Course, CourseEnrollmentRead, CourseEnrollmentReadRole(..), CourseMarking, CourseType, EducationSpecialization, UserShallow, stringFromCourseEnrollmentReadRole)
import Api.Request.Course exposing (courseEnrollmentList, courseUpdate)
import Api.Request.Education exposing (educationSpecializationList)
import Component.MultiTask as MT
import Component.UI.InputBox as InputBox
import Component.UI.Select as Select
import Component.UI.TextArea as TextArea
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Page.CourseListPage exposing (empty_to_nothing)
import Time exposing (Posix)
import Util exposing (Either(..), get_id_str, httpErrorToString, sendMessage, task_to_cmd, user_full_name)
import Uuid exposing (Uuid)


type alias APIToken =
    String


type alias CachedData =
    { course : Maybe Course
    , teachers : Maybe (List CourseEnrollmentRead)
    , specs : Maybe (List EducationSpecialization)
    }


type FetchResult
    = FetchedSpecs (List EducationSpecialization)
    | FetchedTeachers (List CourseEnrollmentRead)


type alias SubModels =
    { spec : Select.Model
    }


type State
    = StateInit (MT.Model Http.Error FetchResult)
    | StateView
    | StateEdit Course Bool SubModels
    | StateSaving Course SubModels
    | StateSaveFailed Course String


type alias Model =
    { token : String
    , state : State
    , editAllowed : Bool
    , cache : CachedData
    }


type FieldData
    = FieldDataTitle String
    | FieldDataDescription String
    | FieldDataForClass String
    | FieldDataForGroup String
    | FieldDataForSpecialization (Maybe Uuid)
    | FieldDataLogo (Maybe Uuid)
    | FieldDataCover (Maybe Uuid)
    | FieldDataArchived (Maybe Posix)
    | FieldDataType (Maybe CourseType)
    | FieldDataMarking (Maybe CourseMarking)


type Msg
    = MsgFetch (MT.Msg Http.Error FetchResult)
    | MsgOnClickSave
    | MsgOnClickEdit
    | MsgOnClickEditCancel
    | MsgSaveFailed Http.Error
    | MsgSaveDone Course
    | MsgOnEditField FieldData
    | MsgSubSpecMsg Select.Msg


emptyCourse : Course
emptyCourse =
    { id = Nothing
    , createdAt = Nothing
    , updatedAt = Nothing
    , type_ = Nothing
    , marking = Nothing
    , title = ""
    , description = Nothing
    , forClass = Nothing
    , forGroup = Nothing
    , archived = Nothing
    , forSpecialization = Nothing
    , logo = Nothing
    , cover = Nothing
    }


{-| Initialize the component.

**editMode**: Whether this course can be edited:

  - Nothing: the course cannot be edited at all.
  - Just False: the course can be edited and currently is in view-only mode.
  - Just True: the course can be edited and currently is in edit mode.

**initData**: A collection of cached related objects.

-}
init : APIToken -> Bool -> CachedData -> ( Model, Cmd Msg )
init token editAllowed initData =
    let
        fetchSpecs =
            initData.specs == Nothing

        fetchEnrollments =
            initData.teachers == Nothing && initData.course /= Nothing

        fetchRequired =
            fetchSpecs || fetchEnrollments

        ( m, c ) =
            MT.init <|
                List.concat
                    [ if fetchSpecs then
                        [ ( ext_task FetchedSpecs token [] <| educationSpecializationList
                          , "Получение данных о специализациях"
                          )
                        ]

                      else
                        []
                    , if fetchEnrollments then
                        [ ( ext_task FetchedTeachers
                                token
                                [ ( "role", stringFromCourseEnrollmentReadRole CourseEnrollmentReadRoleT )
                                ]
                            <|
                                courseEnrollmentList
                          , "Получение данных о записях на курс"
                          )
                        ]

                      else
                        []
                    ]

        model_ =
            { state =
                if fetchRequired then
                    StateInit m

                else
                    StateView
            , editAllowed = editAllowed
            , cache = initData
            , token = token
            }
    in
    ( model_
    , if not fetchRequired then
        Cmd.none

      else
        Cmd.map MsgFetch c
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        ignore =
            ( model, Cmd.none )
    in
    case msg of
        MsgFetch msg_ ->
            case model.state of
                StateInit model_ ->
                    case msg_ of
                        MT.TaskFinishedAll results ->
                            let
                                applyResult res cache =
                                    case res of
                                        Ok (FetchedTeachers teachers) ->
                                            { cache | teachers = Just teachers }

                                        Ok (FetchedSpecs specs) ->
                                            { cache | specs = Just specs }

                                        _ ->
                                            cache

                                newCache =
                                    List.foldl applyResult model.cache results
                            in
                            ( { model
                                | state = StateView
                                , cache = newCache
                              }
                            , Cmd.none
                            )

                        _ ->
                            -- TODO: handle errors
                            let
                                ( m, c ) =
                                    MT.update msg_ model_
                            in
                            ( { model
                                | state = StateInit m
                              }
                            , Cmd.map MsgFetch c
                            )

                _ ->
                    ignore

        MsgOnClickSave ->
            case model.state of
                StateEdit course modified subModels ->
                    ( { model | state = StateSaving course subModels }
                    , if modified then
                        task_to_cmd MsgSaveFailed MsgSaveDone <|
                            ext_task identity model.token [] <|
                                courseUpdate (get_id_str course) course

                      else
                        Cmd.none
                    )

                _ ->
                    ignore

        MsgOnClickEdit ->
            case model.state of
                StateView ->
                    let
                        ( m, c ) =
                            Select.init
                                "Направление"
                                True
                                (Dict.fromList <|
                                    List.map (\s -> ( get_id_str s, s.name )) (Maybe.withDefault [] model.cache.specs)
                                )

                        mbSpecID =
                            Maybe.andThen .forSpecialization model.cache.course

                        mSelected =
                            Maybe.withDefault m <|
                                Maybe.map (\u -> Select.doSelect (Uuid.toString u) m) mbSpecID
                    in
                    ( { model
                        | state =
                            StateEdit
                                (Maybe.withDefault emptyCourse model.cache.course)
                                False
                                { spec = mSelected }
                      }
                    , Cmd.map MsgSubSpecMsg c
                    )

                _ ->
                    ignore

        MsgOnClickEditCancel ->
            case model.state of
                StateEdit _ _ _ ->
                    ( { model | state = StateView }, Cmd.none )

                _ ->
                    ignore

        MsgSaveFailed error ->
            case model.state of
                StateSaving course subModels ->
                    ( { model | state = StateSaveFailed course (httpErrorToString error) }, Cmd.none )

                _ ->
                    ignore

        MsgSaveDone course ->
            case model.state of
                StateSaving _ subModels ->
                    ( { model
                        | state = StateView
                        , cache = (\cache -> { cache | course = Just course }) model.cache
                      }
                    , Cmd.none
                    )

                _ ->
                    ignore

        MsgOnEditField fieldData ->
            case model.state of
                StateEdit course _ subModels ->
                    let
                        newCourse =
                            case fieldData of
                                FieldDataTitle val ->
                                    { course | title = val }

                                FieldDataDescription val ->
                                    { course | description = Just val }

                                FieldDataForClass val ->
                                    { course | forClass = Just val }

                                FieldDataForGroup val ->
                                    { course | forGroup = Just val }

                                FieldDataForSpecialization val ->
                                    { course | forSpecialization = val }

                                FieldDataLogo val ->
                                    { course | logo = val }

                                FieldDataCover val ->
                                    { course | cover = val }

                                FieldDataArchived val ->
                                    { course | archived = val }

                                FieldDataType val ->
                                    { course | type_ = val }

                                FieldDataMarking val ->
                                    { course | marking = val }
                    in
                    ( { model
                        | state = StateEdit newCourse True subModels
                      }
                    , Cmd.none
                    )

                _ ->
                    ignore

        MsgSubSpecMsg msg_ ->
            case model.state of
                StateEdit course modified subModels ->
                    let
                        ( m, c ) =
                            Select.update msg_ subModels.spec

                        editFieldCmd =
                            case msg_ of
                                Select.MsgItemSelected specUUIDStr ->
                                    case Uuid.fromString specUUIDStr of
                                        Just specUUID ->
                                            sendMessage (MsgOnEditField (FieldDataForSpecialization (Just specUUID)))

                                        _ ->
                                            Cmd.none

                                _ ->
                                    Cmd.none
                    in
                    ( { model
                        | state = StateEdit course modified { subModels | spec = m }
                      }
                    , Cmd.batch
                        [ Cmd.map MsgSubSpecMsg c
                        , editFieldCmd
                        ]
                    )

                _ ->
                    ignore


viewView : Course -> Maybe UserShallow -> List EducationSpecialization -> Bool -> Html Msg
viewView course mbTeacher knownSpecs canEdit =
    let
        default_cover_url =
            "/img/course_cover.webp"

        default_logo_url =
            "/img/course.jpg"

        cover_img =
            Maybe.withDefault default_cover_url <|
                Maybe.map (\f -> "/api/file/" ++ Uuid.toString f ++ "/download") course.cover

        logo_img =
            Maybe.withDefault default_logo_url <|
                Maybe.map (\f -> "/api/file/" ++ Uuid.toString f ++ "/download") course.logo

        for_class =
            let
                classes =
                    [ class "users icon", style "color" "#679", style "white-space" "nowrap" ]
            in
            case ( course.forClass, course.forSpecialization ) of
                ( Just cls, Just specID ) ->
                    let
                        specName =
                            List.filter (\s -> s.id == Just specID) knownSpecs
                                |> List.head
                                |> Maybe.map (\s -> s.name)
                                |> Maybe.withDefault "Неизвестное"
                    in
                    span []
                        [ i classes []
                        , text <| cls ++ " класс (" ++ specName ++ " направление)"
                        ]

                ( Just cls, Nothing ) ->
                    span []
                        [ i classes []
                        , text <| cls ++ " класс"
                        ]

                ( _, _ ) ->
                    text ""

        for_group =
            case empty_to_nothing course.forGroup of
                Just g ->
                    span [ style "white-space" "nowrap" ]
                        [ i [ class "list ol icon", style "color" "#679" ] []
                        , text <| "Группа: " ++ g
                        ]

                Nothing ->
                    text ""

        description =
            if (String.trim <| Maybe.withDefault "" course.description) == "" then
                "(нет описания)"

            else
                Maybe.withDefault "" course.description

        teacher =
            case mbTeacher of
                Just t ->
                    span [ class "ml-10", style "white-space" "nowrap" ]
                        [ i [ class "user icon", style "color" "#679" ] []
                        , text
                            "Преподаватель: "
                        , a [ href <| "/profile/" ++ get_id_str t ] [ text <| user_full_name t ]
                        ]

                Nothing ->
                    text ""

        buttons =
            if canEdit then
                [ button
                    [ class "ui button yellow"
                    , onClick MsgOnClickEdit
                    ]
                    [ i [ class "icon edit outline" ] [], text "Редактировать" ]
                ]

            else
                []
    in
    div
        [ style "background" ("linear-gradient( rgba(0, 0, 0, 0.8), rgba(0, 0, 0, 0.8) ), url('" ++ cover_img ++ "')")
        , style "padding" "1em"
        , style "margin" "1em"
        , style "background-repeat" "no-repeat"
        , style "background-size" "cover"
        , style "color" "white"
        , class "row center-xs"
        ]
        [ div
            [ class "col-sm-3 col-xs center-xs"
            , style "min-width" "300px"
            , style "max-width" "300px"
            ]
            [ img
                [ src logo_img
                , style "object-fit" "cover"
                , style "object-position" "center"
                , style "width" "100%"
                , style "height" "300px"
                ]
                []
            ]
        , div [ class "col-sm between-xs row start-xs", style "flex-flow" "column nowrap" ]
            [ div []
                [ div [ class "ml-10 mr-10 row between-md center-xs", style "margin-bottom" "0.5em" ]
                    [ h1
                        [ class "col"
                        , style "margin" "0"
                        ]
                        [ text course.title ]
                    , div
                        [ class "col ml-10"
                        ]
                        buttons
                    ]
                , p [ style "max-height" "220px", style "overflow" "hidden", style "margin-left" "2em" ] [ text description ]
                ]
            , div [ class "row around-xs", style "margin-top" "2em" ]
                [ for_class
                , for_group
                , teacher
                ]
            ]
        ]


viewEdit : Course -> Select.Model -> Bool -> Bool -> Html Msg
viewEdit course selectSpec modified isSaving =
    let
        fieldBaseIB =
            InputBox.init

        fieldBaseTA =
            TextArea.init

        default_cover_url =
            "/img/course_cover.webp"

        default_logo_url =
            "/img/course.jpg"

        cover_img =
            Maybe.withDefault default_cover_url <|
                Maybe.map (\f -> "/api/file/" ++ Uuid.toString f ++ "/download") course.cover

        logo_img =
            Maybe.withDefault default_logo_url <|
                Maybe.map (\f -> "/api/file/" ++ Uuid.toString f ++ "/download") course.logo

        propClass =
            div [ class "col-xs-12 col-md-2" ]
                [ div [ class "row start-xs" ]
                    [ i [ class "users icon", style "color" "#679", style "white-space" "nowrap" ] []
                    , text "Класс: "
                    ]
                , div []
                    [ InputBox.view
                        { fieldBaseIB
                            | value = Maybe.withDefault "" course.forClass
                            , placeholder = "Класс"
                            , onInput = Just (MsgOnEditField << FieldDataForClass)
                            , isDisabled = isSaving
                            , isFluid = True
                        }
                    ]
                ]

        propSpec =
            div [ class "col-xs-12 col-md-2" ]
                [ div [ class "row start-xs" ]
                    [ --i [ class "users icon", style "color" "#679", style "white-space" "nowrap" ] []
                      text "Направление: "
                    ]
                , div []
                    [ Html.map MsgSubSpecMsg <| Select.view selectSpec
                    ]
                ]

        propGroup =
            div [ class "col-xs-12 col-md-2" ]
                [ div [ class "row start-xs" ]
                    [ i [ class "list ol icon", style "color" "#679" ] []
                    , text "Группа: "
                    ]
                , div []
                    [ InputBox.view
                        { fieldBaseIB
                            | value = Maybe.withDefault "" course.forGroup
                            , placeholder = "Группа"
                            , onInput = Just (MsgOnEditField << FieldDataForGroup)
                            , isDisabled = isSaving
                            , isFluid = True
                        }
                    ]
                ]

        buttons =
            [ button
                [ class "ui button"
                , onClick MsgOnClickEditCancel
                ]
                [ i [ class "icon close" ] [], text "Отмена" ]
            , button
                [ class "ui primary button"
                , classList [ ( "disabled", not modified ) ]
                , onClick MsgOnClickSave
                ]
                [ i [ class "icon save outline" ] [], text "Сохранить" ]
            ]

        logoCol =
            div
                [ class "col-sm-3 col-xs center-xs"
                , style "min-width" "300px"
                , style "max-width" "300px"
                ]
                [ img
                    [ src logo_img
                    , style "object-fit" "cover"
                    , style "object-position" "center"
                    , style "width" "100%"
                    , style "height" "300px"
                    ]
                    []
                ]

        infoCol =
            div [ class "col-xs-12 col-sm between-xs" ]
                [ div [ class "ml-10 mr-10 row between-md center-xs", style "margin-bottom" "0.5em" ]
                    [ div
                        [ class "col-xs-12 col-md mb-5"
                        , style "flex-grow" "1"
                        ]
                        [ InputBox.view
                            { fieldBaseIB
                                | value = course.title
                                , placeholder = "Название курса"
                                , onInput = Just (MsgOnEditField << FieldDataTitle)
                                , isDisabled = isSaving
                                , isFluid = True
                            }
                        ]
                    , div
                        [ class "col ml-10 mb-5 first-xs last-md" ]
                        buttons
                    ]
                , div [ style "margin-left" "11px" ]
                    [ TextArea.view
                        { fieldBaseTA
                            | value = Maybe.withDefault "" course.description
                            , placeholder = "Описание"
                            , onInput = Just (MsgOnEditField << FieldDataDescription)
                            , isDisabled = isSaving
                            , width = Just "100%"
                            , height = Just "100%"
                            , lines = 12
                        }
                    ]
                ]

        mainRow =
            div [ class "row center-xs" ] [ logoCol, infoCol ]

        secondaryPropsRow =
            div [ class "row center-xs end-md", style "margin-top" "2em" ]
                [ propClass
                , propSpec
                , propGroup
                ]
    in
    div
        [ style "background" ("linear-gradient( rgba(0, 0, 0, 0.8), rgba(0, 0, 0, 0.8) ), url('" ++ cover_img ++ "')")
        , style "padding" "1em"
        , style "margin" "1em"
        , style "background-repeat" "no-repeat"
        , style "background-size" "cover"
        , style "color" "white"
        ]
        [ mainRow
        , secondaryPropsRow
        ]


viewError : String -> Html Msg
viewError err =
    div [ class "row center-xs middle-xs" ]
        [ div [ class "row" ]
            [ i [ class "big exclamation triangle icon" ] []
            , h1 [] [ text "Произошла ошибка при сохранении курса" ]
            ]
        , div [ class "row" ]
            [ p [] [ text err ]
            ]
        ]


viewInit : MT.Model Http.Error FetchResult -> Html Msg
viewInit model_ =
    div [ class "row center-xs middle-xs" ]
        [ Html.map MsgFetch <|
            MT.view (always "OK") httpErrorToString model_
        ]


view : Model -> Html Msg
view model =
    case (Debug.log "model" model).state of
        StateInit model_ ->
            viewInit model_

        StateView ->
            viewView
                (Maybe.withDefault emptyCourse model.cache.course)
                (Maybe.map .person <| Maybe.andThen List.head model.cache.teachers)
                (Maybe.withDefault [] model.cache.specs)
                model.editAllowed

        StateEdit course modified subModels ->
            viewEdit course subModels.spec modified False

        StateSaving course subModels ->
            viewEdit course subModels.spec True True

        StateSaveFailed _ err ->
            viewError err


subscribtions : Model -> Sub Msg
subscribtions model =
    Sub.none

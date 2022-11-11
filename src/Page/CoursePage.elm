module Page.CoursePage exposing (..)

import Api exposing (ext_task, task, withToken)
import Api.Data exposing (Activity, ActivityContentType(..), CourseDeep, CourseEnrollmentRead, CourseEnrollmentReadRole(..), ImportForCourseResult, UserDeep)
import Api.Request.Activity exposing (activityImportForCourse)
import Api.Request.Course exposing (courseBulkSetActivities, courseGetDeep, courseRead)
import Component.Activity as CA exposing (Msg(..), getOrder, setOrder)
import Component.FileInput as FI
import Component.MessageBox as MessageBox exposing (Type(..))
import Component.Misc exposing (user_link)
import Component.Modal as Modal
import Component.MultiTask as MultiTask exposing (Msg(..))
import Dict exposing (Dict)
import File
import File.Download
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http exposing (Error(..))
import Page.CourseListPage exposing (empty_to_nothing)
import Set
import String exposing (trim)
import Task
import Time exposing (Posix)
import Util exposing (assoc_update, get_id_str, httpErrorToString, list_insert_at, maybeFilter, task_to_cmd, user_full_name, zip)
import Uuid exposing (Uuid)


type alias IsModified =
    Bool


type AddMode
    = AddNone
    | AddGen
    | AddFin


type EditMode
    = EditOff
    | EditOn AddMode IsModified


type State
    = Fetching (MultiTask.Model Http.Error FetchResult)
    | FetchDone CourseDeep (List ( Int, CA.Model ))
    | FetchFailed String


type Msg
    = MsgFetch (MultiTask.Msg Http.Error FetchResult)
    | MsgClickMembers
    | MsgCloseMembers
    | MsgCloseActivitiesImport
    | MsgOnClickImportActivities
    | MsgOnClickEdit
    | MsgOnClickEditCancel
    | MsgOnClickSave
    | MsgOnClickAddGen
    | MsgOnClickAddFin
    | MsgOnClickAddBefore Int (Maybe Posix)
    | MsgCourseSaved
    | MsgCourseSaveError String
    | MsgActivity Int CA.Msg
    | MsgFileInputImport FI.Msg
    | MsgOnClickActivitiesImport
    | MsgActivitiesImportFinished (Result String ImportForCourseResult)


type FetchResult
    = ResCourse CourseDeep


type ActivityImportState
    = ActivityImportStateNone
    | ActivityImportStateFileSelection FI.Model
    | ActivityImportStateInProgress
    | ActivityImportStateSuccess String
    | ActivityImportStateError String


type alias Model =
    { state : State
    , token : String
    , user : UserDeep
    , show_members : Bool
    , edit_mode : EditMode
    , save_error : Maybe String
    , is_staff : Bool
    , teaching_here : Bool
    , activity_component_pk : Int
    , activity_import_state : ActivityImportState
    }


showFetchResult : FetchResult -> String
showFetchResult fetchResult =
    case fetchResult of
        ResCourse courseRead ->
            courseRead.title


taskCourse token cid =
    Task.map ResCourse <| task <| withToken (Just token) <| courseGetDeep cid


init : String -> String -> UserDeep -> ( Model, Cmd Msg )
init token course_id user =
    let
        ( m, c ) =
            MultiTask.init
                [ ( taskCourse token course_id, "Получаем данные о курсе" )
                ]
    in
    ( { state = Fetching m
      , token = token
      , user = user
      , show_members = False
      , edit_mode = EditOff
      , save_error = Nothing
      , is_staff =
            not <|
                Set.isEmpty <|
                    Set.intersect (Set.fromList <| Maybe.withDefault [] user.roles) (Set.fromList [ "admin", "staff" ])
      , teaching_here = False
      , activity_component_pk = 0
      , activity_import_state = ActivityImportStateNone
      }
    , Cmd.map MsgFetch c
    )


collectFetchResults : List (Result e FetchResult) -> Maybe CourseDeep
collectFetchResults fetchResults =
    case fetchResults of
        [ Ok (ResCourse crs) ] ->
            Just crs

        _ ->
            Nothing


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.state of
        FetchDone _ id_comps ->
            Sub.batch <|
                List.map (\( k, v ) -> Sub.map (MsgActivity k) <| CA.subscriptions v) id_comps

        _ ->
            Sub.none


fixOrder : Model -> Model
fixOrder model =
    let
        fixOrder_ j l =
            let
                up =
                    j /= 0

                down =
                    case l of
                        [ _ ] ->
                            False

                        _ ->
                            True
            in
            case l of
                [] ->
                    []

                ( k, v ) :: tl ->
                    ( k, CA.setUpDownControls up down <| CA.setOrder (j + 1) v ) :: fixOrder_ (j + 1) tl
    in
    case model.state of
        FetchDone c acts ->
            { model
                | state =
                    FetchDone c <| fixOrder_ 0 acts
            }

        _ ->
            model


activityMoveUp id acts =
    case acts of
        (( k1, v1 ) as x) :: (( k2, v2 ) as y) :: tl ->
            if k2 == id then
                ( k2, setOrder (getOrder v2 - 1) v2 ) :: ( k1, setOrder (getOrder v1 + 1) v1 ) :: tl

            else
                x :: activityMoveUp id (y :: tl)

        _ ->
            acts


activityMoveDown id acts =
    case acts of
        (( k1, v1 ) as x) :: (( k2, v2 ) as y) :: tl ->
            if k1 == id then
                ( k2, setOrder (getOrder v2 - 1) v2 ) :: ( k1, setOrder (getOrder v1 + 1) v1 ) :: tl

            else
                x :: activityMoveDown id (y :: tl)

        _ ->
            acts


setModified : Bool -> Model -> Model
setModified mod model =
    case model.edit_mode of
        EditOff ->
            model

        EditOn addMode isModified ->
            { model | edit_mode = EditOn addMode mod }


setEditMode : Bool -> Model -> Model
setEditMode edt model =
    let
        new_state =
            case model.state of
                FetchDone courseDeep acts ->
                    FetchDone courseDeep <| List.map (\( k, v ) -> ( k, CA.setEditable edt v )) acts

                _ ->
                    model.state
    in
    { model
        | state = new_state
        , edit_mode =
            if edt then
                EditOn AddNone False

            else
                EditOff
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        parse_course course =
            let
                activities =
                    List.sortBy .order course.activities

                ( ms, cs ) =
                    List.unzip <| List.map (CA.init_from_activity model.token) activities

                len =
                    List.length ms

                id_range =
                    List.range model.activity_component_pk (model.activity_component_pk + len - 1)

                pairs_id_comp =
                    zip id_range ms

                pairs_id_cmd =
                    zip id_range cs
            in
            ( { model
                | state =
                    FetchDone course pairs_id_comp
                , activity_component_pk = model.activity_component_pk + len
                , teaching_here =
                    List.any
                        (\enr ->
                            enr.role == CourseEnrollmentReadRoleT && enr.person.id == model.user.id
                        )
                        course.enrollments
              }
            , Cmd.batch <| List.map (\( id, c_ ) -> Cmd.map (MsgActivity id) c_) pairs_id_cmd
            )
    in
    case ( msg, model.state ) of
        ( MsgFetch msg_, Fetching model_ ) ->
            let
                ( m, c ) =
                    MultiTask.update msg_ model_
            in
            case msg_ of
                TaskFinishedAll results ->
                    case collectFetchResults results of
                        Just course ->
                            parse_course course

                        Nothing ->
                            ( { model | state = FetchFailed "Не удалось разобрать результаты запросов" }, Cmd.none )

                _ ->
                    ( { model | state = Fetching m }, Cmd.map MsgFetch c )

        ( MsgClickMembers, _ ) ->
            ( { model | show_members = True }, Cmd.none )

        ( MsgCloseMembers, _ ) ->
            ( { model | show_members = False }, Cmd.none )

        ( MsgOnClickEdit, FetchDone _ _ ) ->
            ( fixOrder <|
                setEditMode True
                    { model
                        | edit_mode = EditOn AddNone False
                    }
            , Cmd.none
            )

        ( MsgActivity id msg_, FetchDone course act_components ) ->
            case
                List.head <| List.filter (Tuple.first >> (==) id) act_components
            of
                Just ( _, component ) ->
                    let
                        ( m, c ) =
                            CA.update msg_ component

                        ( new_model, cmd ) =
                            case msg_ of
                                CA.MsgMoveUp ->
                                    ( fixOrder
                                        { model
                                            | state =
                                                FetchDone course <|
                                                    activityMoveUp id <|
                                                        assoc_update id m act_components
                                        }
                                    , Cmd.batch [ Cmd.map (MsgActivity id) c, CA.doScrollInto m ]
                                    )

                                CA.MsgMoveDown ->
                                    ( fixOrder
                                        { model
                                            | state =
                                                FetchDone course <|
                                                    activityMoveDown id <|
                                                        assoc_update id m act_components
                                        }
                                    , Cmd.batch [ Cmd.map (MsgActivity id) c, CA.doScrollInto m ]
                                    )

                                CA.MsgOnClickDelete ->
                                    ( fixOrder
                                        { model
                                            | state =
                                                FetchDone course <| List.filter (Tuple.first >> (/=) id) act_components
                                        }
                                    , Cmd.none
                                    )

                                _ ->
                                    ( { model
                                        | state =
                                            FetchDone course <|
                                                assoc_update id m act_components
                                      }
                                    , Cmd.map (MsgActivity id) c
                                    )
                    in
                    ( setModified True new_model, cmd )

                Nothing ->
                    ( model, Cmd.none )

        ( MsgOnClickAddGen, _ ) ->
            let
                new_mode =
                    case model.edit_mode of
                        EditOn _ mod ->
                            EditOn AddGen mod

                        _ ->
                            EditOn AddGen False
            in
            ( { model
                | edit_mode = new_mode
              }
            , Cmd.none
            )

        ( MsgOnClickAddFin, _ ) ->
            let
                new_mode =
                    case model.edit_mode of
                        EditOn _ mod ->
                            EditOn AddFin mod

                        _ ->
                            EditOn AddFin False
            in
            ( { model | edit_mode = new_mode }, Cmd.none )

        ( MsgOnClickAddBefore i Nothing, _ ) ->
            ( model, Task.perform (Just >> MsgOnClickAddBefore i) <| Time.now )

        ( MsgOnClickAddBefore i (Just t), FetchDone course act_components ) ->
            let
                act =
                    case ( model.edit_mode, course.id ) of
                        ( EditOn AddGen _, Just cid ) ->
                            Just
                                { id = Nothing
                                , createdAt = Nothing
                                , updatedAt = Nothing
                                , title = ""
                                , lessonType = Nothing
                                , keywords = Nothing
                                , isHidden = Just False
                                , marksLimit = Just 2
                                , hours = Just 1
                                , fgosComplient = Just False
                                , order = i + 1
                                , date = t
                                , group = Nothing
                                , scientificTopic = Nothing
                                , body = Nothing
                                , dueDate = Nothing
                                , link = Nothing
                                , embed = Nothing
                                , finalType = Nothing
                                , contentType = Just ActivityContentTypeGEN
                                , course = cid
                                , files = Nothing
                                , linkedActivity = Nothing
                                }

                        ( EditOn AddFin _, Just cid ) ->
                            Just
                                { id = Nothing
                                , createdAt = Nothing
                                , updatedAt = Nothing
                                , title = ""
                                , lessonType = Nothing
                                , keywords = Nothing
                                , isHidden = Just False
                                , marksLimit = Just 2
                                , hours = Just 1
                                , fgosComplient = Just False
                                , order = i + 1
                                , date = t
                                , group = Nothing
                                , scientificTopic = Nothing
                                , body = Nothing
                                , dueDate = Nothing
                                , link = Nothing
                                , embed = Nothing
                                , finalType = Nothing
                                , contentType = Just ActivityContentTypeFIN
                                , course = cid
                                , files = Nothing
                                , linkedActivity = Nothing
                                }

                        _ ->
                            Nothing
            in
            case act of
                Nothing ->
                    ( model, Cmd.none )

                Just act_ ->
                    let
                        ( m, c ) =
                            CA.init_from_activity model.token act_
                    in
                    ( fixOrder <|
                        setModified True <|
                            { model
                                | activity_component_pk = model.activity_component_pk + 1

                                --, edit_mode = EditOn AddNone
                                , state =
                                    FetchDone course <|
                                        list_insert_at
                                            i
                                            ( model.activity_component_pk, CA.setEditable True m )
                                            act_components
                            }
                    , Cmd.map (MsgActivity model.activity_component_pk) c
                    )

        ( MsgOnClickEditCancel, FetchDone course _ ) ->
            let
                ( m, c ) =
                    parse_course course
            in
            ( setEditMode False m, c )

        ( MsgOnClickSave, FetchDone course act_components ) ->
            let
                ac_to_tuple : CA.Model -> Maybe ( String, Activity )
                ac_to_tuple c =
                    case CA.getActivity c of
                        Just act ->
                            case act.id of
                                Just id ->
                                    Just ( Uuid.toString id, act )

                                Nothing ->
                                    Nothing

                        Nothing ->
                            Nothing

                create : List Activity
                create =
                    List.filterMap
                        (Tuple.second
                            >> CA.getActivity
                            >> maybeFilter (.id >> (==) Nothing)
                        )
                        act_components

                update_ : Dict String Activity
                update_ =
                    Dict.fromList <| List.filterMap (Tuple.second >> ac_to_tuple) act_components
            in
            ( model
            , task_to_cmd (httpErrorToString >> MsgCourseSaveError) (\_ -> MsgCourseSaved) <|
                ext_task identity
                    model.token
                    []
                    (courseBulkSetActivities
                        (Maybe.withDefault "" <| Maybe.map Uuid.toString course.id)
                        { create = create
                        , update = update_
                        }
                    )
            )

        ( MsgCourseSaveError e, FetchDone course act_components ) ->
            ( { model | save_error = Just e }, Cmd.none )

        ( MsgCourseSaved, FetchDone course act_components ) ->
            let
                ( m, c ) =
                    init model.token (Maybe.withDefault "" <| Maybe.map Uuid.toString course.id) model.user
            in
            ( setEditMode False m
            , c
            )

        -- TODO: update course?
        ( MsgOnClickImportActivities, _ ) ->
            let
                ( m, c ) =
                    FI.init (Just "Выберите файл с темами") [ "text/csv" ]
            in
            ( { model | activity_import_state = ActivityImportStateFileSelection m }, Cmd.map MsgFileInputImport c )

        ( MsgCloseActivitiesImport, _ ) ->
            ( { model | activity_import_state = ActivityImportStateNone }, Cmd.none )

        ( MsgFileInputImport msg_, _ ) ->
            case model.activity_import_state of
                ActivityImportStateFileSelection model_ ->
                    let
                        ( m, c ) =
                            FI.update msg_ model_
                    in
                    ( { model | activity_import_state = ActivityImportStateFileSelection m }, Cmd.map MsgFileInputImport c )

                _ ->
                    ( model, Cmd.none )

        ( MsgOnClickActivitiesImport, FetchDone course _ ) ->
            case model.activity_import_state of
                ActivityImportStateFileSelection model_ ->
                    case ( model_.file, course.id ) of
                        ( Just file, Just cid ) ->
                            ( { model
                                | activity_import_state = ActivityImportStateInProgress
                              }
                            , File.toString file
                                |> Task.andThen
                                    (\csv ->
                                        ext_task identity model.token [] <|
                                            activityImportForCourse { data = csv, courseId = cid }
                                    )
                                |> Task.mapError httpErrorToString
                                |> Task.attempt MsgActivitiesImportFinished
                            )

                        _ ->
                            ( model, Cmd.none )

                ActivityImportStateSuccess status ->
                    ( model, Cmd.none )

                ActivityImportStateError err ->
                    ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ( MsgActivitiesImportFinished res, _ ) ->
            case res of
                Ok v ->
                    ( { model
                        | activity_import_state =
                            ActivityImportStateSuccess <|
                                "Записей создано: "
                                    ++ (String.fromInt <| List.length v.objects)
                      }
                    , Cmd.none
                    )

                Err e ->
                    ( { model | activity_import_state = ActivityImportStateError e }, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )


viewActivitiesImport : Model -> Html Msg
viewActivitiesImport model =
    let
        form state =
            div []
                [ p []
                    [ text "Перед началом импорта убедитесь, что ваш файл с темами сохранен в формате "
                    , strong [] [ text "CSV" ]
                    , text " и имеет заголовок (первую строку) со следующими полями:"
                    ]
                , ul []
                    [ li [] [ strong [] [ text "Номер" ], text " - ЧИСЛО, номер темы в списке" ]
                    , li [] [ strong [] [ text "Дата" ], text " - ДАТА(ЧЧ.ММ.ГГГГ), дата проведения урока" ]
                    , li [] [ strong [] [ text "Тема" ], text " - ТЕКСТ, название темы" ]
                    , li [] [ strong [] [ text "Ключевое слово" ], text " - ТЕКСТ, краткое название темы (отображается в \"шапке\" таблицы)" ]
                    , li [] [ strong [] [ text "Раздел" ], text " - ТЕКСТ, название раздела. Для группировки тем" ]
                    , li [] [ strong [] [ text "ФГОС" ], text " - ЛОГИЧЕСКОЕ(Да, Нет), соответствует ли тема ФГОС" ]
                    , li [] [ strong [] [ text "Раздел научной дисциплины" ], text " - ТЕКСТ, название наздела научной дисциплины" ]
                    , li [] [ strong [] [ text "Форма занятия" ], text " - ТЕКСТ, форма занятия (Контрольная работа, Тест, Лекция, ...)" ]
                    , li [] [ strong [] [ text "Материалы урока" ], text " - ТЕКСТ, ссылки на материалы урока (в свободной форме)" ]
                    , li [] [ strong [] [ text "Домашнее задание" ], text " - ТЕКСТ, текст домашнего задания (в свободной форме)" ]
                    , li [] [ strong [] [ text "Количество оценок" ], text " - ЧИСЛО, максимальное количество оценок по теме" ]
                    , li [] [ strong [] [ text "Часы" ], text " - ЧИСЛО, количество академических часов по данному уроку" ]
                    ]
                , p [] [ text "Скачать шаблон такого файла можно по ", a [ href "/template_activities.csv" ] [ text "ссылке" ], text "." ]
                , p []
                    [ text <|
                        "Убедившись, что ваш файл соответствует указанному выше формату, укажите его в поле ниже и отправьте на сервер. "
                            ++ "По завершению процесса импорта вы увидите результат (успех, ошибка)."
                    ]
                , div [ class "row center-xs" ]
                    [ state
                    ]
                ]
    in
    case model.activity_import_state of
        ActivityImportStateFileSelection m ->
            case m.file of
                Just file ->
                    form <|
                        div [ class "col", style "display" "inline-block" ]
                            [ Html.map
                                MsgFileInputImport
                              <|
                                FI.view m
                            , button [ class "ui button green", onClick MsgOnClickActivitiesImport ] [ text "Начать импорт" ]
                            ]

                Nothing ->
                    form <|
                        div [ class "col", style "display" "inline-block" ]
                            [ Html.map
                                MsgFileInputImport
                              <|
                                FI.view m
                            ]

        ActivityImportStateNone ->
            text ""

        ActivityImportStateInProgress ->
            form <|
                div [ class "col", style "display" "inline-block" ]
                    [ MessageBox.view
                        MessageBox.None
                        True
                        Nothing
                        (text "")
                        (text "Выполняется импорт")
                    ]

        ActivityImportStateSuccess msg ->
            form <|
                div [ class "col", style "display" "inline-block" ]
                    [ MessageBox.view
                        MessageBox.Success
                        False
                        Nothing
                        (text "")
                        (text <| "Импорт успешно завершен: " ++ msg)
                    ]

        ActivityImportStateError err ->
            form <|
                div [ class "col", style "display" "inline-block" ]
                    [ MessageBox.view
                        MessageBox.Error
                        False
                        Nothing
                        (text "")
                        (text <| "Импорт выполнен с ошибкой: " ++ err)
                    ]


viewCourse : CourseDeep -> List ( Int, CA.Model ) -> Model -> Html Msg
viewCourse courseRead components_activity model =
    let
        breadcrumbs =
            div [ class "ui large breadcrumb" ]
                [ a [ class "section", href "/courses" ]
                    [ text "Предметы" ]
                , i [ class "right chevron icon divider" ]
                    []
                , div [ class "active section" ]
                    [ text courseRead.title ]
                ]

        header =
            let
                default_cover_url =
                    "/img/course_cover.webp"

                default_logo_url =
                    "/img/course.jpg"

                cover_img =
                    Maybe.withDefault default_cover_url <|
                        Maybe.map (\f -> "/api/file/" ++ get_id_str f ++ "/download") courseRead.cover

                logo_img =
                    Maybe.withDefault default_logo_url <|
                        Maybe.map (\f -> "/api/file/" ++ get_id_str f ++ "/download") courseRead.logo

                for_class =
                    let
                        classes =
                            [ class "users icon", style "color" "#679", style "white-space" "nowrap" ]
                    in
                    case ( courseRead.forClass, courseRead.forSpecialization ) of
                        ( Just cls, Just spec ) ->
                            span []
                                [ i classes []
                                , text <| cls ++ " класс (" ++ spec.name ++ " направление)"
                                ]

                        ( Just cls, Nothing ) ->
                            span []
                                [ i classes []
                                , text <| cls ++ " класс"
                                ]

                        ( _, _ ) ->
                            text ""

                for_group =
                    case empty_to_nothing courseRead.forGroup of
                        Just g ->
                            span [ style "white-space" "nowrap" ]
                                [ i [ class "list ol icon", style "color" "#679" ] []
                                , text <| g
                                ]

                        Nothing ->
                            text ""

                description =
                    if String.trim courseRead.description == "" then
                        "(нет описания)"

                    else
                        courseRead.description

                teacher =
                    case List.head <| List.filter (\e -> e.role == CourseEnrollmentReadRoleT) courseRead.enrollments of
                        Just t ->
                            span [ class "ml-10", style "white-space" "nowrap" ]
                                [ i [ class "user icon", style "color" "#679" ] []
                                , text
                                    "Преподаватель: "
                                , a [ href <| "/profile/" ++ get_id_str t.person ] [ text <| user_full_name t.person ]
                                ]

                        Nothing ->
                            text ""

                buttons =
                    case ( model.is_staff || model.teaching_here, model.edit_mode ) of
                        ( False, _ ) ->
                            []

                        ( _, EditOff ) ->
                            [ button
                                [ class "ui button yellow"
                                , onClick MsgOnClickEdit
                                ]
                                [ i [ class "icon edit outline" ] [], text "Редактировать" ]
                            ]

                        ( _, EditOn _ mod ) ->
                            [ button
                                [ class "ui button"
                                , onClick MsgOnClickEditCancel
                                ]
                                [ i [ class "icon close" ] [], text "Отмена" ]
                            , button
                                [ class "ui primary button"
                                , classList [ ( "disabled", not mod ) ]
                                , onClick MsgOnClickSave
                                ]
                                [ i [ class "icon save outline" ] [], text "Сохранить" ]
                            , Maybe.withDefault (text "") <|
                                Maybe.map
                                    (\err ->
                                        div
                                            [ class "ui popup error bottom center transition visible"
                                            , style "position" "relative"
                                            , style "display" "block"
                                            ]
                                            [ div [ class "header" ]
                                                [ text "Ошибка при сохранении" ]
                                            , div [ class "" ]
                                                [ text err ]
                                            ]
                                    )
                                    model.save_error
                            ]
            in
            div
                [ style "background" ("linear-gradient( rgba(0, 0, 0, 0.8), rgba(0, 0, 0, 0.8) ), url('" ++ cover_img ++ "')")
                , style "padding" "1em"
                , style "margin" "1em"
                , style "overflow" "hidden"
                , style "color" "white"
                , class "row center-xs"
                ]
                [ div
                    [ class "col-sm-3 col-xs center-xs"
                    , style "margin-right" "1em"
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
                , div [ class "col-sm between-xs row start-xs", style "margin" "1em", style "flex-flow" "column nowrap" ]
                    [ div []
                        [ div [ class "row between-xs middle-xs", style "margin-bottom" "0.5em" ]
                            [ h1
                                [ class "col"
                                , style "margin" "0"
                                ]
                                [ text courseRead.title ]
                            , div
                                [ class "col"
                                ]
                                buttons
                            ]
                        , p [ style "max-height" "180px", style "overflow" "hidden", style "margin-left" "2em" ] [ text description ]
                        ]
                    , div [ class "row around-xs", style "margin-top" "2em" ]
                        [ for_class
                        , for_group
                        , teacher
                        ]
                    ]
                ]

        add_activity_bar =
            if model.edit_mode /= EditOff then
                div
                    [ class "ui text container segment mr-10"
                    , style "background-color" "#EEE"
                    , style "position" "sticky"
                    , style "top" "0"
                    , style "z-index" "10"
                    ]
                    [ div [ class "row around-xs" ]
                        [ div [ class "col-xs-12 col-md-8 mb-5" ]
                            [ div
                                [ style "min-width" "100px"
                                , style "display" "inline-block"
                                , style "text-align" "right"
                                , class "mr-10"
                                ]
                                [ text "Добавить: " ]
                            , button [ class "ui button green", onClick MsgOnClickAddGen ]
                                [ i [ class "plus icon" ] []
                                , text "Тема"
                                ]
                            , button [ class "ui button green", onClick MsgOnClickAddFin ]
                                [ i [ class "plus icon" ] []
                                , text "Контроль"
                                ]
                            ]
                        , div [ class "col-xs-12 col-md-4 start-xs end-md mb-5" ]
                            [ span
                                [ style "min-width" "100px"
                                , style "display" "inline-block"
                                , style "text-align" "right"
                                , class "mr-10"
                                ]
                                [ text "Импорт: " ]
                            , button [ class "ui button green", onClick MsgOnClickImportActivities ]
                                [ i [ class "file icon" ] []
                                , text "CSV"
                                ]
                            ]
                        ]
                    ]

            else
                text ""

        add_activity_placeholder i =
            let
                base : String -> Html Msg
                base txt =
                    div
                        [ class "row center-xs m-10"
                        ]
                        [ div
                            [ class "ui text container p-5"
                            , style "border" "1px dashed #AAA"
                            , style "cursor" "pointer"
                            , onClick (MsgOnClickAddBefore i Nothing)
                            ]
                            [ text txt
                            ]
                        ]
            in
            case model.edit_mode of
                EditOn AddGen _ ->
                    base "Добавить тему здесь"

                EditOn AddFin _ ->
                    base "Добавить контроль здесь"

                _ ->
                    text ""

        activities =
            let
                l =
                    --List.sortBy (Tuple.second >> getOrder)
                    components_activity
            in
            case l of
                [] ->
                    [ h3 [] [ text "Нет активностей для отображения" ] ]

                _ ->
                    List.concat <|
                        List.indexedMap
                            (\i ( id, comp ) ->
                                [ CA.view comp |> Html.map (MsgActivity id)
                                , add_activity_placeholder (i + 1)
                                ]
                            )
                            l

        members =
            let
                teachers =
                    List.map .person <|
                        List.filter (\enr -> enr.role == CourseEnrollmentReadRoleT) courseRead.enrollments

                students =
                    List.map .person <|
                        List.filter (\enr -> enr.role == CourseEnrollmentReadRoleS) courseRead.enrollments

                user_list =
                    List.map (user_link Nothing >> (\el -> div [ style "margin" "1em" ] [ el ]))
            in
            div []
                [ h3 [] [ text "Преподаватели" ]
                , div [ style "padding-left" "1em" ] <| user_list teachers
                , h3 [] [ text "Учащиеся" ]
                , div [ style "padding-left" "1em" ] <| user_list students
                ]

        modal_members do_show =
            Modal.view
                "members"
                "Участники"
                members
                MsgCloseMembers
                [ ( "Закрыть", MsgCloseMembers ) ]
                do_show

        modal_activities_import m =
            case m of
                ActivityImportStateNone ->
                    text ""

                _ ->
                    Modal.view
                        "activities_import"
                        "Импорт тем"
                        (viewActivitiesImport model)
                        MsgCloseActivitiesImport
                        [ ( "Закрыть", MsgCloseActivitiesImport ) ]
                        True

        activities_title =
            h1 [ class "row between-xs" ]
                [ text "Содержание"
                , div []
                    [ if model.is_staff || model.teaching_here then
                        a [ href <| "/marks/course/" ++ get_id_str courseRead ]
                            [ button [ class "ui button" ]
                                [ i [ class "chart bar outline icon" ] []
                                , text "Оценки"
                                ]
                            ]

                      else
                        text ""
                    , button [ class "ui button", onClick MsgClickMembers ]
                        [ i [ class "users icon" ] []
                        , text "Участники"
                        ]
                    ]
                ]
    in
    div [ style "padding-bottom" "3em" ]
        [ modal_members model.show_members
        , modal_activities_import model.activity_import_state
        , breadcrumbs
        , header
        , activities_title
        , add_activity_bar
        , add_activity_placeholder 0
        , div [ class "col center-xs" ] activities
        ]


view : Model -> Html Msg
view model =
    case model.state of
        Fetching model_ ->
            let
                fetcher =
                    MultiTask.view showFetchResult httpErrorToString model_
            in
            div [ class "ui text container" ] [ Html.map MsgFetch fetcher ]

        FetchDone courseRead components_activity ->
            viewCourse courseRead components_activity model

        FetchFailed err ->
            MessageBox.view Error False Nothing (text "Ошибка") (text <| "Не удалось получить данные курса: " ++ err)

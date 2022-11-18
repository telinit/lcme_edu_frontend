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
import Csv
import Dict exposing (Dict)
import File
import File.Download
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error(..))
import List exposing (filterMap)
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
    | AddTsk
    | AddTxt


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
    | MsgOnClickAddTsk
    | MsgOnClickAddTxt
    | MsgOnClickAddBefore Int (Maybe Posix)
    | MsgCourseSaved
    | MsgCourseSaveError String
    | MsgActivity Int CA.Msg
    | MsgFileInputImport FI.Msg
    | MsgOnInputActivityCSVSep String
    | MsgOnClickActivitiesImport
    | MsgActivitiesImportFinished (Result String ImportForCourseResult)
    | MsgActivityImportGotCSVData Char String
    | MsgOnClickToggleActivityImportSettings


type FetchResult
    = ResCourse CourseDeep


type IssueKind
    = IssueKindWarning
    | IssueKindError
    | IssueKindNotice


type alias ActivityCSVValidationIssue =
    { kind : IssueKind
    , row : Maybe Int
    , col : Maybe Int
    , msg : String
    }


type ActivityImportState
    = ActivityImportStateNone
    | ActivityImportStateDataInput Bool String FI.Model
    | ActivityImportStateValidationInProgress
    | ActivityImportStateValidationFinished Char String (Result (List ActivityCSVValidationIssue) ())
    | ActivityImportStateInProgress
    | ActivityImportStateFinished (Result String String)


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


validateActivityCSV : Char -> String -> List ActivityCSVValidationIssue
validateActivityCSV sep data =
    let
        hasErrors =
            List.any (\i -> i.kind == IssueKindError)

        parsed =
            Csv.parseWith sep data

        validateHeaderRow : List String -> List ActivityCSVValidationIssue
        validateHeaderRow fields =
            case fields of
                [] ->
                    [ { kind = IssueKindError
                      , row = Just 1
                      , col = Nothing
                      , msg = "Не обнаружен заголовок. Возможно, ваш файл пустой или пуста первая строка."
                      }
                    ]

                _ ->
                    let
                        trimmedFields =
                            List.map String.trim fields

                        fieldsWithExtraWS =
                            List.filterMap identity <|
                                List.indexedMap
                                    (\i f ->
                                        if f /= String.trim f then
                                            Just
                                                { kind = IssueKindWarning
                                                , row = Just 1
                                                , col = Just (i + 1)
                                                , msg = "Лишние пробельные символы в поле '" ++ f ++ "'"
                                                }

                                        else
                                            Nothing
                                    )
                                    fields

                        requiredFields =
                            Set.fromList
                                [ "Номер"
                                , "Дата"
                                , "Тема"
                                , "Ключевое слово"
                                , "Раздел"
                                , "ФГОС"
                                , "Раздел научной дисциплины"
                                , "Форма занятия"
                                , "Материалы урока"
                                , "Домашнее задание"
                                , "Количество оценок"
                                , "Часы"
                                ]

                        actualFields =
                            Set.fromList trimmedFields

                        missingFields =
                            Set.toList <| Set.diff requiredFields actualFields

                        missingErrors =
                            List.map
                                (\fieldName ->
                                    { kind = IssueKindError
                                    , row = Just 1
                                    , col = Nothing
                                    , msg = "Не обнаружено обязательное поле '" ++ fieldName ++ "'"
                                    }
                                )
                                missingFields

                        extraWarnings =
                            List.filterMap identity <|
                                List.indexedMap
                                    (\c fieldName ->
                                        if Set.member (String.trim fieldName) requiredFields then
                                            Nothing

                                        else
                                            Just
                                                { kind = IssueKindWarning
                                                , row = Just 1
                                                , col = Just (c + 1)
                                                , msg = "Обнаружено лишнее поле '" ++ fieldName ++ "'"
                                                }
                                    )
                                    fields
                    in
                    missingErrors ++ extraWarnings

        validateBodyRow : Int -> List String -> List String -> List ActivityCSVValidationIssue
        validateBodyRow row_num header fields =
            let
                validateInt i k v =
                    let
                        tv =
                            String.trim v
                    in
                    case String.toInt tv of
                        Just _ ->
                            []

                        Nothing ->
                            [ { kind = IssueKindError
                              , row = Just row_num
                              , col = Just i
                              , msg = "Значение в поле '" ++ k ++ "' не является целым числом: '" ++ v ++ "'"
                              }
                            ]

                validateCell i k v =
                    let
                        tv =
                            String.trim v

                        extraWS =
                            if v /= tv then
                                [ { kind = IssueKindWarning
                                  , row = Just row_num
                                  , col = Just i
                                  , msg = "Лишние пробелы в ячейке"
                                  }
                                ]

                            else
                                []

                        emptyValue =
                            if tv == "" then
                                [ { kind = IssueKindWarning
                                  , row = Just row_num
                                  , col = Just i
                                  , msg = "Не указано значение поля '" ++ k ++ "'"
                                  }
                                ]

                            else
                                []
                    in
                    extraWS
                        ++ (case k of
                                "Номер" ->
                                    validateInt i k v

                                "Дата" ->
                                    let
                                        parts =
                                            List.map String.toInt <| String.split "." tv
                                    in
                                    case parts of
                                        [ Just d, Just m, Just y ] ->
                                            let
                                                ed =
                                                    if d < 1 || d > 31 then
                                                        [ { kind = IssueKindError
                                                          , row = Just row_num
                                                          , col = Just i
                                                          , msg = "Некорректное значение числа в дате"
                                                          }
                                                        ]

                                                    else
                                                        []

                                                em =
                                                    if m < 1 || m > 12 then
                                                        [ { kind = IssueKindError
                                                          , row = Just row_num
                                                          , col = Just i
                                                          , msg = "Некорректное значение месяца в дате"
                                                          }
                                                        ]

                                                    else
                                                        []

                                                ey =
                                                    if y < 1990 then
                                                        [ { kind = IssueKindError
                                                          , row = Just row_num
                                                          , col = Just i
                                                          , msg = "Некорректное значение года в дате"
                                                          }
                                                        ]

                                                    else
                                                        []
                                            in
                                            ed ++ em ++ ey

                                        _ ->
                                            if tv == "" then
                                                []
                                                -- Allow empty

                                            else
                                                [ { kind = IssueKindError
                                                  , row = Just row_num
                                                  , col = Just i
                                                  , msg = "Некорректное значение даты"
                                                  }
                                                ]

                                "Тема" ->
                                    if tv == "" then
                                        [ { kind = IssueKindError
                                          , row = Just row_num
                                          , col = Just i
                                          , msg = "Не указана тема"
                                          }
                                        ]

                                    else
                                        []

                                "Ключевое слово" ->
                                    if tv == "" then
                                        emptyValue

                                    else if String.length tv > 50 then
                                        [ { kind = IssueKindWarning
                                          , row = Just row_num
                                          , col = Just i
                                          , msg = "Ключевое слово слишком длинное (>50 символов)"
                                          }
                                        ]

                                    else
                                        []

                                "Раздел" ->
                                    emptyValue

                                "ФГОС" ->
                                    if List.member (String.toLower tv) [ "да", "нет" ] then
                                        []

                                    else
                                        [ { kind = IssueKindError
                                          , row = Just row_num
                                          , col = Just i
                                          , msg = "Значение должно быть одно из: Да, Нет"
                                          }
                                        ]

                                "Раздел научной дисциплины" ->
                                    emptyValue

                                "Форма занятия" ->
                                    emptyValue

                                "Материалы урока" ->
                                    []

                                "Домашнее задание" ->
                                    []

                                "Количество оценок" ->
                                    validateInt i k v

                                "Часы" ->
                                    validateInt i k v

                                _ ->
                                    []
                           )
            in
            -- TODO: compare lengths of 'header' and 'fields'
            List.concat <|
                List.map3
                    validateCell
                    (List.range 1 (List.length fields))
                    header
                    fields
    in
    let
        headerErrors =
            validateHeaderRow parsed.headers

        trimmedHeader =
            List.map String.trim parsed.headers
    in
    if hasErrors headerErrors then
        headerErrors

    else
        case parsed.records of
            [] ->
                { kind = IssueKindNotice
                , row = Nothing
                , col = Nothing
                , msg =
                    "Нет строк для импорта."
                }
                    :: headerErrors

            _ ->
                let
                    bodyErrors =
                        List.indexedMap (\i -> validateBodyRow (i + 2) trimmedHeader) parsed.records
                in
                headerErrors ++ List.concat bodyErrors


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

        ( MsgOnClickAddTsk, _ ) ->
            let
                new_mode =
                    case model.edit_mode of
                        EditOn _ mod ->
                            EditOn AddTsk mod

                        _ ->
                            EditOn AddTsk False
            in
            ( { model | edit_mode = new_mode }, Cmd.none )

        ( MsgOnClickAddTxt, _ ) ->
            let
                new_mode =
                    case model.edit_mode of
                        EditOn _ mod ->
                            EditOn AddTxt mod

                        _ ->
                            EditOn AddTxt False
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
                                , date = Just t
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
                                , submittable = Just False
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
                                , date = Just t
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
                                , submittable = Just False
                                }

                        ( EditOn AddTsk _, Just cid ) ->
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
                                , date = Just t
                                , group = Nothing
                                , scientificTopic = Nothing
                                , body = Nothing
                                , dueDate = Nothing
                                , link = Nothing
                                , embed = Nothing
                                , finalType = Nothing
                                , contentType = Just ActivityContentTypeTSK
                                , course = cid
                                , files = Nothing
                                , linkedActivity = Nothing
                                , submittable = Just False
                                }

                        ( EditOn AddTxt _, Just cid ) ->
                            Just
                                { id = Nothing
                                , createdAt = Nothing
                                , updatedAt = Nothing
                                , title = ""
                                , lessonType = Nothing
                                , keywords = Nothing
                                , isHidden = Just False
                                , marksLimit = Just 0
                                , hours = Just 1
                                , fgosComplient = Just False
                                , order = i + 1
                                , date = Just t
                                , group = Nothing
                                , scientificTopic = Nothing
                                , body = Nothing
                                , dueDate = Nothing
                                , link = Nothing
                                , embed = Nothing
                                , finalType = Nothing
                                , contentType = Just ActivityContentTypeTXT
                                , course = cid
                                , files = Nothing
                                , linkedActivity = Nothing
                                , submittable = Just False
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
            ( { model | activity_import_state = ActivityImportStateDataInput False "," m }, Cmd.map MsgFileInputImport c )

        ( MsgCloseActivitiesImport, _ ) ->
            ( { model | activity_import_state = ActivityImportStateNone }, Cmd.none )

        ( MsgFileInputImport msg_, _ ) ->
            case model.activity_import_state of
                ActivityImportStateDataInput show_settings sep model_ ->
                    let
                        ( m, c ) =
                            FI.update msg_ model_
                    in
                    case msg_ of
                        FI.MsgFileSelected f ->
                            ( { model
                                | activity_import_state = ActivityImportStateValidationInProgress
                              }
                            , Cmd.batch
                                [ Cmd.map MsgFileInputImport c
                                , Task.perform
                                    (MsgActivityImportGotCSVData <|
                                        Maybe.withDefault ',' <|
                                            Maybe.map Tuple.first <|
                                                String.uncons sep
                                    )
                                  <|
                                    File.toString f
                                ]
                            )

                        _ ->
                            ( { model | activity_import_state = ActivityImportStateDataInput show_settings sep m }, Cmd.map MsgFileInputImport c )

                _ ->
                    ( model, Cmd.none )

        ( MsgOnClickActivitiesImport, FetchDone course _ ) ->
            case model.activity_import_state of
                ActivityImportStateDataInput _ _ _ ->
                    ( model, Cmd.none )

                ActivityImportStateValidationFinished sep csv_data _ ->
                    case course.id of
                        Just cid ->
                            ( { model
                                | activity_import_state = ActivityImportStateInProgress
                              }
                            , activityImportForCourse { data = csv_data, sep = String.cons sep "", courseId = cid }
                                |> ext_task identity model.token []
                                |> Task.mapError httpErrorToString
                                |> Task.attempt MsgActivitiesImportFinished
                            )

                        _ ->
                            ( model, Cmd.none )

                ActivityImportStateFinished _ ->
                    ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ( MsgActivitiesImportFinished res, _ ) ->
            ( { model
                | activity_import_state =
                    ActivityImportStateFinished <|
                        Result.map
                            (\v ->
                                "Записей создано: " ++ (String.fromInt <| List.length v.objects)
                            )
                            res
              }
            , Cmd.none
            )

        ( MsgActivityImportGotCSVData sep data, _ ) ->
            let
                val_res =
                    validateActivityCSV sep data

                res =
                    case val_res of
                        [] ->
                            Ok ()

                        _ ->
                            Err val_res
            in
            ( { model | activity_import_state = ActivityImportStateValidationFinished sep data res }, Cmd.none )

        ( MsgOnInputActivityCSVSep sep, _ ) ->
            case model.activity_import_state of
                ActivityImportStateDataInput show_settings _ m ->
                    ( { model | activity_import_state = ActivityImportStateDataInput show_settings sep m }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ( MsgOnClickToggleActivityImportSettings, _ ) ->
            case model.activity_import_state of
                ActivityImportStateDataInput show_settings sep m ->
                    ( { model | activity_import_state = ActivityImportStateDataInput (not show_settings) sep m }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )


viewActValidationIssue : ActivityCSVValidationIssue -> Html Msg
viewActValidationIssue issue =
    let
        icon =
            case issue.kind of
                IssueKindWarning ->
                    i [ class "exclamation triangle icon", style "color" "#fbbd08" ] []

                IssueKindError ->
                    i [ class "minus circle icon", style "color" "#db2828" ] []

                IssueKindNotice ->
                    i [ class "info icon", style "color" "#2185d0" ] []

        kindStr =
            case issue.kind of
                IssueKindWarning ->
                    "Предупреждение"

                IssueKindError ->
                    "Ошибка"

                IssueKindNotice ->
                    "Замечание"

        row =
            div [ class "ml-10" ]
                [ div [ style "font-size" "8pt", style "color" "#999" ] [ text "Строка" ]
                , div [] [ text <| Maybe.withDefault "-" <| Maybe.map String.fromInt issue.row ]
                ]

        col =
            div [ class "ml-10" ]
                [ div [ style "font-size" "8pt", style "color" "#999" ] [ text "Столбец" ]
                , div [] [ text <| Maybe.withDefault "-" <| Maybe.map String.fromInt issue.col ]
                ]

        msg =
            div [ class "ml-10 col-xs start-xs" ]
                [ div [ style "font-size" "8pt", style "color" "#999" ] [ text kindStr ]
                , div [] [ text issue.msg ]
                ]
    in
    div [ class "row center-xs middle-xs ui segment" ]
        [ icon
        , row
        , col
        , msg
        ]


viewActivitiesImport : Model -> Html Msg
viewActivitiesImport model =
    let
        form state =
            div []
                [ p []
                    [ text "Перед началом импорта убедитесь, что ваш файл с темами сохранен в формате "
                    , strong [] [ text "CSV UTF-8" ]
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
                , p []
                    [ text <|
                        "Все перечисленные выше поля обязательны и должны присутствовать в вашем файле в неизменном"
                            ++ " значении (без лишних пробелов и переводов строк). Скачать шаблон такого файла можно по "
                    , a [ href "/template_activities.csv", target "_blank" ] [ text "ссылке" ]
                    , text "."
                    ]
                , p []
                    [ text <|
                        "Убедившись, что ваш файл соответствует указанному выше формату, укажите его в поле ниже и отправьте на сервер. "
                            ++ "По завершению процесса импорта вы увидите результат (успех, ошибка). В случае возникновения ошибок, убедитесь,"
                            ++ " что ваш файл сохранен в кодировке UTF-8. При сохранении файла в Excel, возможно, потребуется указать другой разделитель"
                            ++ " - например, точка с запятой (см. настройки)."
                    ]
                , state
                ]
    in
    case model.activity_import_state of
        ActivityImportStateDataInput show_settings sep m ->
            form <|
                div []
                    [ div [ class "row between-xs" ]
                        [ h3 [] [ text "Настройки импорта" ]
                        , button [ class "ui button", onClick MsgOnClickToggleActivityImportSettings ]
                            [ i [ class "cog icon" ] []
                            , text "Настройки"
                            ]
                        ]
                    , div [ class "row center-xs" ]
                        [ div [ class "col" ]
                            [ div
                                [ class "row"
                                , style "display"
                                    (if show_settings then
                                        "initial"

                                     else
                                        "none"
                                    )
                                ]
                                [ div [ class "ui input middle-xs mb-10" ]
                                    [ label [ class "mr-10" ] [ text "Разделитель: " ]
                                    , input [ class "", type_ "text", placeholder "Разделитель", value sep, onInput MsgOnInputActivityCSVSep ] []
                                    ]
                                ]
                            , div [ class "row center-xs", style "display" "block", style "min-width" "300px" ]
                                [ Html.map
                                    MsgFileInputImport
                                  <|
                                    FI.view m
                                ]
                            ]
                        ]
                    ]

        ActivityImportStateNone ->
            text ""

        ActivityImportStateInProgress ->
            form <|
                div [ class "row center-xs" ]
                    [ div [ class "col", style "display" "inline-block" ]
                        [ MessageBox.view
                            MessageBox.None
                            True
                            Nothing
                            (text "")
                            (text "Выполняется импорт")
                        ]
                    ]

        ActivityImportStateFinished res ->
            case res of
                Ok msg ->
                    form <|
                        div [ class "row center-xs" ]
                            [ div [ class "col", style "display" "inline-block" ]
                                [ MessageBox.view
                                    MessageBox.Success
                                    False
                                    Nothing
                                    (text "")
                                    (text <| "Импорт успешно завершен: " ++ msg)
                                ]
                            ]

                Err err ->
                    form <|
                        div [ class "row center-xs" ]
                            [ div [ class "col", style "display" "inline-block" ]
                                [ MessageBox.view
                                    MessageBox.Error
                                    False
                                    Nothing
                                    (text "")
                                  <|
                                    div []
                                        [ div [] [ text "Импорт выполнен с ошибкой: " ]
                                        , div [ class "ml-10" ] [ text err ]
                                        ]
                                , button [ class "ui button primary", onClick MsgOnClickImportActivities ]
                                    [ i [ class "undo icon" ] []
                                    , text "Начать сначала"
                                    ]
                                ]
                            ]

        ActivityImportStateValidationInProgress ->
            form <|
                div [ class "row center-xs" ]
                    [ div [ class "col", style "display" "inline-block" ]
                        [ MessageBox.view
                            MessageBox.None
                            True
                            Nothing
                            (text "")
                            (text <| "Проводим предварительную проверку вашего файла...")
                        ]
                    ]

        ActivityImportStateValidationFinished _ _ result ->
            let
                cont color_class =
                    button [ class <| "ui button " ++ color_class, onClick MsgOnClickActivitiesImport ] [ i [ class "play icon" ] [], text "Продолжить импорт" ]

                restart =
                    button [ class "ui button primary", onClick MsgOnClickImportActivities ]
                        [ i [ class "undo icon" ] []
                        , text "Начать сначала"
                        ]

                succ =
                    form <|
                        div [ class "row center-xs" ]
                            [ div [ class "col", style "display" "inline-block" ]
                                [ MessageBox.view
                                    MessageBox.Success
                                    False
                                    Nothing
                                    (text "")
                                    (text <| "Предварительная проверка завершена. Проблем не найдено.")
                                , div [ class "mt-10" ] [ cont "green" ]
                                ]
                            ]
            in
            case result of
                Ok _ ->
                    succ

                Err data ->
                    let
                        valKindToInt kind =
                            case kind of
                                IssueKindWarning ->
                                    1

                                IssueKindError ->
                                    0

                                IssueKindNotice ->
                                    2

                        sorted =
                            List.sortBy (.kind >> valKindToInt) data
                    in
                    case sorted of
                        [] ->
                            succ

                        hd :: _ ->
                            let
                                canContinue =
                                    hd.kind /= IssueKindError
                            in
                            form <|
                                div [ class "row center-xs" ]
                                    [ div [ class "col", style "display" "inline-block" ]
                                        [ MessageBox.view
                                            (if canContinue then
                                                MessageBox.Warning

                                             else
                                                MessageBox.Error
                                            )
                                            False
                                            Nothing
                                            (text "")
                                            (text <|
                                                if canContinue then
                                                    "Были найдены некоторые проблемы в ваших данных. "
                                                        ++ "Рекомендуется ознакомиться с их списком ниже и исправить недочеты. "
                                                        ++ "Тем не менее, вы можете продолжить загрузку без исправления."

                                                else
                                                    "Были найдены серьезные ошибки в вашем файле. Для продолжения необходимо "
                                                        ++ "вначале исправить все ошибки и, желательно, все остальные недостатки."
                                            )
                                        , div []
                                            [ restart
                                            , if canContinue then
                                                cont "yellow"

                                              else
                                                text ""
                                            ]
                                        , h3 [] [ text <| "Список найденных проблем (" ++ String.fromInt (List.length sorted) ++ "):" ]
                                        , div [] <| List.map viewActValidationIssue sorted
                                        ]
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
                        [ div [ class "col-xs-12 mb-5" ]
                            [ div
                                [ style "min-width" "100px"
                                , style "display" "inline-block"
                                , style "text-align" "right"
                                , class "mr-10"
                                , style "flex-wrap" "nowrap"
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
                            , button [ class "ui button green", onClick MsgOnClickAddTsk ]
                                [ i [ class "plus icon" ] []
                                , text "Задание"
                                ]
                            , button [ class "ui button green", onClick MsgOnClickAddTxt ]
                                [ i [ class "plus icon" ] []
                                , text "Материал"
                                ]
                            ]
                        , div [ class "col-xs-12 start-xs mb-5" ]
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
                EditOn m _ ->
                    case m of
                        AddGen ->
                            base "Добавить тему здесь"

                        AddFin ->
                            base "Добавить контроль здесь"

                        AddNone ->
                            text ""

                        AddTsk ->
                            base "Добавить задание здесь"

                        AddTxt ->
                            base "Добавить материал здесь"

                EditOff ->
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

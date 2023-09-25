module Page.Course.CoursePage exposing (..)

import Api exposing (ext_task)
import Api.Data exposing (Activity, ActivityContentType(..), Course, CourseEnrollmentRead, CourseEnrollmentReadRole(..), EducationSpecialization, ImportForCourseResult, UserDeep)
import Api.Request.Activity exposing (activityImportForCourse, activityList)
import Api.Request.Course exposing (courseEnrollmentList, courseRead)
import Api.Request.Education exposing (educationSpecializationList)
import Component.Activity as CA
import Component.MessageBox as MessageBox exposing (Type(..))
import Component.Modal as Modal
import Component.MultiTask as MultiTask exposing (Msg(..))
import Component.UI.Breadcrumb as Breadcrumb
import Component.UI.Common exposing (Action(..))
import Component.UI.FileInput as FI
import Csv.Parser
import File
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error(..))
import List
import Page.Course.CourseHeader as Header
import Page.Course.CourseMembers as CourseMembers
import Set
import String
import Task
import Time exposing (Posix)
import Util exposing (assoc_update, get_id_str, httpErrorToString, list_insert_at, zip)
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


type alias FetchedData =
    { course : Course
    , spec : Maybe EducationSpecialization
    , enrollments : List CourseEnrollmentRead
    , activities : List Activity
    }


type State
    = Fetching (MultiTask.Model Http.Error FetchResult)
    | FetchDone FetchedData (List ( Int, CA.Model )) CourseMembers.Model Header.Model
    | FetchFailed String


type Msg
    = MsgFetch (MultiTask.Msg Http.Error FetchResult)
    | MsgClickMembers
    | MsgCloseMembers
    | MsgCloseActivitiesImport
    | MsgOnClickImportActivities
    | MsgOnClickAddGen
    | MsgOnClickAddFin
    | MsgOnClickAddTsk
    | MsgOnClickAddTxt
    | MsgOnClickAddBefore Int (Maybe Posix)
    | MsgActivity Int CA.Msg
    | MsgActivityClicked Int
    | MsgFileInputImport FI.Msg
    | MsgOnInputActivityCSVSep String
    | MsgOnClickActivitiesImport
    | MsgActivitiesImportFinished (Result String ImportForCourseResult)
    | MsgActivityImportGotCSVData Char String
    | MsgOnClickToggleActivityImportSettings
    | MsgOnInputActivityPrimitiveImport String
    | MsgOnClickActivityPrimitiveImport
    | MsgOnClickOpenPrimitiveActImport
    | MsgCloseActivitiesImportPrimitive
    | MsgCourseMembers CourseMembers.Msg
    | MsgHeader Header.Msg
    | MsgDoReloadCourse


type FetchResult
    = FetchedCourse Course
    | FetchedEnrollments (List CourseEnrollmentRead)
    | FetchedActivities (List Activity)
    | FetchedSpec (List EducationSpecialization)


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
    , is_staff : Bool
    , teaching_here : Bool
    , managing_here : Bool
    , observing_here : Bool
    , activity_component_pk : Int
    , activity_import_state : ActivityImportState
    , activity_primitive_import : Maybe String
    }


showFetchResult : FetchResult -> String
showFetchResult _ =
    "OK"


init : String -> String -> UserDeep -> ( Model, Cmd Msg )
init token course_id user =
    let
        ( m, c ) =
            MultiTask.init
                [ ( ext_task FetchedCourse token [] <| courseRead course_id
                  , "Получение данных о курсе"
                  )
                , ( ext_task FetchedSpec token [ ( "courses", course_id ) ] educationSpecializationList
                  , "Получение направления обучения"
                  )
                , ( ext_task FetchedEnrollments token [ ( "course", course_id ), ( "finished_on__isnull", "True" ) ] <| courseEnrollmentList
                  , "Получение данных об участниках"
                  )
                , ( ext_task FetchedActivities token [ ( "course", course_id ) ] activityList
                  , "Получение тем занятий"
                  )
                ]
    in
    ( { state = Fetching m
      , token = token
      , user = user
      , show_members = False
      , edit_mode = EditOff
      , is_staff =
            not <|
                Set.isEmpty <|
                    Set.intersect (Set.fromList <| Maybe.withDefault [] user.roles) (Set.fromList [ "admin", "staff" ])
      , teaching_here = False
      , managing_here = False
      , observing_here = False
      , activity_component_pk = 0
      , activity_import_state = ActivityImportStateNone
      , activity_primitive_import = Nothing
      }
    , Cmd.map MsgFetch c
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.state of
        FetchDone _ id_comps model_members model_header ->
            let
                subs_act =
                    List.map (\( k, v ) -> Sub.map (MsgActivity k) <| CA.subscriptions v) id_comps

                sub_header =
                    Sub.map MsgHeader <| Header.subscribtions model_header

                sub_members =
                    Sub.map MsgCourseMembers <| CourseMembers.subscriptions model_members
            in
            Sub.batch <| subs_act ++ [ sub_header, sub_members ]

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
        FetchDone c acts model_members model_header ->
            { model
                | state =
                    FetchDone c (fixOrder_ 0 acts) model_members model_header
            }

        _ ->
            model


activityMoveUp id acts =
    case acts of
        (( k1, v1 ) as x) :: (( k2, v2 ) as y) :: tl ->
            if k2 == id then
                ( k2, CA.setOrder (CA.getOrder v2 - 1) v2 ) :: ( k1, CA.setOrder (CA.getOrder v1 + 1) v1 ) :: tl

            else
                x :: activityMoveUp id (y :: tl)

        _ ->
            acts


activityMoveDown id acts =
    case acts of
        (( k1, v1 ) as x) :: (( k2, v2 ) as y) :: tl ->
            if k1 == id then
                ( k2, CA.setOrder (CA.getOrder v2 - 1) v2 ) :: ( k1, CA.setOrder (CA.getOrder v1 + 1) v1 ) :: tl

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
                FetchDone course acts model_members model_header ->
                    FetchDone course (List.map (\( k, v ) -> ( k, CA.setEditable edt v )) acts) model_members model_header

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
            Csv.Parser.parse { fieldSeparator = sep } data

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
                                  , msg = "Лишние пробелы в ячейке (в начале или конце)"
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

                                    else if String.length tv > 255 then
                                        [ { kind = IssueKindError
                                          , row = Just row_num
                                          , col = Just i
                                          , msg = "Ключевое слово слишком длинное (>255 символов)"
                                          }
                                        ]

                                    else
                                        []

                                "Раздел" ->
                                    if String.length tv > 255 then
                                        [ { kind = IssueKindError
                                          , row = Just row_num
                                          , col = Just i
                                          , msg = "Название раздела слишком длинное (>255 символов)"
                                          }
                                        ]

                                    else
                                        emptyValue

                                "ФГОС" ->
                                    if List.member (String.toLower tv) [ "да", "нет" ] then
                                        []

                                    else
                                        [ { kind = IssueKindWarning
                                          , row = Just row_num
                                          , col = Just i
                                          , msg = "Значение должно быть одно из: Да, Нет; По умолчанию выбирается 'Нет'. Ваше значение: '" ++ v ++ "'"
                                          }
                                        ]

                                "Раздел научной дисциплины" ->
                                    if String.length tv > 255 then
                                        [ { kind = IssueKindError
                                          , row = Just row_num
                                          , col = Just i
                                          , msg = "Название научной дисциплины слишком длинное (>255 символов)"
                                          }
                                        ]

                                    else
                                        emptyValue

                                "Форма занятия" ->
                                    if String.length tv > 255 then
                                        [ { kind = IssueKindError
                                          , row = Just row_num
                                          , col = Just i
                                          , msg = "Название формы занятия дисциплины слишком длинное (>255 символов)"
                                          }
                                        ]

                                    else
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
            if List.all ((==) "") <| List.map String.trim fields then
                [ { kind = IssueKindWarning
                  , row = Just row_num
                  , col = Nothing
                  , msg = "Пустая строка"
                  }
                ]

            else
                List.concat <|
                    List.map3
                        validateCell
                        (List.range 1 (List.length fields))
                        header
                        fields
    in
    case parsed of
        Ok res ->
            case res of
                [] ->
                    [ { kind = IssueKindNotice
                      , row = Nothing
                      , col = Nothing
                      , msg =
                            "Нет данных для импорта."
                      }
                    ]

                header :: rows ->
                    let
                        headerErrors =
                            validateHeaderRow header

                        trimmedHeader =
                            List.map String.trim header
                    in
                    if hasErrors headerErrors then
                        headerErrors

                    else
                        case rows of
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
                                        List.indexedMap (\i -> validateBodyRow (i + 2) trimmedHeader) rows
                                in
                                headerErrors ++ List.concat bodyErrors

        Err e ->
            case e of
                Csv.Parser.SourceEndedWithoutClosingQuote p ->
                    [ { kind = IssueKindError
                      , row = Nothing
                      , col = Nothing
                      , msg =
                            "Ошибка около символа " ++ String.fromInt p ++ ": Экранирование начато, но не знавершено"
                      }
                    ]

                Csv.Parser.AdditionalCharactersAfterClosingQuote p ->
                    [ { kind = IssueKindError
                      , row = Nothing
                      , col = Nothing
                      , msg =
                            "Ошибка около символа " ++ String.fromInt p ++ ": Обнаружены данные после завершенного экранирования."
                      }
                    ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        parse_course : FetchedData -> ( Model, Cmd Msg )
        parse_course ({ course, spec, enrollments, activities } as data) =
            let
                activities_ =
                    List.sortBy .order activities

                ( ms, cs ) =
                    List.unzip <| List.map (CA.init_from_activity model.token) activities_

                len =
                    List.length ms

                id_range =
                    List.range model.activity_component_pk (model.activity_component_pk + len - 1)

                pairs_id_comp =
                    zip id_range ms

                pairs_id_cmd =
                    zip id_range cs

                cmdsAct =
                    List.map (\( id, c_ ) -> Cmd.map (MsgActivity id) c_) pairs_id_cmd

                teaching_here =
                    List.any
                        (\enr ->
                            enr.role == CourseEnrollmentReadRoleT && enr.person.id == model.user.id
                        )
                        enrollments

                managing_here =
                    List.any
                        (\enr ->
                            enr.role == CourseEnrollmentReadRoleM && enr.person.id == model.user.id
                        )
                        enrollments

                observing_here =
                    List.any
                        (\enr ->
                            enr.role == CourseEnrollmentReadRoleO && enr.person.id == model.user.id
                        )
                        enrollments

                ( mMembers, cMembers ) =
                    CourseMembers.init model.token course.id enrollments teaching_here (model.is_staff || managing_here)

                ( mHeader, cHeader ) =
                    Header.init model.token
                        (teaching_here || (model.is_staff || managing_here))
                        { course = Just course
                        , teachers = Just <| List.filter (.role >> (==) CourseEnrollmentReadRoleT) enrollments
                        , specs = Nothing
                        }
            in
            ( { model
                | state =
                    FetchDone data pairs_id_comp mMembers mHeader
                , activity_component_pk = model.activity_component_pk + len
                , teaching_here = teaching_here
                , managing_here = managing_here
                , observing_here = observing_here
              }
            , Cmd.batch (cmdsAct ++ [ Cmd.map MsgCourseMembers cMembers, Cmd.map MsgHeader cHeader ])
            )
    in
    case ( msg, model.state ) of
        ( MsgFetch msg_, Fetching model_ ) ->
            let
                ( m, c ) =
                    MultiTask.update msg_ model_
            in
            case msg_ of
                TaskFinishedAll [ Ok (FetchedCourse course), Ok (FetchedSpec spec), Ok (FetchedEnrollments enrollments), Ok (FetchedActivities activities) ] ->
                    parse_course
                        { course = course
                        , spec = List.head <| List.filter (.id >> (==) course.forSpecialization) spec
                        , enrollments = enrollments
                        , activities = activities
                        }

                _ ->
                    ( { model | state = Fetching m }, Cmd.map MsgFetch c )

        ( MsgClickMembers, _ ) ->
            ( { model | show_members = True }, Cmd.none )

        ( MsgCloseMembers, _ ) ->
            ( { model | show_members = False }, Cmd.none )

        ( MsgActivity id msg_, FetchDone course act_components model_members model_header ) ->
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
                                                FetchDone
                                                    course
                                                    (activityMoveUp id <|
                                                        assoc_update id m act_components
                                                    )
                                                    model_members
                                                    model_header
                                        }
                                    , Cmd.batch [ Cmd.map (MsgActivity id) c, CA.doScrollInto m ]
                                    )

                                CA.MsgMoveDown ->
                                    ( fixOrder
                                        { model
                                            | state =
                                                FetchDone course
                                                    (activityMoveDown id <|
                                                        assoc_update id m act_components
                                                    )
                                                    model_members
                                                    model_header
                                        }
                                    , Cmd.batch [ Cmd.map (MsgActivity id) c, CA.doScrollInto m ]
                                    )

                                CA.MsgActivityDeleteDone (Ok _) ->
                                    ( fixOrder
                                        { model
                                            | state =
                                                FetchDone
                                                    course
                                                    (List.filter (Tuple.first >> (/=) id) act_components)
                                                    model_members
                                                    model_header
                                        }
                                    , Cmd.none
                                    )

                                _ ->
                                    ( { model
                                        | state =
                                            FetchDone course
                                                (assoc_update id m act_components)
                                                model_members
                                                model_header
                                      }
                                    , Cmd.map (MsgActivity id) c
                                    )
                    in
                    ( setModified True new_model, cmd )

                Nothing ->
                    ( model, Cmd.none )

        ( MsgActivityClicked id, FetchDone course act_components model_members model_header ) ->
            if model.teaching_here || model.managing_here || model.is_staff then
                let
                    acts =
                        List.map
                            (\( id2, act ) ->
                                if id2 == id then
                                    ( id2, CA.setEditable True act )

                                else
                                    ( id2, act )
                            )
                            act_components
                in
                ( { model | state = FetchDone course acts model_members model_header }, Cmd.none )

            else
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

        ( MsgOnClickAddBefore i (Just t), FetchDone ({ course, spec, enrollments, activities } as data) act_components model_members model_header ) ->
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
                                , weight = Just 1
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
                                , weight = Just 1
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
                                , weight = Just 1
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
                                , weight = Just 1
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
                                    FetchDone data
                                        (list_insert_at
                                            i
                                            ( model.activity_component_pk, CA.setEditable True <| CA.revalidate m )
                                            act_components
                                        )
                                        model_members
                                        model_header
                            }
                    , Cmd.map (MsgActivity model.activity_component_pk) c
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

        ( MsgOnClickActivitiesImport, FetchDone ({ course, spec, enrollments, activities } as data) _ _ _ ) ->
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

        ( MsgOnInputActivityPrimitiveImport v, _ ) ->
            ( { model | activity_primitive_import = Just v }, Cmd.none )

        ( MsgOnClickActivityPrimitiveImport, FetchDone ({ course, spec, enrollments, activities } as data) la model_members model_header ) ->
            let
                new_act : Int -> String -> Maybe Activity
                new_act i t =
                    Maybe.map
                        (\cid ->
                            { id = Nothing
                            , createdAt = Nothing
                            , updatedAt = Nothing
                            , title = t
                            , lessonType = Nothing
                            , keywords = Nothing
                            , isHidden = Just False
                            , marksLimit = Just 2
                            , hours = Just 1
                            , fgosComplient = Just False
                            , order = i
                            , date = Nothing
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
                            , weight = Just 1
                            }
                        )
                        course.id

                topics =
                    List.filter ((/=) "") <|
                        List.map String.trim <|
                            String.lines <|
                                Maybe.withDefault "" <|
                                    model.activity_primitive_import

                maxOrder =
                    Maybe.withDefault 0 <| List.maximum <| List.map (Tuple.second >> CA.getOrder) la

                lenTopics =
                    List.length topics

                listOrder =
                    List.range (maxOrder + 1) (maxOrder + lenTopics)

                listPK =
                    List.range model.activity_component_pk (model.activity_component_pk + lenTopics - 1)

                ( lm, lc ) =
                    List.unzip <|
                        List.filterMap identity <|
                            List.map2
                                (\i t -> Maybe.map (CA.init_from_activity model.token) <| new_act i t)
                                listOrder
                                topics
            in
            ( { model
                | state = FetchDone data (la ++ zip listPK (List.map (CA.setEditable True) lm)) model_members model_header
                , activity_component_pk = model.activity_component_pk + lenTopics
                , activity_primitive_import = Nothing
              }
            , Cmd.batch <| List.map2 (\k c_ -> Cmd.map (MsgActivity k) c_) listPK lc
            )

        ( MsgOnClickOpenPrimitiveActImport, _ ) ->
            ( { model | activity_primitive_import = Just "" }, Cmd.none )

        ( MsgCloseActivitiesImportPrimitive, _ ) ->
            ( { model | activity_primitive_import = Nothing }, Cmd.none )

        ( MsgCourseMembers msg_, FetchDone course la model_members model_header ) ->
            let
                ( m, c ) =
                    CourseMembers.update msg_ model_members
            in
            case msg_ of
                CourseMembers.MsgEnrolling (TaskFinishedAll results) ->
                    ( model
                    , if List.all (Result.toMaybe >> (/=) Nothing) results then
                        Task.perform (\_ -> MsgDoReloadCourse) <| Task.succeed ()

                      else
                        Cmd.none
                    )

                _ ->
                    ( { model | state = FetchDone course la m model_header }, Cmd.map MsgCourseMembers c )

        ( MsgHeader msg_, FetchDone course la model_members model_header ) ->
            let
                ( m, c ) =
                    Header.update msg_ model_header
            in
            ( { model | state = FetchDone course la model_members m }, Cmd.map MsgHeader c )

        ( MsgDoReloadCourse, FetchDone course la model_members model_header ) ->
            ( model, Cmd.none )

        -- TODO
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


viewPrimitiveImport : Model -> Html Msg
viewPrimitiveImport model =
    div []
        [ p []
            [ text "Данная форма предназначена для быстрого создания тем из списка. Темы создаются со следующими параметрами:"
            ]
        , ul []
            [ li [] [ strong [] [ text "Тип" ], text " - тема" ]
            , li [] [ strong [] [ text "Номер" ], text " - автоматически увеличивающийся, начиная с последнего существующего." ]
            , li [] [ strong [] [ text "Дата" ], text " - не задана" ]
            , li [] [ strong [] [ text "Тема" ], text " - название темы" ]
            , li [] [ strong [] [ text "Ключевое слово" ], text " - не задано" ]
            , li [] [ strong [] [ text "Раздел" ], text " - не задано" ]
            , li [] [ strong [] [ text "ФГОС" ], text " - Нет" ]
            , li [] [ strong [] [ text "Раздел научной дисциплины" ], text " - не задано" ]
            , li [] [ strong [] [ text "Форма занятия" ], text " - не задано" ]
            , li [] [ strong [] [ text "Материалы урока" ], text " - не задано" ]
            , li [] [ strong [] [ text "Домашнее задание" ], text " - не задано" ]
            , li [] [ strong [] [ text "Количество оценок" ], text " - 2" ]
            , li [] [ strong [] [ text "Часы" ], text " - 1" ]
            ]
        , p []
            [ text "Введите список тем в поле ниже - по одной теме на строку. Пустые строки будут проигнорированы. Не забудьте "
            , strong [] [ text "сохранить " ]
            , text "изменения на странице курса."
            ]
        , div [ class "row center-xs" ]
            [ div [ class "col-xs-12 center-xs" ]
                [ div [ class "row ui form field" ]
                    [ textarea
                        [ value <| Maybe.withDefault "" model.activity_primitive_import
                        , onInput MsgOnInputActivityPrimitiveImport
                        , rows 20
                        ]
                        []
                    ]
                , div [ class "row center-xs mt-10" ]
                    [ button [ class "ui button green", onClick MsgOnClickActivityPrimitiveImport ]
                        [ i [ class "plus icon" ] []
                        , text "Добавить"
                        ]
                    ]
                ]
            ]
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
                        [ h3 [] [ text "Данные импорта" ]
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
                                , button [ class "ui button primary", onClick MsgOnClickImportActivities ]
                                    [ i [ class "undo icon" ] []
                                    , text "Начать сначала"
                                    ]
                                , button [ class "ui button green", onClick MsgDoReloadCourse ]
                                    [ text "Перезагрузить курс"
                                    ]
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


viewCourse : FetchedData -> List ( Int, CA.Model ) -> CourseMembers.Model -> Header.Model -> Model -> Html Msg
viewCourse data components_activity members_model header_model model =
    let
        breadcrumbs =
            Breadcrumb.view
                [ { label = "Главная", onClick = Just (ActionGotoLink "/"), icon = Nothing }
                , { label = "Предметы", onClick = Just (ActionGotoLink "/courses"), icon = Nothing }
                , { label = data.course.title, onClick = Nothing, icon = Nothing }
                ]

        header =
            Html.map MsgHeader <|
                Header.view header_model

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
                                , text "CSV КТП"
                                ]
                            , button [ class "ui button green", onClick MsgOnClickOpenPrimitiveActImport ]
                                [ i [ class "bars icon" ] []
                                , text "Список тем"
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
                                [ div [ onClick (MsgActivityClicked id) ] [ CA.view comp |> Html.map (MsgActivity id) ]
                                , add_activity_placeholder (i + 1)
                                ]
                            )
                            l

        modal_members do_show =
            Modal.view
                "members"
                "Участники"
                (Html.map MsgCourseMembers <| CourseMembers.view members_model)
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
                        "Импорт тем (КТП)"
                        (viewActivitiesImport model)
                        MsgCloseActivitiesImport
                        [ ( "Закрыть", MsgCloseActivitiesImport ) ]
                        True

        modal_activities_import_primitive =
            case model.activity_primitive_import of
                Just _ ->
                    Modal.view
                        "activities_import_primitive"
                        "Импорт тем (список)"
                        (viewPrimitiveImport model)
                        MsgCloseActivitiesImportPrimitive
                        [ ( "Закрыть", MsgCloseActivitiesImportPrimitive ) ]
                        True

                _ ->
                    text ""

        activities_title =
            h1 [ class "row between-xs ml-10 mr-10" ]
                [ text "Содержание"
                , div []
                    [ if model.is_staff || model.teaching_here || model.managing_here || model.observing_here then
                        a [ href <| "/marks/course/" ++ get_id_str data.course ]
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
        , modal_activities_import_primitive
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

        FetchDone data components_activity members_model header_model ->
            viewCourse data components_activity members_model header_model model

        FetchFailed err ->
            MessageBox.view Error False Nothing (text "Ошибка") (text <| "Не удалось получить данные курса: " ++ err)

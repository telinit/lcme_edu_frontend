module Component.MarkTable exposing (..)

import Api exposing (ext_task)
import Api.Data as Data exposing (..)
import Api.Request.Activity exposing (activityList)
import Api.Request.Course exposing (courseEnrollmentList, courseList, courseRead)
import Api.Request.Mark exposing (markCreate, markDelete, markList, markPartialUpdate)
import Browser.Dom exposing (Error(..), focus)
import Component.Misc exposing (checkbox, user_link)
import Component.Modal as Modal
import Component.MultiTask as MultiTask exposing (Msg(..))
import Component.Select as Select
import Dict as D exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (attribute, autofocus, checked, class, href, id, style, tabindex, type_, value)
import Html.Events exposing (on, onCheck, onClick)
import Http
import Json.Decode as JD
import List as L
import Maybe as M
import Page.CourseListPage exposing (empty_to_nothing)
import Set
import Task
import Time as T exposing (Posix, Zone, millisToPosix, utc)
import Util exposing (Either, dictFromTupleListMany, dictGroupBy, eitherGetRight, finalTypeToStr, get_id_str, httpErrorToString, index_by, listDropWhile, listSplitWhile, listTailWithEmpty, listTakeWhile, maybeToList, posixToDDMMYYYY, resultIsOK, user_full_name, zip)
import Uuid exposing (Uuid)


type Column
    = Activity Data.Activity
    | Date (Maybe Posix)


type Row
    = User Data.UserShallow
    | Course Data.Course


type alias ActivityID =
    Uuid


type alias StudentID =
    Uuid


type alias MarkIndex =
    Dict ( String, String ) (List MarkSlot)


type alias IsSelected =
    Bool


type MarkSlot
    = SlotMark IsSelected Data.Mark
    | SlotVirtual IsSelected ActivityID StudentID


type Direction
    = Left
    | Right
    | Top
    | Bottom


type MarkCmd
    = CmdSetMark String
    | CmdDeleteMark
    | CmdMove Direction
    | CmdUnknown String


type DateFilter
    = DateFilterQ1
    | DateFilterQ2
    | DateFilterQ3
    | DateFilterQ4
    | DateFilterH1
    | DateFilterH2
    | DateFilterAll


type alias SlotList =
    List MarkSlot


type alias ColList =
    List SlotList


type alias RowList =
    List ColList


type FetchedDataEvent
    = FetchedMarks (List Mark)
    | FetchedCourseList (List Course)
    | FetchedCourse Course
    | FetchedActivities (List Activity)
    | FetchedEnrollments (List CourseEnrollmentRead)


type Msg
    = MsgFetch (MultiTask.Msg Http.Error FetchedDataEvent)
    | MsgMarkKeyPress MarkSlot Int Int MarkCmd
    | MsgMarkCreated ( Int, Int ) Mark
    | MsgMarkUpdated ( Int, Int ) Mark
    | MsgMarkDeleted ( Int, Int ) Uuid
    | MsgMarkSelected ( Int, Int )
    | MsgNop
    | MsgSelectSwitchCell Select.Msg
    | MsgMarkClicked (Maybe Mark) ( Int, Int )
    | MsgOnClickCloseMarkDetails
    | MsgSetDateFilter DateFilter
    | MsgOnCheckGroupByDate Bool


type State
    = StateLoading (MultiTask.Model Http.Error FetchedDataEvent)
    | StateComplete
    | StateError String


type Mode
    = MarksOfCourse
    | MarksOfStudent


type alias FetchedData =
    { courses : List Course
    , activities : List Activity
    , marks : List Mark
    , enrollments : List CourseEnrollmentRead
    }


type alias Model =
    { columns : List Column
    , rows : List Row
    , cells : List (List (List MarkSlot))
    , state : State
    , token : String
    , tz : Zone
    , student_id : Maybe Uuid
    , teacher_id : Maybe Uuid
    , size : ( Int, Int )
    , switchCell : Maybe Select.Model
    , selectedCoords : ( Int, Int )
    , canEdit : Bool
    , canViewDetails : Bool
    , showMarkDetails : Maybe Mark
    , dateFilter : DateFilter
    , mode : Mode
    , fetchedData : FetchedData
    , marksGroupByDate : Maybe Bool
    }


keyCodeToMarkCmd : String -> MarkCmd
keyCodeToMarkCmd code =
    case code of
        "ArrowLeft" ->
            CmdMove Left

        "ArrowUp" ->
            CmdMove Top

        "ArrowRight" ->
            CmdMove Right

        "ArrowDown" ->
            CmdMove Bottom

        "KeyA" ->
            CmdMove Left

        "KeyW" ->
            CmdMove Top

        "KeyD" ->
            CmdMove Right

        "KeyS" ->
            CmdMove Bottom

        "Digit0" ->
            CmdSetMark "0"

        "Digit1" ->
            CmdSetMark "1"

        "Digit2" ->
            CmdSetMark "2"

        "Digit3" ->
            CmdSetMark "3"

        "Digit4" ->
            CmdSetMark "4"

        "Digit5" ->
            CmdSetMark "5"

        "KeyY" ->
            CmdSetMark "н"

        "KeyP" ->
            CmdSetMark "зч"

        "BracketLeft" ->
            CmdSetMark "нз"

        "Minus" ->
            CmdSetMark "-"

        "Equal" ->
            CmdSetMark "+"

        "Delete" ->
            CmdDeleteMark

        _ ->
            CmdUnknown code


showFetchedData : FetchedDataEvent -> String
showFetchedData fetchedData =
    case fetchedData of
        FetchedMarks marks ->
            "Оценки: " ++ (String.fromInt <| List.length marks)

        FetchedCourseList courses ->
            "Курсы: " ++ (String.fromInt <| List.length courses)

        FetchedCourse course ->
            "Курс: " ++ course.title

        FetchedActivities activities ->
            "Активности: " ++ (String.fromInt <| List.length activities)

        FetchedEnrollments enr ->
            "Записи: " ++ (String.fromInt <| List.length enr)


doCreateMark : String -> Uuid -> Uuid -> Uuid -> ( Int, Int ) -> String -> Cmd Msg
doCreateMark token activity_id student_id author_id coords new_mark =
    let
        onResult res =
            case res of
                Ok r ->
                    MsgMarkCreated coords r

                Err _ ->
                    MsgNop
    in
    Task.attempt onResult <|
        ext_task identity token [] <|
            markCreate
                { value = new_mark
                , author = author_id
                , student = student_id
                , activity = activity_id
                , id = Nothing
                , comment = Nothing
                , createdAt = Nothing
                , updatedAt = Nothing
                }


doUpdateMark : String -> Mark -> ( Int, Int ) -> String -> Cmd Msg
doUpdateMark token old_mark coords new_mark =
    let
        onResult res =
            case res of
                Ok r ->
                    MsgMarkUpdated coords r

                Err _ ->
                    MsgNop
    in
    Maybe.withDefault Cmd.none <|
        Maybe.map
            (\id ->
                Task.attempt onResult <|
                    ext_task identity token [] <|
                        markPartialUpdate (Uuid.toString id)
                            { old_mark | value = new_mark }
            )
            old_mark.id


doDeleteMark : String -> Uuid -> ( Int, Int ) -> Cmd Msg
doDeleteMark token mark_id coords =
    let
        onResult res =
            case res of
                Ok r ->
                    MsgMarkDeleted coords mark_id

                Err _ ->
                    MsgNop
    in
    Task.attempt onResult <|
        ext_task identity token [] <|
            markDelete <|
                Uuid.toString mark_id


focusFirstCell : Model -> Cmd Msg
focusFirstCell model =
    case ( model.rows, model.columns ) of
        ( [], _ ) ->
            Cmd.none

        ( _, [] ) ->
            Cmd.none

        ( _, _ ) ->
            Task.attempt (\_ -> MsgNop) <| focus "slot-0-0"


initForStudent : String -> Uuid -> ( Model, Cmd Msg )
initForStudent token student_id =
    let
        ( m, c ) =
            MultiTask.init
                [ ( ext_task FetchedCourseList token [ ( "enrollments__person", Uuid.toString student_id ), ( "enrollments__role", "s" ) ] courseList
                  , "Получение данных о курсах"
                  )
                , ( ext_task FetchedActivities token [ ( "course__enrollments__person", Uuid.toString student_id ) ] activityList
                  , "Получение тем занятий"
                  )
                , ( ext_task FetchedMarks token [ ( "student", Uuid.toString student_id ) ] markList
                  , "Получение оценок"
                  )
                ]
    in
    ( { state = StateLoading m
      , token = token
      , rows = []
      , columns = []
      , cells = []
      , student_id = Just student_id
      , teacher_id = Nothing
      , size = ( 0, 0 )
      , tz = utc
      , switchCell = Nothing
      , selectedCoords = ( 0, 0 )
      , canViewDetails = True
      , canEdit = False
      , showMarkDetails = Nothing
      , dateFilter = DateFilterAll
      , mode = MarksOfStudent
      , fetchedData =
            { courses = []
            , activities = []
            , marks = []
            , enrollments = []
            }
      , marksGroupByDate = Just False
      }
    , Cmd.map MsgFetch c
    )


initForCourse : String -> Uuid -> Maybe Uuid -> ( Model, Cmd Msg )
initForCourse token course_id teacher_id =
    let
        ( m, c ) =
            MultiTask.init
                [ ( ext_task FetchedCourse token [] <| courseRead <| Uuid.toString course_id
                  , "Получение данных о курсе"
                  )
                , ( ext_task FetchedEnrollments token [ ( "course", Uuid.toString course_id ) ] <| courseEnrollmentList
                  , "Получение данных об участниках"
                  )
                , ( ext_task FetchedActivities token [ ( "course", Uuid.toString course_id ) ] activityList
                  , "Получение тем занятий"
                  )
                , ( ext_task FetchedMarks token [ ( "activity__course", Uuid.toString course_id ) ] markList
                  , "Получение оценок"
                  )
                ]

        ( sm, sc ) =
            Select.init "Автопереход" False <|
                D.fromList
                    [ ( "", "Не переходить" )
                    , ( "right", "Вправо" )
                    , ( "bottom", "Вниз" )
                    ]
    in
    ( { state = StateLoading m
      , token = token
      , rows = []
      , columns = []

      --, marks = D.empty
      , cells = []
      , student_id = Nothing
      , teacher_id = teacher_id
      , size = ( 0, 0 )
      , tz = utc
      , switchCell = Just sm
      , selectedCoords = ( 0, 0 )
      , canViewDetails = False
      , canEdit = True
      , showMarkDetails = Nothing
      , dateFilter = DateFilterAll
      , mode = MarksOfCourse
      , fetchedData =
            { courses = []
            , activities = []
            , marks = []
            , enrollments = []
            }
      , marksGroupByDate = Nothing
      }
    , Cmd.batch [ Cmd.map MsgFetch c, Cmd.map MsgSelectSwitchCell sc ]
    )


updateMark : Model -> ( Int, Int ) -> Either Uuid Mark -> Model
updateMark model ( cell_x, cell_y ) markIdOrRec =
    let
        update_slot : MarkSlot -> M.Maybe Mark -> MarkSlot
        update_slot slot mb_mark_ =
            case ( slot, mb_mark_ ) of
                ( SlotMark sel _, Just new_mark ) ->
                    SlotMark sel new_mark

                ( SlotMark sel old_mark, Nothing ) ->
                    SlotVirtual sel old_mark.activity old_mark.student

                ( SlotVirtual sel _ _, Just new_mark ) ->
                    SlotMark sel new_mark

                ( SlotVirtual _ _ _, Nothing ) ->
                    slot

        update_col : Int -> List MarkSlot -> Maybe Mark -> List MarkSlot
        update_col x col mb_mark_ =
            case ( x, col ) of
                ( 0, slot :: tl ) ->
                    update_slot slot mb_mark_ :: tl

                ( _, slot :: tl ) ->
                    slot :: update_col (x - 1) tl mb_mark_

                ( _, [] ) ->
                    []

        oldFetchedData : FetchedData
        oldFetchedData =
            model.fetchedData

        updateData marks =
            case markIdOrRec of
                Util.Left mid ->
                    List.filter (.id >> (/=) (Just mid)) marks

                Util.Right newMark ->
                    case marks of
                        [] ->
                            [ newMark ]

                        oldMark :: rest ->
                            if oldMark.id == newMark.id then
                                newMark :: rest

                            else
                                oldMark :: updateData rest
    in
    { model
        | cells =
            L.indexedMap
                (\y row ->
                    if y == cell_y then
                        Tuple.second <|
                            L.foldl
                                (\col ( slots_cnt, res ) ->
                                    let
                                        new_col =
                                            update_col (cell_x - slots_cnt) col <| eitherGetRight markIdOrRec
                                    in
                                    ( slots_cnt + L.length new_col, res ++ [ new_col ] )
                                )
                                ( 0, [] )
                                row

                    else
                        row
                )
                model.cells
        , fetchedData =
            { oldFetchedData
                | marks = updateData oldFetchedData.marks
            }
    }


focusCell x y =
    let
        onResult r =
            case r of
                Ok _ ->
                    MsgMarkSelected ( x, y )

                Err _ ->
                    MsgNop
    in
    Task.attempt onResult <| focus <| "slot-" ++ String.fromInt x ++ "-" ++ String.fromInt y


switchMarkCmd : Model -> Cmd Msg
switchMarkCmd model =
    let
        ( x, y ) =
            model.selectedCoords
    in
    case model.switchCell of
        Just sw ->
            case sw.selected of
                Just "right" ->
                    focusCell (x + 1) y

                Just "bottom" ->
                    focusCell x (y + 1)

                _ ->
                    Cmd.none

        _ ->
            Cmd.none


dateFilter : DateFilter -> List Activity -> List Activity
dateFilter filter orderSortedActs =
    case filter of
        DateFilterQ1 ->
            let
                ( l, r ) =
                    listSplitWhile (.finalType >> (/=) (Just ActivityFinalTypeQ1)) orderSortedActs
            in
            l ++ maybeToList (List.head r)

        DateFilterQ2 ->
            let
                ( l, r ) =
                    listSplitWhile (.finalType >> (/=) (Just ActivityFinalTypeQ2)) <|
                        List.drop 1 <|
                            listDropWhile (.finalType >> (/=) (Just ActivityFinalTypeQ1)) orderSortedActs
            in
            l ++ maybeToList (List.head r)

        DateFilterQ3 ->
            let
                ( l, r ) =
                    listSplitWhile (.finalType >> (/=) (Just ActivityFinalTypeQ3)) <|
                        List.drop 1 <|
                            listDropWhile (.finalType >> (/=) (Just ActivityFinalTypeQ2)) orderSortedActs
            in
            l ++ maybeToList (List.head r)

        DateFilterQ4 ->
            let
                ( l, r ) =
                    listSplitWhile (.finalType >> (/=) (Just ActivityFinalTypeQ4)) <|
                        List.drop 1 <|
                            listDropWhile (.finalType >> (/=) (Just ActivityFinalTypeQ3)) orderSortedActs
            in
            l ++ maybeToList (List.head r)

        DateFilterH1 ->
            let
                ( l, r ) =
                    listSplitWhile (.finalType >> (/=) (Just ActivityFinalTypeH1)) orderSortedActs
            in
            l ++ maybeToList (List.head r)

        DateFilterH2 ->
            let
                ( l, r ) =
                    listSplitWhile (.finalType >> (/=) (Just ActivityFinalTypeH2)) <|
                        List.drop 1 <|
                            listDropWhile (.finalType >> (/=) (Just ActivityFinalTypeH1)) orderSortedActs
            in
            l ++ maybeToList (List.head r)

        DateFilterAll ->
            orderSortedActs


updateTable : Model -> Model
updateTable model =
    case model.mode of
        MarksOfCourse ->
            let
                ix_acts =
                    index_by get_id_str activities

                rows =
                    L.filterMap
                        (\enr ->
                            if enr.role == CourseEnrollmentReadRoleS then
                                enr.person |> User |> Just

                            else
                                Nothing
                        )
                    <|
                        List.sortBy (.person >> user_full_name) model.fetchedData.enrollments

                columns =
                    L.map Activity <| L.sortBy .order activities

                activities =
                    dateFilter model.dateFilter <|
                        List.filter (\a -> 0 < Maybe.withDefault 0 a.marksLimit) model.fetchedData.activities

                mark_coords mark =
                    D.get (Uuid.toString mark.activity) ix_acts
                        |> M.andThen
                            (\act ->
                                Just
                                    ( mark
                                    , get_id_str act
                                    , Uuid.toString mark.student
                                    )
                            )

                marks_ix =
                    dictFromTupleListMany <|
                        L.map (\( a, b, c_ ) -> ( ( b, c_ ), SlotMark False a )) <|
                            L.filterMap mark_coords <|
                                L.sortBy (.createdAt >> M.map T.posixToMillis >> M.withDefault 0) model.fetchedData.marks

                cells =
                    L.map
                        (\row ->
                            L.map
                                (\col ->
                                    case ( row, col ) of
                                        ( User student, Activity act ) ->
                                            let
                                                coords =
                                                    ( get_id_str act, get_id_str student )

                                                mark_slots =
                                                    M.withDefault [] <| D.get coords marks_ix
                                            in
                                            case ( act.id, student.id ) of
                                                ( Just aid, Just sid ) ->
                                                    mark_slots
                                                        ++ L.repeat
                                                            (M.withDefault 0 act.marksLimit - L.length mark_slots)
                                                            (SlotVirtual False aid sid)

                                                _ ->
                                                    mark_slots

                                        ( _, _ ) ->
                                            []
                                )
                                columns
                        )
                        rows
            in
            { model
                | rows = rows
                , columns = columns
                , cells = cells
                , size =
                    ( M.withDefault 0 <|
                        L.maximum <|
                            L.map (\row -> L.sum <| L.map L.length row) cells
                    , L.length rows
                    )
            }

        MarksOfStudent ->
            let
                rows =
                    L.map Course <| List.sortBy .title model.fetchedData.courses

                existingActivityIDS =
                    Set.fromList <| List.map (.activity >> Uuid.toString) model.fetchedData.marks

                activities =
                    List.filter (\a -> Set.member (get_id_str a) existingActivityIDS) <|
                        L.concat <|
                            L.map (L.sortBy .order >> dateFilter model.dateFilter) <|
                                D.values <|
                                    dictGroupBy
                                        (.course >> Uuid.toString)
                                        model.fetchedData.activities

                ix_acts =
                    index_by get_id_str activities

                columns : List Column
                columns =
                    (if M.withDefault False <| model.marksGroupByDate then
                        L.map Date <|
                            L.map (Just << T.millisToPosix) <|
                                Set.toList <|
                                    Set.fromList <|
                                        L.filterMap (.date >> M.map T.posixToMillis) <|
                                            L.sortBy .order activities

                     else
                        []
                    )
                        ++ [ Date Nothing ]

                activity_course_id : Activity -> String
                activity_course_id act =
                    Uuid.toString act.course

                mark_coords : Mark -> Maybe ( Mark, String, String )
                mark_coords mark =
                    D.get (Uuid.toString mark.activity) ix_acts
                        |> M.map
                            (\act ->
                                ( mark
                                , if M.withDefault False <| model.marksGroupByDate then
                                    String.fromInt <| M.withDefault 0 <| M.map T.posixToMillis act.date

                                  else
                                    "0"
                                , activity_course_id act
                                )
                            )

                marks_ix : Dict ( String, String ) (List MarkSlot)
                marks_ix =
                    dictFromTupleListMany <|
                        L.map (\( mark, x, y ) -> ( ( x, y ), SlotMark False mark )) <|
                            L.filterMap mark_coords <|
                                L.sortBy
                                    (\m ->
                                        ( D.get (Uuid.toString m.activity) ix_acts |> M.map (.order >> (*) (-1)) |> M.withDefault 0
                                        , m.createdAt |> M.map T.posixToMillis |> M.withDefault 0
                                        )
                                    )
                                    model.fetchedData.marks

                cells : List (List (List MarkSlot))
                cells =
                    L.map
                        (\row ->
                            L.map
                                (\col ->
                                    case ( row, col ) of
                                        ( Course course, Date date ) ->
                                            let
                                                mark_slots =
                                                    M.withDefault [] <|
                                                        D.get
                                                            ( String.fromInt <|
                                                                M.withDefault 0 <|
                                                                    M.map T.posixToMillis date
                                                            , get_id_str course
                                                            )
                                                            marks_ix
                                            in
                                            mark_slots

                                        ( _, _ ) ->
                                            []
                                )
                                columns
                        )
                        rows
            in
            { model
                | rows = rows
                , columns = columns
                , cells = cells
                , size =
                    ( M.withDefault 0 <|
                        L.maximum <|
                            L.map (\row -> L.sum <| L.map L.length row) cells
                    , L.length rows
                    )
            }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        ignore =
            ( model, Cmd.none )
    in
    case ( msg, model.state ) of
        ( MsgFetch msg_, StateLoading model_ ) ->
            let
                ( m, c ) =
                    MultiTask.update msg_ model_
            in
            case ( msg_, model.student_id ) of
                ( TaskCompleted _ r, _ ) ->
                    let
                        oldFetchedData =
                            model.fetchedData

                        newFetchedData =
                            case r of
                                FetchedCourseList courses ->
                                    { oldFetchedData | courses = courses }

                                FetchedMarks marks ->
                                    { oldFetchedData | marks = marks }

                                FetchedCourse course ->
                                    { oldFetchedData | courses = [ course ] }

                                FetchedActivities activities ->
                                    { oldFetchedData | activities = List.sortBy .order activities }

                                FetchedEnrollments enrollments ->
                                    { oldFetchedData | enrollments = enrollments }
                    in
                    ( { model | fetchedData = newFetchedData, state = StateLoading m }, Cmd.map MsgFetch c )

                ( TaskFinishedAll results, _ ) ->
                    if List.all resultIsOK results then
                        ( updateTable { model | state = StateComplete }, Cmd.none )

                    else
                        ( { model | state = StateLoading m }, Cmd.map MsgFetch c )

                _ ->
                    ( { model | state = StateLoading m }, Cmd.map MsgFetch c )

        ( MsgFetch msg_, _ ) ->
            ignore

        ( MsgMarkKeyPress mark_slot x y cmd, _ ) ->
            let
                onResult res =
                    case res of
                        Ok r ->
                            MsgNop

                        Err e ->
                            MsgNop

                check_coords ( x_, y_ ) ( w, h ) =
                    x_ >= 0 && y_ >= 0 && x_ < w && y_ < h

                vec =
                    case cmd of
                        CmdMove Left ->
                            ( -1, 0 )

                        CmdMove Top ->
                            ( 0, -1 )

                        CmdMove Right ->
                            ( 1, 0 )

                        CmdMove Bottom ->
                            ( 0, 1 )

                        _ ->
                            ( 0, 0 )

                v2add ( a, b ) ( c, d ) =
                    ( a + c, b + d )

                ( nx, ny ) =
                    v2add ( x, y ) vec
            in
            if not model.canEdit then
                ignore

            else
                case cmd of
                    CmdMove _ ->
                        if check_coords ( nx, ny ) model.size then
                            ( { model | selectedCoords = ( nx, ny ) }
                            , focusCell nx ny
                            )

                        else
                            ignore

                    CmdSetMark new_mark ->
                        case mark_slot of
                            SlotMark _ mark ->
                                ( model
                                , doUpdateMark
                                    model.token
                                    mark
                                    ( x, y )
                                    new_mark
                                )

                            SlotVirtual _ activityID studentID ->
                                ( model
                                , Maybe.withDefault Cmd.none <|
                                    Maybe.map
                                        (\author_id ->
                                            doCreateMark
                                                model.token
                                                activityID
                                                studentID
                                                author_id
                                                ( x, y )
                                                new_mark
                                        )
                                        model.teacher_id
                                )

                    CmdUnknown _ ->
                        ignore

                    CmdDeleteMark ->
                        case mark_slot of
                            SlotMark isSelected mark ->
                                Maybe.withDefault ( model, Cmd.none ) <|
                                    Maybe.map
                                        (\id ->
                                            ( model
                                            , doDeleteMark
                                                model.token
                                                id
                                                ( x, y )
                                            )
                                        )
                                        mark.id

                            SlotVirtual _ _ _ ->
                                ignore

        ( MsgMarkCreated ( x, y ) mark, _ ) ->
            ( updateMark model ( x, y ) (Util.Right mark), switchMarkCmd model )

        ( MsgMarkUpdated ( x, y ) mark, _ ) ->
            ( updateMark model ( x, y ) (Util.Right mark), switchMarkCmd model )

        ( MsgMarkDeleted ( x, y ) mid, _ ) ->
            ( updateMark model ( x, y ) (Util.Left mid), switchMarkCmd model )

        ( MsgNop, _ ) ->
            ignore

        ( MsgSelectSwitchCell msg_, _ ) ->
            case model.switchCell of
                Just model_ ->
                    let
                        ( m, c ) =
                            Select.update msg_ model_
                    in
                    ( { model | switchCell = Just m }, Cmd.map MsgSelectSwitchCell c )

                Nothing ->
                    ignore

        ( MsgMarkSelected ( x, y ), _ ) ->
            ( { model | selectedCoords = ( x, y ) }, Cmd.none )

        ( MsgMarkClicked mark ( x, y ), _ ) ->
            ( { model
                | showMarkDetails =
                    if model.canViewDetails then
                        mark

                    else
                        Nothing
                , selectedCoords = ( x, y )
              }
            , Cmd.none
            )

        ( MsgOnClickCloseMarkDetails, _ ) ->
            ( { model | showMarkDetails = Nothing }, Cmd.none )

        ( MsgSetDateFilter f, StateComplete ) ->
            ( updateTable { model | dateFilter = f }, Cmd.none )

        ( MsgSetDateFilter f, _ ) ->
            ignore

        ( MsgOnCheckGroupByDate val, _ ) ->
            ( updateTable { model | marksGroupByDate = Just val }, Cmd.none )


viewColumn : Bool -> Zone -> Column -> Html Msg
viewColumn showNoDate tz column =
    case column of
        Activity activity ->
            case activity.contentType of
                Just ActivityContentTypeFIN ->
                    div []
                        [ div [ style "font-weight" "bold" ] [ text <| Maybe.withDefault "(нет даты)" <| Maybe.map (posixToDDMMYYYY tz) activity.date ]
                        , div [] [ text <| finalTypeToStr activity ]
                        ]

                _ ->
                    div []
                        [ div [ style "font-weight" "bold" ] [ text <| Maybe.withDefault "(нет даты)" <| Maybe.map (posixToDDMMYYYY tz) activity.date ]
                        , div [] [ text <| Maybe.withDefault "" activity.keywords ]
                        ]

        Date posix ->
            strong []
                [ text <|
                    M.withDefault
                        (if showNoDate then
                            "(без даты)"

                         else
                            "Оценки"
                        )
                    <|
                        M.map (posixToDDMMYYYY T.utc) posix
                ]


viewRowsFirstCol : Row -> Html Msg
viewRowsFirstCol row =
    case row of
        User user ->
            div [ style "margin" "0 1em" ] [ user_link Nothing user ]

        Course course ->
            a [ href <| "/course/" ++ get_id_str course ] [ text course.title ]


markValueColors : String -> ( String, String )
markValueColors val =
    let
        default =
            ( "#BFC9CA", "#5c5e60" )
    in
    case val of
        "4" ->
            ( "#7DCEA0", "#145931" )

        "5" ->
            ( "#76D7C4", "#0e6756" )

        "3" ->
            ( "#F7DC6F", "rgb(119 97 5)" )

        "2" ->
            ( "#D98880", "#922B21" )

        "1" ->
            markValueColors "2"

        "0" ->
            default

        "н" ->
            default

        "зч" ->
            markValueColors "5"

        "нз" ->
            markValueColors "2"

        "+" ->
            markValueColors "5"

        "-" ->
            markValueColors "2"

        _ ->
            default


markSelectedColors : ( String, String )
markSelectedColors =
    ( "#7FB3D5", "#1F618D" )


viewMarkSlot : Int -> Int -> Int -> MarkSlot -> Html Msg
viewMarkSlot y x s markSlot =
    let
        is_first =
            y == 0 && (x + s) == 0

        common_attrs =
            [ style "min-width" "40px"
            , style "max-width" "40px"
            , style "min-height" "40px"
            , style "max-height" "40px"
            , style "margin" "5px"
            , id <| "slot-" ++ String.fromInt (x + s) ++ "-" ++ String.fromInt y
            , class "mark_slot"
            , tabindex 1
            , style "cursor" "pointer"
            , on "keydown" <|
                JD.andThen
                    (\k ->
                        JD.succeed <|
                            MsgMarkKeyPress markSlot (x + s) y <|
                                keyCodeToMarkCmd k
                    )
                <|
                    JD.at [ "code" ] JD.string
            ]
                ++ [ autofocus is_first ]
    in
    case markSlot of
        SlotMark sel mark ->
            let
                ( bg, fg ) =
                    if sel then
                        markSelectedColors

                    else
                        markValueColors mark.value
            in
            div
                ([ style "background-color" bg
                 , style "border" ("1px solid " ++ fg)
                 , style "color" fg
                 , style "font-size" "16pt"
                 , style "padding" "5px"
                 , class "row center-xs middle-xs"
                 , style "font-weight" "bold"
                 , onClick (MsgMarkClicked (Just mark) ( x, y ))
                 ]
                    ++ common_attrs
                    ++ (if sel then
                            [ id "slot_selected" ]

                        else
                            []
                       )
                )
                [ text mark.value ]

        SlotVirtual sel _ _ ->
            div
                ([ class "mark_slot"
                 , onClick (MsgMarkClicked Nothing ( x, y ))
                 ]
                    ++ common_attrs
                    ++ (if sel then
                            [ id "slot_selected" ]

                        else
                            []
                       )
                )
                []


viewTableCell : Bool -> Int -> Int -> SlotList -> Html Msg
viewTableCell alignStart y x slot_list =
    td
        [ style "white-space" "nowrap"
        ]
        [ div
            [ class
                ("row "
                    ++ (if alignStart then
                            "start-xs"

                        else
                            "center-xs"
                       )
                )
            , style "min-width" (String.fromInt (List.length slot_list * 50) ++ "px") -- TODO: change with something better
            ]
          <|
            L.indexedMap (viewMarkSlot y x) slot_list
        ]


viewTableHeader : Model -> Html Msg
viewTableHeader model =
    let
        td_attrs col =
            case col of
                Activity act ->
                    case act.contentType of
                        Just ActivityContentTypeFIN ->
                            [ style "background-color" "#FFEFE2FF" ]

                        Just ActivityContentTypeTSK ->
                            [ style "background-color" "hsl(266, 100%, 97%)" ]

                        _ ->
                            [ style "background-color" "#EEF6FFFF" ]

                Date _ ->
                    [ style "background-color" "white" ]
    in
    thead
        [ style "position" "sticky"
        , style "top" "0"
        , style "z-index" "2"
        ]
        [ tr []
            ((++)
                [ td
                    [ style "position" "sticky"
                    , style "left" "0"
                    , style "top" "0"
                    , style "background-color" "#F6F6F6"
                    ]
                    []
                ]
             <|
                L.map
                    (\col ->
                        td
                            ([ style "text-align" "center"
                             , style "vertical-align" "top"
                             , style "border-bottom" "2px solid #DDD"
                             ]
                                ++ td_attrs col
                            )
                            [ viewColumn (M.withDefault False <| model.marksGroupByDate) model.tz col ]
                    )
                    model.columns
            )
        ]


viewTableRow : Bool -> Int -> ( Row, ColList ) -> Html Msg
viewTableRow alignStart y ( row, cols ) =
    tr []
        ([ td
            [ style "vertical-align" "middle"
            , style "white-space" "nowrap"
            , style "background-color" "white"
            , style "position" "sticky"
            , style "left" "0"
            , style "border-right" "2px solid #DDD"
            ]
            [ viewRowsFirstCol row ]
         ]
            ++ (Tuple.second <|
                    L.foldl
                        (\col ( x, res ) -> ( x + L.length col, res ++ [ viewTableCell alignStart y x col ] ))
                        ( 0, [] )
                        cols
               )
        )


viewMarkDetailsModal : Model -> Html Msg
viewMarkDetailsModal model =
    case model.showMarkDetails of
        Just mark ->
            let
                activity =
                    case model.state of
                        StateComplete ->
                            List.head <|
                                List.filter (\a -> a.id == Just mark.activity) model.fetchedData.activities

                        _ ->
                            Nothing

                details =
                    div [ class "row center-xs middle-xs" ]
                        [ div [ class "col-xs-12 col-md-6" ]
                            [ div [ class "row" ]
                                [ div [ class "col-xs-12 col-sm-6 end-xs" ] [ strong [] [ text "Оценка:" ] ]
                                , div [ class "col-xs-12 col-sm-6 start-xs" ] [ text mark.value ]
                                ]
                            , div [ class "row" ]
                                [ div [ class "col-xs-12 col-sm-6 end-xs" ] [ strong [] [ text "Тема:" ] ]
                                , div [ class "col-xs-12 col-sm-6 start-xs" ]
                                    [ text <|
                                        Maybe.withDefault "(Неизвестна)" <|
                                            Maybe.map .title activity
                                    ]
                                ]
                            , div [ class "row" ]
                                [ div [ class "col-xs-12 col-sm-6 end-xs" ] [ strong [] [ text "Описание:" ] ]
                                , div [ class "col-xs-12 col-sm-6 start-xs" ]
                                    [ text <|
                                        Maybe.withDefault "(Неизвестно)" <|
                                            empty_to_nothing <|
                                                Maybe.andThen .body activity
                                    ]
                                ]
                            , div [ class "row" ]
                                [ div [ class "col-xs-12 col-sm-6 end-xs" ] [ strong [] [ text "Дата темы:" ] ]
                                , div [ class "col-xs-12 col-sm-6 start-xs" ]
                                    [ text <|
                                        Maybe.withDefault "(Неизвестно)" <|
                                            empty_to_nothing <|
                                                M.map (posixToDDMMYYYY T.utc) <|
                                                    M.andThen .date activity
                                    ]
                                ]
                            , div [ class "row" ]
                                [ div [ class "col-xs-12 col-sm-6 end-xs" ] [ strong [] [ text "Дата выставления:" ] ]
                                , div [ class "col-xs-12 col-sm-6 start-xs" ]
                                    [ text <|
                                        Maybe.withDefault "(Неизвестно)" <|
                                            empty_to_nothing <|
                                                M.map (posixToDDMMYYYY T.utc) <|
                                                    mark.createdAt
                                    ]
                                ]
                            ]
                        ]
            in
            Modal.view
                "mark_details"
                "Подробности"
                details
                MsgOnClickCloseMarkDetails
                [ ( "Закрыть", MsgOnClickCloseMarkDetails ) ]
                True

        Nothing ->
            text ""


viewDateFilter : Model -> Html Msg
viewDateFilter model =
    let
        viewItem ( s, f ) =
            let
                selStyle =
                    if model.dateFilter == f then
                        [ style "background-color" "rgb(65, 131, 196)"
                        , style "color" "white"
                        , style "border-radius" "5px"
                        ]

                    else
                        []
            in
            div
                [ class "item mr-5"
                , style "padding" "0"
                , style "cursor" "pointer"
                , onClick (MsgSetDateFilter f)
                ]
                [ div
                    ([ class "content"
                     , style "margin" "5px 10px 5px 10px"
                     , style "padding" "5px"
                     ]
                        ++ selStyle
                    )
                    [ div
                        ([ class "header"
                         ]
                            ++ selStyle
                        )
                        [ text s ]
                    ]
                ]
    in
    div [ class "ui mini horizontal divided list" ] <|
        List.map viewItem
            [ ( "1 четверть", DateFilterQ1 )
            , ( "2 четверть", DateFilterQ2 )
            , ( "3 четверть", DateFilterQ3 )
            , ( "4 четверть", DateFilterQ4 )
            , ( "1 полугодие", DateFilterH1 )
            , ( "2 полугодие", DateFilterH2 )
            , ( "Все", DateFilterAll )
            ]


viewTable : Model -> Html Msg
viewTable model =
    div
        [ style "position" "absolute"
        , style "left" "0"
        , style "right" "0"
        , style "bottom" "0"
        , style "top" "120px"
        ]
        [ viewMarkDetailsModal model
        , div
            [ class "ui container segment"
            , style "margin-bottom" "10px"
            , style "background-color" "#EEE"
            , style "padding" "5px"
            ]
            [ div [ class "row between-xs middle-xs", style "height" "100%" ]
                [ div
                    [ class "col-xs-12 col-sm center-xs start-sm"
                    , style "flex-grow" "2"
                    ]
                    [ viewDateFilter model
                    ]
                , div [ class "col-xs-12 col-sm center-xs end-sm mt-5" ]
                    [ Maybe.withDefault (text "") <|
                        Maybe.map (\val -> checkbox "Группировать по дате" val MsgOnCheckGroupByDate) model.marksGroupByDate
                    , Maybe.withDefault (text "") <|
                        Maybe.map (Html.map MsgSelectSwitchCell << Select.view) model.switchCell
                    ]
                ]
            ]
        , if model.rows == [] || model.columns == [] then
            h3 [] [ text "Нет данных" ]

          else
            table
                [ class "ui celled striped unstackable table"
                , style "max-width" "fit-content"
                , style "max-height" "calc(100% - 60px)"
                , style "display" "block"
                , style "overflow" "scroll"
                , style "margin-top" "10px"
                , style "margin" "auto"
                ]
                ((++) [ viewTableHeader model ] <|
                    L.indexedMap
                        (viewTableRow <|
                            not <|
                                M.withDefault False model.marksGroupByDate
                        )
                    <|
                        zip model.rows model.cells
                )
        ]


view : Model -> Html Msg
view model =
    case model.state of
        StateLoading model_ ->
            Html.map MsgFetch <| MultiTask.view showFetchedData httpErrorToString model_

        StateComplete ->
            viewTable model

        StateError string ->
            text string

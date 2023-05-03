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
import Theme
import Time as T exposing (Posix, Zone, millisToPosix, utc)
import Tuple exposing (first, second)
import Util exposing (Either, actCT2string, dict2DGet, dictFromTupleListMany, dictGroupBy, eitherGetRight, finalTypeOrder, finalTypeToStr, get_id_str, httpErrorToString, index_by, listDropWhile, listSplitWhile, listTailWithEmpty, listTakeWhile, listUniqueNaive, maybeFlatten, maybeToList, monthToInt, posixToDDMMYYYY, prec, resultIsOK, takeLongestPrefixBy, taskGetTimeAndZone, user_full_name, zip, zip3)
import Uuid exposing (Uuid)


type ColumnHeader
    = ColumnHeaderActivity Data.Activity
    | ColumnHeaderDate (Maybe Posix)
    | ColumnHeaderMean
    | ColumnHeaderFinal String


type RowHeader
    = RowHeaderUser Data.UserShallow
    | RowHeaderCourse Data.Course


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
    | SlotMean (Maybe Float)


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
    | DateFilterFinal


type alias SlotList =
    List MarkSlot


type alias ColumnList =
    List SlotList


type alias RowList =
    List ColumnList


type FetchedDataEvent
    = FetchedMarks (List Mark)
    | FetchedCourseList (List Course)
    | FetchedCourse Course
    | FetchedActivities (List Activity)
    | FetchedEnrollments (List CourseEnrollmentRead)
    | FetchedDate ( Zone, Posix )


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

    --, tzTime : ( Zone, Posix )
    }


type alias Model =
    { columns : List ColumnHeader
    , rows : List RowHeader
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

        "Backspace" ->
            CmdDeleteMark

        _ ->
            CmdUnknown code


markToNum : Mark -> number
markToNum m =
    case m.value of
        "1" ->
            1

        "2" ->
            2

        "3" ->
            3

        "4" ->
            4

        "5" ->
            5

        "+" ->
            5

        "-" ->
            2

        "зч" ->
            5

        "нз" ->
            2

        _ ->
            0


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

        FetchedDate _ ->
            "OK"


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
                , ( ext_task FetchedEnrollments
                        token
                        [ ( "course", Uuid.toString course_id )
                        , ( "finished_on__isnull", "True" )
                        ]
                    <|
                        courseEnrollmentList
                  , "Получение данных об участниках"
                  )
                , ( ext_task FetchedActivities token [ ( "course", Uuid.toString course_id ) ] activityList
                  , "Получение тем занятий"
                  )
                , ( ext_task FetchedMarks token [ ( "activity__course", Uuid.toString course_id ) ] markList
                  , "Получение оценок"
                  )
                , ( Task.map FetchedDate taskGetTimeAndZone
                  , "Получение текущей даты"
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

                ( SlotMean _, _ ) ->
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
    updateTable
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


focusCell : Int -> Int -> Cmd Msg
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
    let
        q1marker act =
            act.finalType == Just ActivityFinalTypeQ1

        q2marker act =
            act.finalType == Just ActivityFinalTypeQ2 || act.finalType == Just ActivityFinalTypeH1

        q3marker act =
            act.finalType == Just ActivityFinalTypeQ3

        q4marker act =
            False
                || (act.finalType
                        == Just ActivityFinalTypeQ4
                   )
                || (act.finalType
                        == Just ActivityFinalTypeH2
                   )
                || (act.finalType
                        == Just ActivityFinalTypeY
                   )

        h1marker =
            q2marker

        h2marker =
            q4marker
    in
    case filter of
        DateFilterQ1 ->
            let
                ( l, r ) =
                    takeLongestPrefixBy q1marker orderSortedActs
            in
            l

        DateFilterQ2 ->
            let
                ( q1, q1tail ) =
                    takeLongestPrefixBy q1marker orderSortedActs

                ( q2, q2tail ) =
                    takeLongestPrefixBy q2marker q1tail
            in
            q2

        DateFilterQ3 ->
            let
                ( q2, q2tail ) =
                    takeLongestPrefixBy q2marker orderSortedActs

                ( q3, q3tail ) =
                    takeLongestPrefixBy q3marker q2tail
            in
            q3

        DateFilterQ4 ->
            let
                ( q3, q3tail ) =
                    takeLongestPrefixBy q3marker orderSortedActs

                ( q4, q4tail ) =
                    takeLongestPrefixBy q4marker q3tail
            in
            q4

        DateFilterH1 ->
            let
                ( h1, h1tail ) =
                    takeLongestPrefixBy h1marker orderSortedActs
            in
            h1

        DateFilterH2 ->
            let
                ( h1, h1tail ) =
                    takeLongestPrefixBy h1marker orderSortedActs
            in
            h1tail

        DateFilterAll ->
            orderSortedActs

        DateFilterFinal ->
            List.filter (.contentType >> (==) (Just ActivityContentTypeFIN)) orderSortedActs


updateTable : Model -> Model
updateTable model =
    case model.mode of
        MarksOfCourse ->
            let
                actsIX : Dict String Activity
                actsIX =
                    index_by get_id_str activities

                actsFinIX =
                    D.filter (\id a -> a.contentType == Just ActivityContentTypeFIN) actsIX

                rows : List RowHeader
                rows =
                    L.filterMap
                        (\enr ->
                            if enr.role == CourseEnrollmentReadRoleS then
                                enr.person |> RowHeaderUser |> Just

                            else
                                Nothing
                        )
                    <|
                        List.sortBy (.person >> user_full_name) model.fetchedData.enrollments

                columns : List ColumnHeader
                columns =
                    (L.map ColumnHeaderActivity <| L.sortBy .order activities) ++ [ ColumnHeaderMean ]

                activities : List Activity
                activities =
                    dateFilter model.dateFilter <|
                        List.filter (\a -> 0 < Maybe.withDefault 0 a.marksLimit) model.fetchedData.activities

                markSlotIX : Dict String (Dict String (List MarkSlot))
                markSlotIX =
                    L.foldl
                        (\mark resD ->
                            let
                                mbAct =
                                    D.get (Uuid.toString mark.activity) actsIX

                                sID =
                                    Uuid.toString mark.student
                            in
                            case mbAct of
                                Just act ->
                                    let
                                        y =
                                            get_id_str act

                                        x =
                                            sID
                                    in
                                    D.update x
                                        (\mbSubD ->
                                            let
                                                slot =
                                                    SlotMark False mark

                                                subD =
                                                    M.withDefault D.empty mbSubD

                                                subDNew =
                                                    D.update y (Just << M.withDefault [ slot ] << M.map (\l -> l ++ [ slot ])) subD
                                            in
                                            Just subDNew
                                        )
                                        resD

                                Nothing ->
                                    resD
                        )
                        D.empty
                        model.fetchedData.marks

                markIsFinal : Mark -> Bool
                markIsFinal mark =
                    D.member (Uuid.toString mark.activity) actsFinIX

                cells : List (List (List MarkSlot))
                cells =
                    L.map
                        (\row ->
                            L.map
                                (\col ->
                                    case ( row, col ) of
                                        ( RowHeaderUser student, ColumnHeaderActivity act ) ->
                                            let
                                                mark_slots =
                                                    M.withDefault [] <| dict2DGet (get_id_str student) (get_id_str act) markSlotIX
                                            in
                                            case ( act.id, student.id ) of
                                                ( Just aid, Just sid ) ->
                                                    mark_slots
                                                        ++ L.repeat
                                                            (M.withDefault 0 act.marksLimit - L.length mark_slots)
                                                            (SlotVirtual False aid sid)

                                                _ ->
                                                    mark_slots

                                        ( RowHeaderUser student, ColumnHeaderMean ) ->
                                            let
                                                slotToNum s =
                                                    case s of
                                                        SlotMark _ m ->
                                                            if m.value == "н" || markIsFinal m then
                                                                Nothing

                                                            else
                                                                markToNum m |> Just

                                                        _ ->
                                                            Nothing

                                                marks =
                                                    L.filterMap slotToNum <|
                                                        L.concat <|
                                                            D.values <|
                                                                M.withDefault D.empty <|
                                                                    D.get (get_id_str student) markSlotIX

                                                len =
                                                    L.length marks

                                                sum =
                                                    L.sum marks
                                            in
                                            if len > 0 then
                                                [ SlotMean (Just <| sum / toFloat len) ]

                                            else
                                                [ SlotMean Nothing ]

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
                    L.map RowHeaderCourse <| List.sortBy .title model.fetchedData.courses

                existingActivityIDS =
                    Set.fromList <| List.map (.activity >> Uuid.toString) model.fetchedData.marks

                activities : List Activity
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

                finalActs =
                    L.sortBy (.finalType >> Maybe.withDefault ActivityFinalTypeF >> finalTypeOrder) <|
                        L.filter (\act -> act.contentType == Just ActivityContentTypeFIN) activities

                columns : List ColumnHeader
                columns =
                    (if M.withDefault False <| model.marksGroupByDate then
                        L.map ColumnHeaderDate <|
                            L.map (Just << T.millisToPosix) <|
                                Set.toList <|
                                    Set.fromList <|
                                        L.filterMap (.date >> M.map T.posixToMillis) <|
                                            L.sortBy .order activities

                     else
                        []
                    )
                        ++ [ ColumnHeaderDate Nothing ]
                        ++ (if M.withDefault False <| M.map not model.marksGroupByDate then
                                L.map ColumnHeaderFinal <|
                                    listUniqueNaive <|
                                        L.map finalTypeToStr finalActs

                            else
                                []
                           )

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

                                  else if act.contentType == Just ActivityContentTypeFIN then
                                    finalTypeToStr act

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
                                        ( D.get (Uuid.toString m.activity) ix_acts |> M.map (.order >> (*) -1) |> M.withDefault 0
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
                                        ( RowHeaderCourse course, ColumnHeaderDate date ) ->
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

                                        ( RowHeaderCourse course, ColumnHeaderFinal name ) ->
                                            let
                                                mark_slots =
                                                    M.withDefault [] <|
                                                        D.get
                                                            ( name
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

                                FetchedDate ( zone, posix ) ->
                                    oldFetchedData
                    in
                    ( { model | fetchedData = newFetchedData, state = StateLoading m }, Cmd.map MsgFetch c )

                ( TaskFinishedAll results, _ ) ->
                    if List.all resultIsOK results then
                        let
                            filterTZTime : Result error FetchedDataEvent -> Maybe ( Zone, Posix )
                            filterTZTime res =
                                case res of
                                    Ok (FetchedDate x) ->
                                        Just x

                                    _ ->
                                        Nothing

                            tzTime : Maybe ( Zone, Posix )
                            tzTime =
                                List.head <| List.filterMap filterTZTime results

                            tz2quarter : ( Zone, Posix ) -> DateFilter
                            tz2quarter ( zone, posix ) =
                                let
                                    month =
                                        monthToInt <| T.toMonth zone posix
                                in
                                if month > 10 then
                                    DateFilterQ2

                                else if month > 8 then
                                    DateFilterQ1

                                else if month > 3 then
                                    DateFilterQ4

                                else
                                    DateFilterQ3
                        in
                        ( updateTable
                            { model
                                | state = StateComplete
                                , dateFilter = Maybe.withDefault DateFilterAll <| Maybe.map tz2quarter tzTime
                            }
                        , Cmd.none
                        )

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

                            SlotMean _ ->
                                ignore

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

                            SlotMean _ ->
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


viewColumnHeader : Bool -> Zone -> ColumnHeader -> Html Msg
viewColumnHeader showNoDate tz column =
    case column of
        ColumnHeaderActivity activity ->
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

        ColumnHeaderDate posix ->
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

        ColumnHeaderMean ->
            strong []
                [ text "Средняя оценка" ]

        ColumnHeaderFinal v ->
            strong []
                [ text v ]


viewRowsFirstCol : RowHeader -> Html Msg
viewRowsFirstCol row =
    case row of
        RowHeaderUser user ->
            div [ style "margin" "0 1em" ] [ user_link Nothing user ]

        RowHeaderCourse course ->
            a [ href <| "/course/" ++ get_id_str course ] [ text course.title ]


markValueColors : String -> ( String, String )
markValueColors val =
    case val of
        "4" ->
            Theme.default.colors.marks.good

        "5" ->
            Theme.default.colors.marks.excellent

        "3" ->
            Theme.default.colors.marks.average

        "2" ->
            Theme.default.colors.marks.bad

        "1" ->
            Theme.default.colors.marks.bad

        "0" ->
            Theme.default.colors.marks.neutral

        "н" ->
            Theme.default.colors.marks.neutral

        "зч" ->
            Theme.default.colors.marks.excellent

        "нз" ->
            Theme.default.colors.marks.bad

        "+" ->
            Theme.default.colors.marks.excellent

        "-" ->
            Theme.default.colors.marks.bad

        _ ->
            Theme.default.colors.marks.neutral


markNumberValueColor : Float -> String
markNumberValueColor v =
    let
        sel =
            second
    in
    if v < 2.5 then
        sel <| markValueColors "2"

    else if v < 3.5 then
        sel <| markValueColors "3"

    else if v < 4.5 then
        sel <| markValueColors "4"

    else
        sel <| markValueColors "5"


viewMarkSlot : Int -> Int -> Int -> MarkSlot -> Html Msg
viewMarkSlot y x s markSlot =
    let
        is_first =
            y == 0 && (x + s) == 0

        id_ =
            id <| "slot-" ++ String.fromInt (x + s) ++ "-" ++ String.fromInt y

        common_attrs =
            [ style "min-width" "40px"
            , style "max-width" "40px"
            , style "min-height" "40px"
            , style "max-height" "40px"
            , style "margin" "5px"
            , id_
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
                        Theme.default.colors.marks.selected

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
            let
                ( bg, fg ) =
                    if sel then
                        Theme.default.colors.marks.selected

                    else
                        Theme.default.colors.marks.empty
            in
            div
                ([ class "mark_slot"
                 , onClick (MsgMarkClicked Nothing ( x, y ))
                 , style "background-color" bg
                 ]
                    ++ common_attrs
                    ++ (if sel then
                            [ id "slot_selected" ]

                        else
                            []
                       )
                )
                []

        SlotMean (Just v) ->
            strong
                [ style "color" <| markNumberValueColor v
                , style "font-size" "16pt"
                , id_
                ]
                [ text <| String.fromFloat <| prec True 2 v ]

        SlotMean Nothing ->
            strong
                [ style "color" <| second <| markValueColors "н"
                , style "font-size" "16pt"
                , id_
                ]
                [ text "Н/Д" ]


viewTableCell : Bool -> Int -> Int -> RowHeader -> ColumnHeader -> SlotList -> Html Msg
viewTableCell alignStart y x rowHeader colHeader slot_list =
    let
        bgColor =
            case colHeader of
                ColumnHeaderActivity act ->
                    case act.contentType of
                        Just ct ->
                            case ct of
                                ActivityContentTypeGEN ->
                                    first Theme.default.colors.activities.empty

                                ActivityContentTypeTXT ->
                                    first Theme.default.colors.activities.empty

                                ActivityContentTypeTSK ->
                                    first Theme.default.colors.activities.empty

                                ActivityContentTypeLNK ->
                                    first Theme.default.colors.activities.empty

                                ActivityContentTypeMED ->
                                    first Theme.default.colors.activities.empty

                                ActivityContentTypeFIN ->
                                    first Theme.default.colors.activities.final

                        Nothing ->
                            first Theme.default.colors.activities.empty

                ColumnHeaderDate _ ->
                    first Theme.default.colors.activities.empty

                ColumnHeaderMean ->
                    first Theme.default.colors.activities.mean

                ColumnHeaderFinal _ ->
                    first Theme.default.colors.activities.final
    in
    td
        [ style "white-space" "nowrap"
        , style "background-color" bgColor
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

            --, style "min-width" (String.fromInt (List.length slot_list * 50) ++ "px") -- TODO: change with something better
            --, style "max-width" (String.fromInt (List.length slot_list * 70 + 50) ++ "px")
            , style "margin" "0"
            , style "width" "100%"
            , style "min-width" "max-content"
            ]
          <|
            L.indexedMap (viewMarkSlot y x) slot_list
        ]


viewTableHeader : Model -> Html Msg
viewTableHeader model =
    let
        td_attrs col =
            case col of
                ColumnHeaderActivity act ->
                    case act.contentType of
                        Just ActivityContentTypeFIN ->
                            [ style "background-color" <| first Theme.default.colors.activities.final ]

                        Just ActivityContentTypeTSK ->
                            [ style "background-color" <| first Theme.default.colors.activities.task ]

                        _ ->
                            [ style "background-color" <| first Theme.default.colors.activities.general ]

                ColumnHeaderDate _ ->
                    [ style "background-color" <| first Theme.default.colors.activities.empty ]

                ColumnHeaderMean ->
                    [ style "background-color" <| first Theme.default.colors.activities.mean ]

                ColumnHeaderFinal _ ->
                    [ style "background-color" <| first Theme.default.colors.activities.final ]
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
                            [ div [ style "max-width" "150px" ] [ viewColumnHeader (M.withDefault False <| model.marksGroupByDate) model.tz col ] ]
                    )
                    model.columns
            )
        ]


viewTableRow : List ColumnHeader -> Bool -> Int -> ( RowHeader, ColumnList ) -> Html Msg
viewTableRow columnHeaders alignStart y ( rowHeader, columnContentList ) =
    tr []
        ([ td
            [ style "vertical-align" "middle"
            , style "white-space" "nowrap"
            , style "background-color" "white"
            , style "position" "sticky"
            , style "left" "0"
            , style "border-right" "2px solid #DDD"
            ]
            [ viewRowsFirstCol rowHeader ]
         ]
            ++ (Tuple.second <|
                    L.foldl
                        (\( col, colContent ) ( x, res ) ->
                            let
                                alignStart2 =
                                    case col of
                                        ColumnHeaderFinal _ ->
                                            False

                                        _ ->
                                            alignStart
                            in
                            ( x + L.length colContent, res ++ [ viewTableCell alignStart2 y x rowHeader col colContent ] )
                        )
                        ( 0, [] )
                        (zip columnHeaders columnContentList)
               )
        )


viewMarkDetailsModal : Model -> Html Msg
viewMarkDetailsModal model =
    case model.showMarkDetails of
        Just mark ->
            let
                activity : Maybe Activity
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
                                [ div [ class "col-xs-12 col-sm-6 end-xs" ] [ strong [] [ text "Тип:" ] ]
                                , div [ class "col-xs-12 col-sm-6 start-xs" ]
                                    [ text <|
                                        Maybe.withDefault "(нет)" <|
                                            maybeFlatten <|
                                                Maybe.map (.contentType >> Maybe.map actCT2string) activity
                                    ]
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
                        [ style "background-color" Theme.default.colors.ui.primary
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
            , ( "Итоговые", DateFilterFinal )
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
                        (viewTableRow model.columns <|
                            not <|
                                M.withDefault False model.marksGroupByDate
                                    || model.canEdit
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

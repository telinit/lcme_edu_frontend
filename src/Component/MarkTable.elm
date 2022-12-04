module Component.MarkTable exposing (..)

import Api exposing (ext_task)
import Api.Data as Data exposing (..)
import Api.Request.Activity exposing (activityList)
import Api.Request.Course exposing (courseGetDeep, courseList)
import Api.Request.Mark exposing (markCreate, markDelete, markList, markPartialUpdate)
import Browser.Dom exposing (Error(..), focus)
import Component.Misc exposing (user_link)
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
import Set
import Task
import Time as T exposing (Posix, Zone, millisToPosix, utc)
import Util exposing (dictFromTupleListMany, finalTypeToStr, get_id_str, httpErrorToString, index_by, posixToDDMMYYYY, user_full_name, zip)
import Uuid exposing (Uuid)


type Column
    = Activity Data.Activity
    | Date Posix


type Row
    = User Data.UserShallow
    | Course Data.CourseShallow


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


type alias SlotList =
    List MarkSlot


type alias ColList =
    List SlotList


type alias RowList =
    List ColList


type FetchedData
    = FetchedMarks (List Mark)
    | FetchedCourseList (List CourseShallow)
    | FetchedCourse CourseDeep
    | FetchedActivities (List Activity)


type Msg
    = MsgFetch (MultiTask.Msg Http.Error FetchedData)
    | MsgMarkKeyPress MarkSlot Int Int MarkCmd
    | MsgMarkCreated ( Int, Int ) Mark
    | MsgMarkUpdated ( Int, Int ) Mark
    | MsgMarkDeleted ( Int, Int )
    | MsgMarkSelected ( Int, Int )
    | MsgNop
    | MsgSetStickyCol1 Bool
    | MsgSetStickyRow1 Bool
    | MsgSelectSwitchCell Select.Msg
    | MsgMarkClicked Mark ( Int, Int )
    | MsgOnClickCloseMarkDetails


type State
    = Loading (MultiTask.Model Http.Error FetchedData)
    | Complete (List CourseShallow) (List Activity) (List Mark)
    | Error String


type alias Model =
    { columns : List Column
    , rows : List Row

    --, marks : MarkIndex
    , cells : List (List (List MarkSlot))
    , state : State
    , token : String
    , tz : Zone
    , student_id : Maybe Uuid
    , teacher_id : Maybe Uuid
    , size : ( Int, Int )
    , stickyRow1 : Bool
    , stickyCol1 : Bool
    , switchCell : Maybe Select.Model
    , selectedCoords : ( Int, Int )
    , canEdit : Bool
    , canViewDetails : Bool
    , showMarkDetails : Maybe Mark
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


showFetchedData : FetchedData -> String
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
                    MsgMarkDeleted coords

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
                , ( ext_task FetchedActivities token [ ( "student", Uuid.toString student_id ) ] activityList
                  , "Получение тем занятий"
                  )
                , ( ext_task FetchedMarks token [ ( "student", Uuid.toString student_id ) ] markList
                  , "Получение оценок"
                  )
                ]
    in
    ( { state = Loading m
      , token = token
      , rows = []
      , columns = []
      , cells = []
      , student_id = Just student_id
      , teacher_id = Nothing
      , size = ( 0, 0 )
      , tz = utc
      , stickyRow1 = True
      , stickyCol1 = True
      , switchCell = Nothing
      , selectedCoords = ( 0, 0 )
      , canViewDetails = True
      , canEdit = False
      , showMarkDetails = Nothing
      }
    , Cmd.map MsgFetch c
    )


initForCourse : String -> Uuid -> Maybe Uuid -> ( Model, Cmd Msg )
initForCourse token course_id teacher_id =
    let
        ( m, c ) =
            MultiTask.init
                [ ( ext_task FetchedCourse token [] <| courseGetDeep <| Uuid.toString course_id
                  , "Получение данных о курсе"
                  )
                , ( ext_task FetchedMarks token [ ( "course", Uuid.toString course_id ) ] markList
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
    ( { state = Loading m
      , token = token
      , rows = []
      , columns = []

      --, marks = D.empty
      , cells = []
      , student_id = Nothing
      , teacher_id = teacher_id
      , size = ( 0, 0 )
      , tz = utc
      , stickyRow1 = True
      , stickyCol1 = True
      , switchCell = Just sm
      , selectedCoords = ( 0, 0 )
      , canViewDetails = False
      , canEdit = True
      , showMarkDetails = Nothing
      }
    , Cmd.batch [ Cmd.map MsgFetch c, Cmd.map MsgSelectSwitchCell sc ]
    )


updateMark : Model -> ( Int, Int ) -> Maybe Mark -> Model
updateMark model ( cell_x, cell_y ) mb_mark =
    let
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
                                            update_col (cell_x - slots_cnt) col mb_mark
                                    in
                                    ( slots_cnt + L.length new_col, res ++ [ new_col ] )
                                )
                                ( 0, [] )
                                row

                    else
                        row
                )
                model.cells
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.state ) of
        ( MsgFetch msg_, Loading model_ ) ->
            let
                ( m, c ) =
                    MultiTask.update msg_ model_
            in
            case ( msg_, model.student_id ) of
                --Marks for student
                ( TaskFinishedAll [ Ok (FetchedCourseList courses), Ok (FetchedActivities acts), Ok (FetchedMarks marks) ], Just student_id ) ->
                    let
                        rows =
                            L.map Course <| List.sortBy .title courses

                        -- TODO: Add time filters
                        existingActivityIDS =
                            Set.fromList <| List.map (.activity >> Uuid.toString) marks

                        activities =
                            List.filter (\a -> Set.member (get_id_str a) existingActivityIDS) acts

                        ix_acts =
                            index_by get_id_str activities

                        columns =
                            L.map Date <|
                                L.map T.millisToPosix <|
                                    Set.toList <|
                                        Set.fromList <|
                                            L.filterMap (.date >> Maybe.map T.posixToMillis) <|
                                                L.sortBy .order activities

                        activity_timestamp act =
                            Maybe.map (String.fromInt << T.posixToMillis) act.date

                        activity_course_id act =
                            Uuid.toString act.course

                        mark_coords mark =
                            D.get (Uuid.toString mark.activity) ix_acts
                                |> M.andThen
                                    (\act ->
                                        M.map
                                            (\date ->
                                                ( mark
                                                , String.fromInt <| T.posixToMillis date
                                                , activity_course_id act
                                                )
                                            )
                                            act.date
                                    )

                        marks_ix =
                            dictFromTupleListMany <|
                                L.map (\( mark, x, y ) -> ( ( x, y ), SlotMark False mark )) <|
                                    L.filterMap mark_coords <|
                                        L.sortBy (.createdAt >> M.map T.posixToMillis >> M.withDefault 0) marks

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
                                                                        T.posixToMillis date
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
                    ( { model
                        | state = Complete courses acts marks
                        , rows = rows
                        , columns = columns
                        , cells = cells
                        , size =
                            ( M.withDefault 0 <|
                                L.maximum <|
                                    L.map (\row -> L.sum <| L.map L.length row) cells
                            , L.length rows
                            )
                      }
                    , Cmd.map MsgFetch c
                    )

                ( TaskFinishedAll [ Ok (FetchedCourse course), Ok (FetchedMarks marks) ], _ ) ->
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
                                List.sortBy (.person >> user_full_name) course.enrollments

                        columns =
                            L.map Activity <| L.sortBy .order activities

                        activity_timestamp act =
                            String.fromInt <| T.posixToMillis act.date

                        activities =
                            List.filter (\a -> 0 < Maybe.withDefault 0 a.marksLimit) course.activities

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
                                        L.sortBy (.createdAt >> M.map T.posixToMillis >> M.withDefault 0) marks

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
                    ( { model
                        | state = Complete [] course.activities marks -- TODO: Convert deep to shallow
                        , rows = rows
                        , columns = columns
                        , cells = cells
                        , size =
                            ( M.withDefault 0 <|
                                L.maximum <|
                                    L.map (\row -> L.sum <| L.map L.length row) cells
                            , L.length rows
                            )
                      }
                    , Cmd.map MsgFetch c
                    )

                _ ->
                    ( { model | state = Loading m }, Cmd.map MsgFetch c )

        ( MsgFetch msg_, _ ) ->
            ( model, Cmd.none )

        ( MsgMarkKeyPress mark_slot x y cmd, _ ) ->
            let
                ignore =
                    ( model, Cmd.none )

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
            ( updateMark model ( x, y ) (Just mark), switchMarkCmd model )

        ( MsgMarkUpdated ( x, y ) mark, _ ) ->
            ( updateMark model ( x, y ) (Just mark), switchMarkCmd model )

        ( MsgMarkDeleted ( x, y ), _ ) ->
            ( updateMark model ( x, y ) Nothing, switchMarkCmd model )

        ( MsgNop, _ ) ->
            ( model, Cmd.none )

        ( MsgSetStickyCol1 v, _ ) ->
            ( { model | stickyCol1 = v }, Cmd.none )

        ( MsgSetStickyRow1 v, _ ) ->
            ( { model | stickyRow1 = v }, Cmd.none )

        ( MsgSelectSwitchCell msg_, _ ) ->
            case model.switchCell of
                Just model_ ->
                    let
                        ( m, c ) =
                            Select.update msg_ model_
                    in
                    ( { model | switchCell = Just m }, Cmd.map MsgSelectSwitchCell c )

                Nothing ->
                    ( model, Cmd.none )

        ( MsgMarkSelected ( x, y ), _ ) ->
            ( { model | selectedCoords = ( x, y ) }, Cmd.none )

        ( MsgMarkClicked mark ( x, y ), _ ) ->
            ( { model | showMarkDetails = Just mark, selectedCoords = ( x, y ) }, Cmd.none )

        ( MsgOnClickCloseMarkDetails, _ ) ->
            ( { model | showMarkDetails = Nothing }, Cmd.none )


viewColumn : Zone -> Column -> Html Msg
viewColumn tz column =
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
            strong [] [ text <| posixToDDMMYYYY T.utc posix ]


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
                 , onClick (MsgMarkClicked mark ( x, y ))
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
                ([ class "mark_slot" ]
                    ++ common_attrs
                    ++ (if sel then
                            [ id "slot_selected" ]

                        else
                            []
                       )
                )
                []


viewTableCell : Int -> Int -> SlotList -> Html Msg
viewTableCell y x slot_list =
    td
        [ style "white-space" "nowrap"
        ]
        [ div
            [ class "row center-xs"
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
                    []
    in
    thead
        (if model.stickyRow1 then
            [ style "position" "sticky", style "top" "0", style "z-index" "2" ]

         else
            []
        )
        [ tr []
            ((++)
                [ td
                    (if model.stickyCol1 then
                        [ style "position" "sticky"
                        , style "left" "0"
                        , style "top" "0"
                        , style "background-color" "#F6F6F6"
                        ]

                     else
                        []
                    )
                    []
                ]
             <|
                L.map
                    (\col ->
                        td
                            ([ style "text-align" "center"
                             , style "vertical-align" "top"

                             --, style "white-space" "nowrap"
                             ]
                                ++ td_attrs col
                            )
                            [ viewColumn model.tz col ]
                    )
                    model.columns
            )
        ]


viewTableRow : Bool -> Int -> ( Row, ColList ) -> Html Msg
viewTableRow stickyCol1 y ( row, cols ) =
    tr []
        ([ td
            ([ style "vertical-align" "middle"
             , style "white-space" "nowrap"
             , style "background-color" "white"
             ]
                ++ (if stickyCol1 then
                        [ style "position" "sticky", style "left" "0" ]

                    else
                        []
                   )
            )
            [ viewRowsFirstCol row ]
         ]
            ++ (Tuple.second <|
                    L.foldl
                        (\col ( x, res ) -> ( x + L.length col, res ++ [ viewTableCell y x col ] ))
                        ( 0, [] )
                        cols
               )
        )


viewTable : Model -> Html Msg
viewTable model =
    let
        markDetailsModal =
            case model.showMarkDetails of
                Just mark ->
                    let
                        topic =
                            case model.state of
                                Complete _ activities _ ->
                                    text <|
                                        Maybe.withDefault "(Неизвестна)" <|
                                            Maybe.map .title <|
                                                List.head <|
                                                    List.filter (\a -> a.id == Just mark.activity) activities

                                _ ->
                                    text ""

                        details =
                            div [ class "row center-xs middle-xs" ]
                                [ div [ class "col-xs-12 col-md-6" ]
                                    [ div [ class "row" ]
                                        [ div [ class "col-xs-12 col-sm-6 end-xs" ] [ strong [] [ text "Оценка:" ] ]
                                        , div [ class "col-xs-12 col-sm-6 start-xs" ] [ text mark.value ]
                                        ]
                                    , div [ class "row" ]
                                        [ div [ class "col-xs-12 col-sm-6 end-xs" ] [ strong [] [ text "Тема:" ] ]
                                        , div [ class "col-xs-12 col-sm-6 start-xs" ] [ topic ]
                                        ]
                                    , div [ class "row" ]
                                        [ div [ class "col-xs-12 col-sm-6 end-xs" ] []
                                        , div [ class "col-xs-12 col-sm-6 start-xs" ] []
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
    in
    div
        [ style "position" "absolute"
        , style "left" "0"
        , style "right" "0"
        , style "bottom" "0"
        , style "top" "120px"
        ]
        [ markDetailsModal
        , div
            [ class "ui container segment"
            , style "height" "50px"
            , style "margin-bottom" "10px"
            , style "background-color" "#EEE"
            , style "padding" "5px"
            ]
            [ div [ class "row between-xs middle-xs", style "height" "100%" ]
                [ div [ class "col-xs-12 col-sm center-xs start-sm" ]
                    [ div [ class "ui checkbox" ]
                        [ input [ type_ "checkbox", attribute "tabindex" "0", checked model.stickyRow1, onCheck MsgSetStickyRow1 ] []
                        , label [] [ text "Закрепить первую строку" ]
                        ]
                    , div [ class "ui checkbox ml-10" ]
                        [ input [ type_ "checkbox", attribute "tabindex" "0", checked model.stickyCol1, onCheck MsgSetStickyCol1 ] []
                        , label [] [ text "Закрепить первый столбец" ]
                        ]
                    ]
                , div [ class "col-xs-12 col-sm-3 center-xs end-sm" ]
                    [ Maybe.withDefault (text "") <|
                        Maybe.map (Html.map MsgSelectSwitchCell << Select.view) model.switchCell
                    ]
                ]
            ]
        , table
            [ class "ui celled striped unstackable table"
            , style "max-width" "fit-content"
            , style "max-height" "calc(100% - 60px)"
            , style "display" "block"
            , style "overflow" "scroll"
            , style "margin-top" "10px"
            , style "margin" "auto"
            ]
            ((++) [ viewTableHeader model ] <| L.indexedMap (viewTableRow model.stickyCol1) <| zip model.rows model.cells)
        ]


view : Model -> Html Msg
view model =
    case model.state of
        Loading model_ ->
            Html.map MsgFetch <| MultiTask.view showFetchedData httpErrorToString model_

        Complete _ _ _ ->
            if model.rows == [] || model.columns == [] then
                h3 [] [ text "Нет данных" ]

            else
                viewTable model

        Error string ->
            text string

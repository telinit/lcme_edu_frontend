module Component.MarkTable exposing (..)

import Api exposing (ext_task)
import Api.Data as Data exposing (..)
import Api.Request.Activity exposing (activityList)
import Api.Request.Course exposing (courseGetDeep, courseList)
import Api.Request.Mark exposing (markList)
import Array as A exposing (Array)
import Component.MultiTask as MultiTask exposing (Msg(..))
import Dict as D exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (class, href, style)
import Http
import List as L exposing (filterMap)
import Maybe as M
import Set
import Time as T exposing (Posix)
import Util exposing (dictFromTupleListMany, dictGroupBy, get_id, get_id_str, httpErrorToString, index_by, maybeForceJust, monthToInt, posixToDDMMYYYY, user_full_name, zip)
import Uuid exposing (Uuid)


type Column
    = Activity Data.Activity
    | Date Posix


type Row
    = User Data.User
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
    | MsgMarkArrowClick


type State
    = Loading (MultiTask.Model Http.Error FetchedData)
    | Complete
    | Error String


type alias Model =
    { columns : List Column
    , rows : List Row

    --, marks : MarkIndex
    , cells : List (List (List MarkSlot))
    , state : State
    , token : String
    , student_id : Maybe Uuid
    }


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


initForStudent : String -> String -> ( Model, Cmd Msg )
initForStudent token student_id =
    let
        ( m, c ) =
            MultiTask.init
                [ ( ext_task FetchedCourseList token [ ( "enrollments__person", student_id ), ( "enrollments__role", "s" ) ] courseList
                  , "Получение данных о курсах"
                  )
                , ( ext_task FetchedActivities token [ ( "student", student_id ) ] activityList
                  , "Получение тем занятий"
                  )
                , ( ext_task FetchedMarks token [ ( "student", student_id ) ] markList
                  , "Получение оценок"
                  )
                ]
    in
    ( { state = Loading m
      , token = token
      , rows = []
      , columns = []

      --, marks = D.empty
      , cells = []
      , student_id = Uuid.fromString student_id
      }
    , Cmd.map MsgFetch c
    )


initForCourse : String -> String -> ( Model, Cmd Msg )
initForCourse token course_id =
    let
        ( m, c ) =
            MultiTask.init
                [ ( ext_task FetchedCourse token [] <| courseGetDeep course_id
                  , "Получение данных о курсе"
                  )
                , ( ext_task FetchedMarks token [ ( "course", course_id ) ] markList
                  , "Получение оценок"
                  )
                ]
    in
    ( { state = Loading m
      , token = token
      , rows = []
      , columns = []

      --, marks = D.empty
      , cells = []
      , student_id = Nothing
      }
    , Cmd.map MsgFetch c
    )


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
                        blah =
                            Debug.log "Marks for student" ( ( L.length courses, L.length acts ), ( L.length marks, student_id ) )

                        ix_acts =
                            index_by get_id_str acts

                        rows =
                            L.map Course <| List.sortBy .title courses

                        columns =
                            L.map Date <|
                                L.map T.millisToPosix <|
                                    Set.toList <|
                                        Set.fromList <|
                                            L.map (.date >> T.posixToMillis) <|
                                                L.sortBy .order acts

                        activity_timestamp act =
                            String.fromInt <| T.posixToMillis act.date

                        activity_course_id act =
                            Uuid.toString act.course

                        mark_coords mark =
                            D.get (Uuid.toString mark.activity) ix_acts
                                |> M.andThen
                                    (\act ->
                                        Just
                                            ( mark
                                            , activity_timestamp act
                                            , activity_course_id act
                                            )
                                    )

                        marks_ix =
                            Debug.log "marks_ix" <|
                                dictFromTupleListMany <|
                                    L.map (\( mark, x, y ) -> ( ( x, y ), SlotMark False mark )) <|
                                        L.filterMap mark_coords marks
                    in
                    ( { model
                        | state = Complete
                        , rows = Debug.log "rows" rows
                        , columns = Debug.log "columns" columns
                        , cells =
                            L.map
                                (\row ->
                                    L.map
                                        (\col ->
                                            case ( row, col ) of
                                                ( Course course, Date date ) ->
                                                    let
                                                        mark_slots =
                                                            M.withDefault [] <| D.get ( String.fromInt <| T.posixToMillis date, get_id_str course ) marks_ix
                                                    in
                                                    mark_slots

                                                ( _, _ ) ->
                                                    []
                                        )
                                        columns
                                )
                                rows
                      }
                    , Cmd.map MsgFetch c
                    )

                ( TaskFinishedAll [ Ok (FetchedCourse course), Ok (FetchedMarks marks) ], _ ) ->
                    let
                        ix_acts =
                            index_by get_id_str course.activities

                        rows =
                            L.map (.person >> User) <| List.sortBy (.person >> user_full_name) course.enrollments

                        columns =
                            L.map Activity <| L.sortBy .order course.activities

                        activity_timestamp act =
                            String.fromInt <| T.posixToMillis act.date

                        mark_coords mark =
                            D.get (Uuid.toString mark.activity) ix_acts
                                |> M.andThen
                                    (\act ->
                                        Just
                                            ( mark
                                            , String.fromInt <| T.posixToMillis act.date
                                            , Uuid.toString mark.student
                                            )
                                    )

                        marks_ix =
                            dictFromTupleListMany <|
                                L.map (\( a, b, c_ ) -> ( ( b, c_ ), SlotMark False a )) <|
                                    L.filterMap mark_coords marks
                    in
                    ( { model
                        | state = Complete
                        , rows = rows
                        , columns = columns
                        , cells =
                            L.map
                                (\row ->
                                    L.map
                                        (\col ->
                                            case ( row, col ) of
                                                ( User student, Activity act ) ->
                                                    let
                                                        mark_slots =
                                                            M.withDefault [] <| D.get ( activity_timestamp act, get_id_str course ) marks_ix
                                                    in
                                                    mark_slots
                                                        ++ L.repeat
                                                            (M.withDefault 0 act.marksLimit - L.length mark_slots)
                                                            (SlotVirtual False (get_id act) (get_id student))

                                                ( _, _ ) ->
                                                    []
                                        )
                                        columns
                                )
                                rows
                      }
                    , Cmd.map MsgFetch c
                    )

                _ ->
                    ( { model | state = Loading m }, Cmd.map MsgFetch c )

        ( MsgFetch msg_, _ ) ->
            ( model, Cmd.none )

        ( MsgMarkArrowClick, _ ) ->
            ( model, Cmd.none )



--(x,y) -> Debug.todo <| Debug.toString (x,y)


viewColumn : Column -> Html Msg
viewColumn column =
    case column of
        Activity activity ->
            viewColumn <| Date activity.date

        Date posix ->
            text <| posixToDDMMYYYY T.utc posix


viewRow : Row -> Html Msg
viewRow row =
    case row of
        User user ->
            a [ href <| "/profile/" ++ get_id_str user ] [ text <| user_full_name user ]

        Course course ->
            a [ href <| "/course/" ++ get_id_str course ] [ text course.title ]


markValueColors : String -> ( String, String )
markValueColors val =
    let
        default =
            ( "#BFC9CA", "#909497" )
    in
    case val of
        "5" ->
            ( "#7DCEA0", "#1E8449" )

        "4" ->
            ( "#76D7C4", "#148F77" )

        "3" ->
            ( "#F7DC6F", "#B7950B" )

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


viewMarkSlot : MarkSlot -> Html Msg
viewMarkSlot markSlot =
    let
        common_style =
            [ style "min-width" "40px"
            , style "max-width" "40px"
            , style "min-height" "40px"
            , style "max-height" "40px"
            , style "margin" "5px"
            ]
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
                 ]
                    ++ common_style
                )
                [ text mark.value ]

        SlotVirtual sel _ _ ->
            let
                own_style =
                    if sel then
                        [ style "background-color" <| Tuple.first markSelectedColors
                        , style "border" ("1px dashed " ++ Tuple.second markSelectedColors)
                        ]

                    else
                        [ style "border" "1px dashed #BFC9CA"
                        ]
            in
            div (own_style ++ common_style) []


viewTableCell : SlotList -> Html Msg
viewTableCell slot_list =
    td []
        [ div [ class "row center-xs" ] <| L.map viewMarkSlot slot_list
        ]


viewTableHeader : List Column -> Html Msg
viewTableHeader columns =
    thead []
        [ tr []
            ((++) [ tr [] [] ] <| L.map (viewColumn >> L.singleton >> td []) columns)
        ]


viewTableRow : ( Row, ColList ) -> Html Msg
viewTableRow ( row, cols ) =
    tr [] ([ td [] [ viewRow row ] ] ++ L.map viewTableCell (Debug.log "cols" cols))


viewTable : List Row -> List Column -> RowList -> Html Msg
viewTable rows columns cells =
    table [ class "ui collapsing celled striped table" ]
        ((++) [ viewTableHeader columns ] <| L.map viewTableRow <| zip rows cells)


view : Model -> Html Msg
view model =
    case model.state of
        Loading model_ ->
            Html.map MsgFetch <| MultiTask.view showFetchedData httpErrorToString model_

        Complete ->
            if model.rows == [] || model.columns == [] then
                h3 [] [ text "Нет данных" ]

            else
                viewTable model.rows model.columns model.cells

        Error string ->
            text string

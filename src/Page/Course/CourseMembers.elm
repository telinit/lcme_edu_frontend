module Page.Course.CourseMembers exposing (..)

import Api exposing (ext_task)
import Api.Data exposing (CourseEnrollmentRead, CourseEnrollmentReadRole(..), CourseEnrollmentWrite, CourseEnrollmentWriteRole(..), UserShallow)
import Api.Request.Course exposing (courseEnrollmentCreate, courseEnrollmentDelete)
import Component.List.User as LU
import Component.Misc exposing (user_link)
import Component.MultiTask as MT
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Svg.Styled.Attributes exposing (result)
import Task
import Util exposing (get_id_str, httpErrorToString, user_full_name)
import Uuid exposing (Uuid)


type Msg
    = MsgOnClickAddTeacher
    | MsgOnClickAddStudent
    | MsgOnClickRemoveEnrollment CourseEnrollmentRead
    | MsgUserList LU.Msg
    | MsgRemoveFinished CourseEnrollmentRead (Result String ())
    | MsgOnClickBackToList
    | MsgOnClickAddMembers
    | MsgEnrolling (MT.Msg Http.Error CourseEnrollmentWrite)


type alias RemovingState =
    Dict String (Maybe String)


type State
    = StateList RemovingState
    | StateAddMemberSelection CourseEnrollmentReadRole LU.Model
    | StateEnrolling (MT.Model Http.Error CourseEnrollmentWrite)


type alias Model =
    { token : String
    , courseID : Maybe Uuid
    , canManageTeachers : Bool
    , canManageStudents : Bool
    , state : State
    , enrollments : List CourseEnrollmentRead
    }


findEnrollments : CourseEnrollmentReadRole -> String -> List CourseEnrollmentRead -> List CourseEnrollmentRead
findEnrollments role uid enrollments =
    List.filter (\enr -> enr.role == role && get_id_str enr.person == uid) enrollments


doRemove : Model -> List CourseEnrollmentRead -> Cmd Msg
doRemove model enrs =
    let
        cmdDelEnr : CourseEnrollmentRead -> Cmd Msg
        cmdDelEnr enr =
            Task.attempt (MsgRemoveFinished enr) <|
                Task.mapError httpErrorToString <|
                    ext_task identity model.token [] <|
                        courseEnrollmentDelete <|
                            get_id_str enr
    in
    Cmd.batch <|
        List.map cmdDelEnr enrs

enrollmentRoleR2W : CourseEnrollmentWriteRole -> CourseEnrollmentReadRole
enrollmentRoleR2W r =
    case r of
        CourseEnrollmentWriteRoleT ->
            CourseEnrollmentReadRoleT

        CourseEnrollmentWriteRoleS ->
            CourseEnrollmentReadRoleS

--enrollmentR2W : CourseEnrollmentRead -> CourseEnrollmentWrite
--enrollmentR2W enr =
--    { id = enr.id
--    , person  = enr.person.id
--    , createdAt  = enr.createdAt
--    , updatedAt = enr.updatedAt
--    , role = enrollmentRoleR2W enr.role
--    , finishedOn = enr.finishedOn
--    , course = enr.course
--    }


getTeachers : Model -> List CourseEnrollmentRead
getTeachers model =
    List.filter (.role >> (==) CourseEnrollmentReadRoleT) model.enrollments


getStudents : Model -> List CourseEnrollmentRead
getStudents model =
    List.filter (.role >> (==) CourseEnrollmentReadRoleS) model.enrollments


init : String -> Maybe Uuid -> List CourseEnrollmentRead -> Bool -> Bool -> ( Model, Cmd Msg )
init token courseID enr isTeacher isStaff =
    ( { canManageTeachers = isStaff
      , canManageStudents = isTeacher || isStaff
      , state = StateList Dict.empty
      , token = token
      , enrollments = enr
      , courseID = courseID
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        _ =
            Debug.log "CourseMembers.update" ( msg, model )
    in
    case msg of
        MsgOnClickAddTeacher ->
            let
                ( m, c ) =
                    LU.init model.token
            in
            ( { model | state = StateAddMemberSelection CourseEnrollmentReadRoleT m }, Cmd.map MsgUserList c )

        MsgOnClickAddStudent ->
            let
                ( m, c ) =
                    LU.init model.token
            in
            ( { model | state = StateAddMemberSelection CourseEnrollmentReadRoleS m }, Cmd.map MsgUserList c )

        MsgOnClickRemoveEnrollment enr ->
            case model.state of
                StateList removingState ->
                    ( { model
                        | state =
                            StateList <|
                                Dict.update (get_id_str enr) (\_ -> Just Nothing) removingState
                      }
                    , doRemove model [ enr ]
                    )

                StateAddMemberSelection _ _ ->
                    ( model, Cmd.none )

                StateEnrolling _ ->
                    ( model, Cmd.none )

        MsgUserList msg_ ->
            case model.state of
                StateAddMemberSelection r model_ ->
                    let
                        ( m, c ) =
                            LU.update msg_ model_
                    in
                    ( { model | state = StateAddMemberSelection r m }, Cmd.map MsgUserList c )

                StateList _ ->
                    ( model, Cmd.none )

                StateEnrolling _ ->
                    ( model, Cmd.none )

        MsgRemoveFinished enr result ->
            case result of
                Ok _ ->
                    let
                        model_ =
                            { model | enrollments = List.filter ((/=) enr) model.enrollments }
                    in
                    case model_.state of
                        StateList removing ->
                            ( { model_ | state = StateList <| Dict.remove (get_id_str enr) removing }, Cmd.none )

                        StateAddMemberSelection _ _ ->
                            ( model_, Cmd.none )

                        StateEnrolling _ ->
                            ( model, Cmd.none )

                Err error ->
                    case model.state of
                        StateList removing ->
                            ( { model | state = StateList <| Dict.update (get_id_str enr) (\_ -> Just (Just error)) removing }, Cmd.none )

                        StateAddMemberSelection _ _ ->
                            ( model, Cmd.none )

                        StateEnrolling _ ->
                            ( model, Cmd.none )

        MsgOnClickBackToList ->
            case model.state of
                StateList _ ->
                    ( model, Cmd.none )

                StateAddMemberSelection _ _ ->
                    ( { model | state = StateList Dict.empty }, Cmd.none )

                StateEnrolling _ ->
                    ( model, Cmd.none )

        MsgOnClickAddMembers ->
            case model.state of
                StateList _ ->
                    ( model, Cmd.none )

                StateAddMemberSelection role userList ->
                    let
                        users =
                            Dict.values userList.selected

                        role2 =
                            case role of
                                CourseEnrollmentReadRoleT ->
                                    CourseEnrollmentWriteRoleT

                                CourseEnrollmentReadRoleS ->
                                    CourseEnrollmentWriteRoleS

                        taskAddEnr user =
                            case ( model.courseID, user.id ) of
                                ( Just cid, Just uid ) ->
                                    Just <|
                                        ext_task identity model.token [] <|
                                            courseEnrollmentCreate
                                                { id = Nothing
                                                , createdAt = Nothing
                                                , updatedAt = Nothing
                                                , role = role2
                                                , finishedOn = Nothing
                                                , person = uid
                                                , course = cid
                                                }

                                _ ->
                                    Nothing

                        ( m, c ) =
                            MT.init <|
                                List.filterMap
                                    (\u ->
                                        Maybe.map (\t -> ( t, "Добавляем пользователя " ++ user_full_name u )) <| taskAddEnr u
                                    )
                                    users
                    in
                    ( { model | state = StateEnrolling m }, Cmd.map MsgEnrolling c )

                StateEnrolling _ ->
                    ( model, Cmd.none )

        MsgEnrolling msg_ ->
            case model.state of
                StateEnrolling model_ ->
                    let
                        ( m, c ) =
                            MT.update msg_ model_
                    in
                    case msg_ of
                        _ ->
                            ( { model | state = StateEnrolling m }, Cmd.map MsgEnrolling c )

                StateList _ ->
                    ( model, Cmd.none )

                StateAddMemberSelection _ _ ->
                    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    let
        user_list : Maybe (CourseEnrollmentRead -> Msg) -> RemovingState -> List CourseEnrollmentRead -> List (Html Msg)
        user_list mbDeleteMsg removingState =
            let
                removeButton enr =
                    case ( mbDeleteMsg, Dict.get (get_id_str enr) removingState ) of
                        ( Nothing, _ ) ->
                            text ""

                        ( _, Just Nothing ) ->
                            div [ class "ui text loader" ] []

                        ( Just msg, _ ) ->
                            button [ class "ui basic icon button red", onClick (msg enr) ] [ i [ class "minus icon" ] [] ]

                removeStatus enr =
                    case Dict.get (get_id_str enr) removingState of
                        Just state ->
                            case state of
                                Just err ->
                                    div [ class "ui segment", style "margin" "0" ] [ text <| "Не удалось удалить: " ++ err ]

                                Nothing ->
                                    div [ class "ui segment", style "margin" "0" ] [ text "Удаляем..." ]

                        Nothing ->
                            text ""
            in
            List.sortBy (.person >> user_full_name)
                >> List.map
                    (\enr ->
                        div [ class "row between-xs middle-xs" ]
                            [ div [ style "margin" "1em" ]
                                [ removeButton enr
                                , span [ style "font-size" "16pt" ] [ user_link Nothing enr.person ]
                                ]
                            , removeStatus enr
                            ]
                    )
    in
    case model.state of
        StateList removing ->
            div []
                [ h3 [ class "row between-xs middle-xs" ]
                    [ text "Преподаватели"
                    , if model.canManageTeachers then
                        button [ class "ui button green", onClick MsgOnClickAddTeacher ] [ i [ class "plus icon" ] [], text "Добавить" ]

                      else
                        text ""
                    ]
                , div [ style "padding-left" "1em" ] <|
                    user_list
                        (if model.canManageTeachers then
                            Just MsgOnClickRemoveEnrollment

                         else
                            Nothing
                        )
                        removing
                    <|
                        getTeachers model
                , h3 [ class "row between-xs middle-xs" ]
                    [ text "Учащиеся"
                    , if model.canManageStudents then
                        button [ class "ui button green", onClick MsgOnClickAddStudent ] [ i [ class "plus icon" ] [], text "Добавить" ]

                      else
                        text ""
                    ]
                , div [ style "padding-left" "1em" ] <|
                    user_list
                        (if model.canManageStudents then
                            Just MsgOnClickRemoveEnrollment

                         else
                            Nothing
                        )
                        removing
                    <|
                        getStudents model
                ]

        StateAddMemberSelection r model_ ->
            let
                sRole =
                    case r of
                        CourseEnrollmentReadRoleT ->
                            "преподавателей"

                        CourseEnrollmentReadRoleS ->
                            "учащихся"

                controls =
                    div []
                        [ button
                            [ class "ui button"
                            , onClick MsgOnClickBackToList
                            ]
                            [ i [ class "arrow left icon" ] []
                            , text "Назад"
                            ]
                        , button
                            [ class "ui button green"
                            , classList [ ( "disabled", Dict.isEmpty model_.selected ) ]
                            , onClick MsgOnClickAddMembers
                            ]
                            [ i [ class "plus icon" ] []
                            , text "Добавить"
                            ]
                        ]
            in
            div []
                [ h3 [ class "row between-xs middle-xs" ] [ text <| "Добавить " ++ sRole, controls ]
                , Html.map MsgUserList <| LU.view model_
                ]

        StateEnrolling model_ ->
            div []
                [ h3 [ class "row between-xs middle-xs" ] [ text "Выполняем запись на курс" ]
                , Html.map MsgEnrolling <| MT.view (\_ -> "OK") httpErrorToString model_
                ]

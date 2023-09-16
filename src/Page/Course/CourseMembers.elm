module Page.Course.CourseMembers exposing (..)

import Api exposing (ext_task)
import Api.Data exposing (CourseEnrollmentRead, CourseEnrollmentReadRole(..), CourseEnrollmentWrite, CourseEnrollmentWriteRole(..), UserShallow)
import Api.Request.Course exposing (courseEnrollmentCreate, courseEnrollmentDelete, courseEnrollmentPartialUpdate, courseEnrollmentUpdate)
import Component.List.User as LU
import Component.Misc exposing (user_link)
import Component.MultiTask as MT
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Random
import Svg.Styled.Attributes exposing (result)
import Task
import Time
import Util exposing (get_id_str, httpErrorToString, randomGenerateTask, user_full_name)
import Uuid exposing (Uuid)


type Msg
    = MsgOnClickAddMember CourseEnrollmentReadRole
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
                    Task.andThen
                        (\now ->
                            Task.andThen
                                (\fake_uuid ->
                                    ext_task (\_ -> ()) model.token [] <|
                                        courseEnrollmentUpdate (get_id_str enr)
                                            { id = Nothing
                                            , createdAt = Nothing
                                            , updatedAt = Nothing
                                            , role = enrollmentRoleR2W enr.role
                                            , person = Maybe.withDefault fake_uuid enr.person.id -- FIXME: A Person record always has an ID but the API generator makes it a Maybe thing. Hence this workaround
                                            , course = enr.course
                                            , finishedOn = Just now
                                            }
                                )
                                (randomGenerateTask Uuid.uuidGenerator)
                        )
                        Time.now
    in
    Cmd.batch <|
        List.map cmdDelEnr enrs


enrollmentRoleW2R : CourseEnrollmentWriteRole -> CourseEnrollmentReadRole
enrollmentRoleW2R r =
    case r of
        CourseEnrollmentWriteRoleT ->
            CourseEnrollmentReadRoleT

        CourseEnrollmentWriteRoleS ->
            CourseEnrollmentReadRoleS

        CourseEnrollmentWriteRoleM ->
            CourseEnrollmentReadRoleM

        CourseEnrollmentWriteRoleO ->
            CourseEnrollmentReadRoleO

        CourseEnrollmentWriteRoleL ->
            CourseEnrollmentReadRoleL


enrollmentRoleR2W : CourseEnrollmentReadRole -> CourseEnrollmentWriteRole
enrollmentRoleR2W r =
    case r of
        CourseEnrollmentReadRoleT ->
            CourseEnrollmentWriteRoleT

        CourseEnrollmentReadRoleS ->
            CourseEnrollmentWriteRoleS

        CourseEnrollmentReadRoleM ->
            CourseEnrollmentWriteRoleM

        CourseEnrollmentReadRoleO ->
            CourseEnrollmentWriteRoleO

        CourseEnrollmentReadRoleL ->
            CourseEnrollmentWriteRoleL


getEnrollmentsByRole : Model -> CourseEnrollmentReadRole -> List CourseEnrollmentRead
getEnrollmentsByRole model role =
    List.filter (.role >> (==) role) model.enrollments


getTeachers : Model -> List CourseEnrollmentRead
getTeachers model =
    getEnrollmentsByRole model CourseEnrollmentReadRoleT


getStudents : Model -> List CourseEnrollmentRead
getStudents model =
    getEnrollmentsByRole model CourseEnrollmentReadRoleS


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
        ignore =
            ( model, Cmd.none )
    in
    case msg of
        MsgOnClickAddMember role ->
            let
                ( m, c ) =
                    LU.init model.token
            in
            ( { model | state = StateAddMemberSelection role m }, Cmd.map MsgUserList c )

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
                    ignore

                StateEnrolling _ ->
                    ignore

        MsgUserList msg_ ->
            case model.state of
                StateAddMemberSelection r model_ ->
                    let
                        ( m, c ) =
                            LU.update msg_ model_
                    in
                    ( { model | state = StateAddMemberSelection r m }, Cmd.map MsgUserList c )

                StateList _ ->
                    ignore

                StateEnrolling _ ->
                    ignore

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
                            ignore

                        StateEnrolling _ ->
                            ignore

                Err error ->
                    case model.state of
                        StateList removing ->
                            ( { model
                                | state =
                                    StateList <|
                                        Dict.update (get_id_str enr) (\_ -> Just (Just error)) removing
                              }
                            , Cmd.none
                            )

                        StateAddMemberSelection _ _ ->
                            ignore

                        StateEnrolling _ ->
                            ignore

        MsgOnClickBackToList ->
            case model.state of
                StateList _ ->
                    ignore

                StateAddMemberSelection _ _ ->
                    ( { model | state = StateList Dict.empty }, Cmd.none )

                StateEnrolling _ ->
                    ( { model | state = StateList Dict.empty }, Cmd.none )

        MsgOnClickAddMembers ->
            case model.state of
                StateList _ ->
                    ignore

                StateAddMemberSelection role userList ->
                    let
                        users =
                            Dict.values userList.selected

                        taskAddEnr user =
                            case ( model.courseID, user.id ) of
                                ( Just cid, Just uid ) ->
                                    Just <|
                                        ext_task identity model.token [] <|
                                            courseEnrollmentCreate
                                                { id = Nothing
                                                , createdAt = Nothing
                                                , updatedAt = Nothing
                                                , role = enrollmentRoleR2W role
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
                    ignore

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
                    ignore

                StateAddMemberSelection _ _ ->
                    ignore


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
        StateList removing_state ->
            let
                list_segment : String -> Maybe Msg -> Maybe (CourseEnrollmentRead -> Msg) -> List CourseEnrollmentRead -> List (Html Msg)
                list_segment label mbMsgAdd mbMsgDel enrollments =
                    [ h3 [ class "row between-xs middle-xs" ]
                        [ text label
                        , Maybe.withDefault (text "") <|
                            Maybe.map
                                (\msg ->
                                    button [ class "ui button green", onClick msg ] [ i [ class "plus icon" ] [], text "Добавить" ]
                                )
                                mbMsgAdd
                        ]
                    , div [ style "padding-left" "1em" ] <|
                        if enrollments == [] then
                            [ span [ style "font-size" "16pt" ] [ text "(нет)" ] ]

                        else
                            user_list
                                mbMsgDel
                                removing_state
                                enrollments
                    ]

                list_segment2 label role canManage =
                    let
                        enr =
                            getEnrollmentsByRole model role
                    in
                    if enr == [] && not canManage then
                        []

                    else
                        list_segment label
                            (if canManage then
                                Just (MsgOnClickAddMember role)

                             else
                                Nothing
                            )
                            (if canManage then
                                Just MsgOnClickRemoveEnrollment

                             else
                                Nothing
                            )
                            enr
            in
            div []
                (list_segment2 "Менеджеры" CourseEnrollmentReadRoleM model.canManageTeachers
                    ++ list_segment2 "Наблюдатели" CourseEnrollmentReadRoleO model.canManageTeachers
                    ++ list_segment2 "Преподаватели" CourseEnrollmentReadRoleT model.canManageTeachers
                    ++ list_segment2 "Учащиеся" CourseEnrollmentReadRoleS model.canManageStudents
                    ++ list_segment2 "Вольные слушатели" CourseEnrollmentReadRoleL model.canManageStudents
                )

        StateAddMemberSelection r model_ ->
            let
                sRole =
                    case r of
                        CourseEnrollmentReadRoleT ->
                            "преподавателей"

                        CourseEnrollmentReadRoleS ->
                            "учащихся"

                        CourseEnrollmentReadRoleM ->
                            "менеджеров"

                        CourseEnrollmentReadRoleO ->
                            "наблюдателей"

                        CourseEnrollmentReadRoleL ->
                            "вольных слушателей"

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
            div [] <|
                [ h3 [ class "row between-xs middle-xs" ] [ text "Выполняем запись на курс" ]
                , Html.map MsgEnrolling <| MT.view (\_ -> "OK") httpErrorToString model_
                ]
                    ++ (if MT.hasError model_ then
                            [ div [ class "row center-xs" ]
                                [ button [ class "ui button", onClick MsgOnClickBackToList ]
                                    [ i [ class "arrow left icon" ] []
                                    , text "Назад"
                                    ]
                                ]
                            ]

                        else
                            []
                       )

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
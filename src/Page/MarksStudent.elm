module Page.MarksStudent exposing (..)

import Api exposing (ext_task)
import Api.Data exposing (UserDeep, UserShallow)
import Api.Request.User exposing (userRead)
import Component.MarkTable as MT
import Component.Misc exposing (user_link)
import Html exposing (Html, div, h1, h2, h3, span, text)
import Html.Attributes exposing (class, style)
import Http
import Task
import Util exposing (user_deep_to_shallow, user_has_any_role)
import Uuid exposing (Uuid)


type Msg
    = MsgTable MT.Msg
    | MsgStudentFetchFinished (Result Http.Error UserShallow)


type State
    = MarksTable MT.Model
    | StudentSelection


type alias Model =
    { state : State
    , token : String
    , user : UserDeep
    , student : Maybe UserShallow
    }


init : String -> UserDeep -> Maybe Uuid -> ( Model, Cmd Msg )
init token user mb_student_id =
    let
        student_id : Maybe Uuid
        student_id =
            case ( mb_student_id, user.children ) of
                ( Just _, _ ) ->
                    mb_student_id

                ( Nothing, [ child ] ) ->
                    child.id

                ( _, _ ) ->
                    if user_has_any_role user [ "student" ] then
                        user.id

                    else
                        Nothing
    in
    case student_id of
        Just id ->
            let
                ( m, c ) =
                    MT.initForStudent token id

                student =
                    List.head <|
                        List.filter (.id >> (==) student_id) <|
                            [ user_deep_to_shallow user ]
                                ++ user.children

                fetchStudent =
                    if student == Nothing then
                        Task.attempt MsgStudentFetchFinished <|
                            ext_task identity token [] <|
                                userRead (Uuid.toString id)

                    else
                        Cmd.none
            in
            ( { state = MarksTable m, token = token, user = user, student = student }, Cmd.batch [ Cmd.map MsgTable c, fetchStudent ] )

        Nothing ->
            ( { state = StudentSelection, token = token, user = user, student = Nothing }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        ignore =
            ( model, Cmd.none )

        _ = Debug.log "update" ( msg, model )
    in
    case ( msg, model.state ) of
        ( MsgTable msg_, MarksTable t ) ->
            let
                ( m, c ) =
                    MT.update msg_ t
            in
            ( { model | state = MarksTable m }, Cmd.map MsgTable c )

        ( MsgTable _, StudentSelection ) ->
            ignore

        ( MsgStudentFetchFinished r, MarksTable _ ) ->
            case r of
                Ok student ->
                    ( { model | student = Just student }, Cmd.none )

                Err _ ->
                    ignore

        ( MsgStudentFetchFinished _, StudentSelection ) ->
            ignore


view : Model -> Html Msg
view model =
    case model.state of
        MarksTable t ->
            div []
                [ Maybe.withDefault (text "") <|
                    Maybe.map
                        (\u ->
                            div []
                                [ h3 [ class "row center-xs middle-xs" ]
                                    [ span [ class "mr-5" ] [ text "Учащийся: " ]
                                    , user_link Nothing u
                                    ]
                                ]
                        )
                        model.student
                , div [ class "row center-xs" ]
                    [ div
                        [ class "col"
                        ]
                        [ Html.map MsgTable <| MT.view t ]
                    ]
                ]

        StudentSelection ->
            let
                self_is_student =
                    List.member "student" <| Maybe.withDefault [] model.user.roles

                lnk user =
                    user_link (Just <| "/marks/student/" ++ (Maybe.withDefault "" <| Maybe.map Uuid.toString user.id)) user
            in
            div [ class "row center-xs" ]
                [ div [ class "col" ] <|
                    List.filterMap identity <|
                        [ Just <| h1 [] [ text "Выберите учащегося" ]
                        , if self_is_student then
                            Just (div [ class "row", style "margin" "1em" ] [ lnk <| user_deep_to_shallow model.user ])

                          else
                            Nothing
                        ]
                            ++ List.map (\child -> Just <| div [ class "row", style "margin" "1em" ] [ lnk child ]) model.user.children
                ]

module Page.MarksStudent exposing (..)

import Api.Data exposing (UserDeep)
import Component.MarkTable as MT
import Component.Misc exposing (user_link)
import Html exposing (Html, div, h1, h2, text)
import Html.Attributes exposing (class, style)
import Util exposing (get_id_str, user_deep_to_shallow, user_has_any_role)
import Uuid exposing (Uuid)


type Msg
    = MsgTable MT.Msg


type State
    = MarksTable MT.Model
    | StudentSelection


type alias Model =
    { state : State
    , token : String
    , user : UserDeep
    }


init : String -> UserDeep -> Maybe Uuid -> ( Model, Cmd Msg )
init token user mb_student_id =
    let
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
    case Debug.log "student_id" student_id of
        Just id ->
            let
                ( m, c ) =
                    MT.initForStudent token id
            in
            ( { state = MarksTable m, token = token, user = user }, Cmd.map MsgTable c )

        Nothing ->
            ( { state = StudentSelection, token = token, user = user }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.state ) of
        ( MsgTable msg_, MarksTable t ) ->
            let
                ( m, c ) =
                    MT.update msg_ t
            in
            ( { model | state = MarksTable m }, Cmd.map MsgTable c )

        ( MsgTable _, StudentSelection ) ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    case model.state of
        MarksTable t ->
            div [ class "row center-xs" ] [ Html.map MsgTable <| MT.view t ]

        StudentSelection ->
            let
                self_is_student =
                    List.member "student" <| Maybe.withDefault [] model.user.roles

                lnk user =
                    user_link (Just <| "/marks/student/" ++ get_id_str user) user
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

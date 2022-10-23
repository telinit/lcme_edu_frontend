module Page.MarksCourse exposing (..)

import Component.MarkTable as MT
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)


type Msg
    = MsgTable MT.Msg


type alias Model =
    { table : MT.Model
    , token : String
    }


init : String -> String -> ( Model, Cmd Msg )
init token course_id =
    let
        ( m, c ) =
            MT.initForCourse token course_id
    in
    ( { table = m, token = token }, Cmd.map MsgTable c )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MsgTable msg_ ->
            let
                ( m, c ) =
                    MT.update msg_ model.table
            in
            ( { model | table = m }, Cmd.map MsgTable c )


view : Model -> Html Msg
view model =
    div [ class "row center-xs" ] [ Html.map MsgTable <| MT.view model.table ]

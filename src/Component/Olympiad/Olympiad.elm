module Olympiad exposing (..)

import Html exposing (Html, text)


type Msg
    = Msg


type Model
    = Model


init : () -> ( Model, Cmd Msg )
init () =
    ( Model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( Model, Cmd.none )


view : Model -> Html Msg
view model =
    text ""

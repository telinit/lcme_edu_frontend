module Page.Admin.Test exposing (..)

import Component.FileManager as FileManager
import Component.UI.Common exposing (Action(..), IconType(..), Size(..))
import Component.UI.IconMenu as IconMenu
import Html exposing (..)
import Html.Attributes exposing (..)


type alias Model =
    { fm : FileManager.Model
    }


type Msg
    = MsgFM FileManager.Msg

type alias APIToken = String

init : APIToken -> ( Model, Cmd Msg )
init token =
    let
        ( m, c ) =
            FileManager.init token Nothing
    in
    ( { fm = m }, Cmd.map MsgFM c )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MsgFM msg_ ->
            let
                ( m, c ) =
                    FileManager.update msg_ model.fm
            in
            ( { fm = m }, Cmd.map MsgFM c )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Html Msg
view model =
    div [style "width" "100%"]
        [ Html.map MsgFM <| FileManager.view model.fm ]

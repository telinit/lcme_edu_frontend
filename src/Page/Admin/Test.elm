module Page.Admin.Test exposing (..)

import Component.FileManager as FileManager
import Component.UI.Common exposing (Action(..), IconType(..), Size(..))
import Component.UI.IconMenu as IconMenu
import Component.UI.ProgressBar as ProgressBar exposing (Progress(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Random
import Time exposing (Posix)


type alias Model =
    { fm : FileManager.Model
    , pb : ProgressBar.Model
    }


type Msg
    = MsgFM FileManager.Msg


type alias APIToken =
    String


init : APIToken -> ( Model, Cmd Msg )
init token =
    let
        ( m, c ) =
            FileManager.init token Nothing

        pb_ =
            ProgressBar.init 0
    in
    ( { fm = m
      , pb =
            { pb_
                | isActive = True
                , color = Just "green"
                , showProgress = Just ProgressPercents
                , label = Just "test test"
                , size = Just Small
            }
      }
    , Cmd.map MsgFM c
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MsgFM msg_ ->
            let
                ( m, c ) =
                    FileManager.update msg_ model.fm
            in
            ( { model | fm = m }, Cmd.map MsgFM c )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Html Msg
view model =
    div [ style "width" "100%" ]
        [ Html.map MsgFM <| FileManager.view model.fm
        ]

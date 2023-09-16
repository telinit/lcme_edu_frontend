module Component.UI.FileInput exposing (..)

import File exposing (File)
import File.Select
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Util exposing (fileSizeToISO)


type Msg
    = MsgDoSelectFile
    | MsgFileSelected File


type alias Model =
    { prompt : String
    , file : Maybe File
    , mimes : List String
    }


init : Maybe String -> List String -> ( Model, Cmd Msg )
init prompt mimes =
    ( { prompt = Maybe.withDefault "Выберите файл" prompt
      , file = Nothing
      , mimes = mimes
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MsgDoSelectFile ->
            ( model, File.Select.file model.mimes MsgFileSelected )

        MsgFileSelected file ->
            ( { model | file = Just file }, Cmd.none )


view : Model -> Html Msg
view model =
    let
        sel =
            case model.file of
                Just f ->
                    [ div []
                        [ strong [ class "pr-5" ] [ text "Имя:" ]
                        , text <| File.name f
                        ]

                    --, div [] [ text <| File.mime f ]
                    , div []
                        [ strong [ class "pr-5" ] [ text "Размер:" ]
                        , text <| fileSizeToISO <| File.size f
                        ]
                    ]

                Nothing ->
                    [ div [] [ text model.prompt ] ]
    in
    div [ class "ui segment", style "cursor" "pointer", onClick MsgDoSelectFile ]
        [ div [ class "row middle-xs center-xs" ]
            [ div [ class "col", style "font-size" "24pt" ]
                [ i [ class "file icon" ] []
                ]
            , div [ class "col" ]
                sel
            ]
        ]

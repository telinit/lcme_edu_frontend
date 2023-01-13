module Page.Admin.ExportMarks exposing (..)

import File.Download
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type Msg
    = MsgDownload String


type Model
    = Model


init : () -> ( Model, Cmd Msg )
init () =
    ( Model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MsgDownload url ->
            ( model, File.Download.url url )


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Экспорт оценок" ]
        , p [] [ text "Для экспорта оценок из дневника в различных форматах поспользуйтесь ссылками ниже:" ]
        , div [ class "row start-xs center-sm" ]
            [ div [ class "col-xs-12 start-xs pl-20" ]
                [ a [ class "", href "/api/mark/export?type=csv_full", target "_blank", style "display" "block" ]
                    [ i [ class "icon file excel", style "font-size" "16pt" ] []
                    , text "Все учащиеся в одной таблице (CSV)"
                    ]
                , a [ class "", href "/api/mark/export?type=csv_archive", target "_blank", style "display" "block" ]
                    [ i [ class "icon file archive", style "font-size" "16pt" ] []
                    , text "Все учащиеся в архиве с разделением по учащимся (ZIP)"
                    ]
                ]
            ]
        ]

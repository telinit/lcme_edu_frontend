module Page.NotFound exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


view =
    div
        [ class "ui middle aligned center aligned grid"
        , style "height" "100%"
        , style "background-color" "#EEE"
        ]
        [ div [ class "column" ]
            [ h1 [] [ text "Страница не найдена" ]
            , a [ class "ui large blue submit button", href "/" ] [ text "На главную" ]
            ]
        ]

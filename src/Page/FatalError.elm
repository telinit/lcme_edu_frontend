module Page.FatalError exposing (..)

import Html exposing (Html, div, h1, h3, p, pre, text)
import Html.Attributes exposing (class, style)


view : String -> Html a
view data =
    div []
        [ h1 [] [ text "Произошла фатальная ошибка" ]
        , p [] [text "Просим отправить информацию о произошедшем на sysadmin@lnmo.ru"]
        , h3 [] [ text "Данные для разработчика:" ]
        , div
            [ class "ui segment"
            , style "max-width" "60%"
            , style "font-family" "monospace"
            , style "margin" "15px"
            , style "padding" "10px"
            ]
            [ text data
            ]
        ]

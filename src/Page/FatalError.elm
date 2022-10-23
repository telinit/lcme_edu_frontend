module Page.FatalError exposing (..)

import Html exposing (Html, div, h1, h3, pre, text)


view : String -> Html a
view data = div [] [
        h1 [] [text "Произошла фатальная ошибка"],
        h3 [] [text "Данные для разработчика:"],
        pre [] [text data]
    ]
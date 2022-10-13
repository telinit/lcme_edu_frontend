module Util exposing (..)

import Http


httpErrorToString : Http.Error -> String
httpErrorToString error =
    case error of
        Http.BadUrl url ->
            "Некорректный адрес: " ++ url

        Http.Timeout ->
            "Таймаут"

        Http.NetworkError ->
            "Сетевая ошибка"

        Http.BadStatus code ->
            "Код ошибки: " ++ String.fromInt code

        Http.BadBody s ->
            "Некорректный формат данных: " ++ s

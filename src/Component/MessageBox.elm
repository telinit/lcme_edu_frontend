module Component.MessageBox exposing (..)

import Html exposing (Html, div, i, p, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


type Type
    = None
    | Success
    | Error
    | Warning


view : Type -> Maybe msg -> Html msg -> Html msg -> Html msg
view type_ onClose header body =
    let
        type_class =
            case type_ of
                None ->
                    ""

                Success ->
                    ""

                Error ->
                    ""

                Warning ->
                    ""

        close_button =
            case onClose of
                Just msg ->
                    [ i [ class "close icon", onClick msg ] [] ]

                Nothing ->
                    []
    in
    div [ class ("ui negative message " ++ type_class) ]
        (close_button
            ++ [ div [ class "header" ] [ header ]
               , p [] [ body ]
               ]
        )

module Component.MessageBox exposing (..)

import Html exposing (Html, div, i, p, text)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)


type Type
    = None
    | Success
    | Error
    | Warning


view : Type -> Bool -> Maybe msg -> Html msg -> Html msg -> Html msg
view type_ isLoading onClose header body =
    let
        type_class =
            case type_ of
                None ->
                    ""

                Success ->
                    "positive"

                Error ->
                    "negative"

                Warning ->
                    "warning"

        close_button =
            case onClose of
                Just msg ->
                    [ i [ class "close icon", onClick msg ] [] ]

                Nothing ->
                    []
    in
    div [ class ("ui message " ++ type_class) ]
        (close_button
            ++ [ div [ class "header" ] [ header ]
               , div []
                    [ if isLoading then
                        div [ class "ui active inline loader small", style "margin-right" "1em" ] []

                      else
                        text ""
                    , body
                    ]
               ]
        )

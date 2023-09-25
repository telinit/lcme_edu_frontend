module Component.Modal exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, stopPropagationOn)
import Json.Decode


view id_ title body_ msg_close buttons do_show =
    if do_show then
        div
            [ class "ui dimmer"
            , style "opacity" "initial"
            , style "position" "fixed"
            , style "display" "flex"
            ]
            [ div
                [ class "ui longer modal"
                , style "display" "initial"
                , style "max-height" "90vh"
                , style "overflow-y" "scroll"
                , id id_
                ]
                [ div [ class "header" ]
                    [ div [ class "row between-xs" ]
                        [ text title
                        , i
                            [ class "close icon"
                            , onClick msg_close
                            , style "cursor" "pointer"
                            ]
                            []
                        ]
                    ]
                , div [ class "content" ]
                    [ body_
                    ]
                , div [ class "actions" ]
                    (List.map
                        (\( label, msg ) ->
                            div [ class "ui button", onClick msg ]
                                [ text label ]
                        )
                        buttons
                    )
                ]
            ]

    else
        text ""


viewInline body =
    div
        [ style "width" "100%"
        , style "height" "100%"
        , style "background" "rgba(0, 0, 0, 0.5)"
        , style "z-index" "10"
        , style "position" "absolute"
        , class "row center-xs middle-xs m-0"
        ]
        [ div
            [ class "col ui modal"
            , style "background" "white"
            , style "display" "initial"
            ]
            [ div [ class "header" ] [ text "header" ]
            , div [ class "content" ] [ body ]
            , div [ class "actions" ] [ text "123" ]
            ]
        ]

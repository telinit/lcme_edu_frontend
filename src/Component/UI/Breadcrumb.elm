module Component.UI.Breadcrumb exposing (..)

import Component.UI.Common exposing (Action(..), IconType, viewIcon)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Util exposing (Either, maybeToList)


type alias Item msg =
    { label : String
    , icon : Maybe (IconType msg)
    , onClick : Maybe (Action msg)
    }


viewItem : Item msg -> Bool -> Html msg
viewItem item isActive =
    let
        cls =
            (if isActive then
                "active "

             else
                ""
            )
                ++ "section"

        ico =
            maybeToList <| Maybe.map viewIcon item.icon
    in
    case item.onClick of
        Nothing ->
            span [ class cls ] <| ico ++ [ text item.label ]

        Just (ActionGotoLink url) ->
            a [ class cls, href url ] <| ico ++ [ text item.label ]

        Just (ActionMessage msg) ->
            span [ class cls, onClick msg, style "cursor" "pointer" ] <| ico ++ [ text item.label ]


view : List (Item msg) -> Html msg
view =
    let
        view1 items_ =
            case items_ of
                [] ->
                    []

                [ hd ] ->
                    [ viewItem hd True ]

                hd :: tl ->
                    [ viewItem hd False, i [ class "right chevron icon divider" ] [] ] ++ view1 tl
    in
    div [ class "ui large breadcrumb" ] << view1

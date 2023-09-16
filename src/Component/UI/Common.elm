module Component.UI.Common exposing (..)

import Html exposing (Html, div, i)
import Html.Attributes exposing (class)


type Side
    = Left
    | Right


type Size
    = Mini
    | Small
    | Large
    | Big
    | Huge
    | Massive


type IconType msg
    = IconGeneric String Color
    | IconCustom (Html msg)


type alias CSSValue =
    String


type alias Color =
    String


type Action msg
    = ActionGotoLink String
    | ActionMessage msg


size2String : Size -> String
size2String size =
    case size of
        Mini ->
            "mini"

        Small ->
            "small"

        Large ->
            "large"

        Big ->
            "big"

        Huge ->
            "huge"

        Massive ->
            "massive"


viewIcon : IconType msg -> Html msg
viewIcon iconType =
    case iconType of
        IconGeneric name color ->
            i [ class <| name ++ " icon " ++ color ] []

        IconCustom html ->
            div [ class "icon" ] [ html ]

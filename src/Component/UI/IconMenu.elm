module Component.UI.IconMenu exposing (..)

import Component.UI.Common exposing (Action(..), IconType(..), Size, size2String, viewIcon)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Util exposing (maybeToList)


type alias Item msg =
    { label : String
    , icon : Maybe (IconType msg)
    , onClick : Maybe (Action msg)
    , color : Maybe String
    , isActive : Bool
    , isDisabled : Bool
    }


type alias Model msg =
    { items : List (Item msg)
    , isVertical : Bool
    , isCompact : Bool
    , size : Maybe Size
    }


viewItem : Item msg -> Html msg
viewItem item =
    let
        ico =
            case ( item.icon, item.isDisabled ) of
                ( Just (IconGeneric id _), True ) ->
                    maybeToList <| Maybe.map viewIcon <| Just <| IconGeneric id ""

                _ ->
                    maybeToList <| Maybe.map viewIcon item.icon

        cls =
            List.concat
                [ maybeToList (Maybe.map (\c -> ( c, True )) item.color)
                , [ ( "item", True )
                  , ( "active", item.isActive )
                  , ( "disabled", item.isDisabled )
                  ]
                ]
    in
    case item.onClick of
        Nothing ->
            span [ classList cls ] <| ico ++ [ text item.label ]

        Just (ActionGotoLink url) ->
            a [ classList cls, href url ] <| ico ++ [ text item.label ]

        Just (ActionMessage msg) ->
            span [ classList cls, onClick msg, style "cursor" "pointer" ] <| ico ++ [ text item.label ]


view : Model msg -> Html msg
view model =
    let
        cl =
            [ ( "ui", True )
            , ( Maybe.withDefault "" <| Maybe.map size2String model.size, model.size /= Nothing )
            , ( "сompact", model.isCompact )
            , ( "vertical", model.isVertical )
            , ( "labeled icon menu", True )
            ]
    in
    div
        [ classList cl ]
    <|
        List.map viewItem model.items

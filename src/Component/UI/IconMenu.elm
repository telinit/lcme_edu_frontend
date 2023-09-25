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
    , title : Maybe String
    }


type alias Model msg =
    { items : List (List (Item msg))
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

        onClickOverride =
            if item.isDisabled then
                Nothing

            else
                item.onClick

        title_ =
            maybeToList <| Maybe.map title item.title
    in
    case onClickOverride of
        Nothing ->
            span ([ classList cls ] ++ title_) <| ico ++ [ text item.label ]

        Just (ActionGotoLink url) ->
            a ([ classList cls, href url ] ++ title_) <| ico ++ [ text item.label ]

        Just (ActionMessage msg) ->
            span
                ([ classList cls
                 , onClick msg
                 , style "cursor" "pointer"
                 ]
                    ++ title_
                )
            <|
                ico
                    ++ [ text item.label ]


viewFull : Model msg -> Html msg
viewFull model =
    let
        cl =
            [ ( "ui", True )
            , ( Maybe.withDefault "" <| Maybe.map size2String model.size, model.size /= Nothing )
            , ( "vertical", model.isVertical )
            , ( "labeled icon menu", True )
            ]
    in
    div
        [ classList cl ]
    <|
        List.map (div [ class "mr-10" ] << List.map viewItem) model.items


viewCompact : Model msg -> Html msg
viewCompact model =
    let
        viewItem2 : Item msg -> Html msg
        viewItem2 item =
            let
                classes =
                    classList
                        [ ( "ui", True )
                        , ( "disabled", item.isDisabled )
                        , ( "active", item.isActive )
                        , ( "button", True )
                        ]

                buttonBody =
                    case item.icon of
                        Just (IconGeneric icon color) ->
                            [ i [ class <| icon ++ " " ++ color ++ " icon" ] []
                            ]

                        Just (IconCustom html) ->
                            [ html
                            ]

                        Nothing ->
                            []

                title_ =
                    maybeToList <| Maybe.map title item.title
            in
            case item.onClick of
                Just (ActionGotoLink link) ->
                    a [ href link ] [ button [ classes ] buttonBody ]

                Just (ActionMessage msg) ->
                    button
                        ([ classes
                         , onClick msg
                         , style "cursor" "pointer"
                         ]
                            ++ title_
                        )
                        buttonBody

                Nothing ->
                    button [ classes ] buttonBody

        viewGroup i =
            div
                [ classList
                    ([ ( "ui", True ) ]
                        ++ (maybeToList <| Maybe.map (\sz -> ( size2String sz, True )) model.size)
                        ++ [ ( "icon buttons", True ) ]
                        ++ [ ( "pl-10", i /= 0 ) ]
                    )
                ]
                << List.map viewItem2
    in
    div [] <| List.indexedMap viewGroup model.items


view model =
    if model.isCompact then
        viewCompact model

    else
        viewFull model

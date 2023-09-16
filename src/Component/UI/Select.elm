module Component.UI.Select exposing (..)

import Browser.Events
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Json.Decode as JD exposing (Value)


type alias Key =
    String


type alias Label =
    String


type alias Model =
    { items : Dict Key Label
    , selected : Maybe String
    , placeholder : String
    , active : Bool
    , fluid : Bool
    }


type Msg
    = MsgNoop
    | MsgItemSelected Key
    | MsgToggleMenu
    | MsgCloseMenu


init : Label -> Bool -> Dict Key Label -> ( Model, Cmd Msg )
init placeholder fluid items =
    ( { items = items
      , selected = Nothing
      , placeholder = placeholder
      , active = False
      , fluid = fluid
      }
    , Cmd.none
    )


doSelect : Key -> Model -> Model
doSelect key model =
    { model | selected = Maybe.map (\_ -> key) <| Dict.get key model.items }


updateItem : Key -> Label -> Model -> Model
updateItem key label model =
    { model | items = Dict.update key (\_ -> Just label) model.items }


removeItem : Key -> Model -> Model
removeItem key model =
    { model
        | items = Dict.remove key model.items
        , selected =
            if model.selected == Just key then
                Nothing

            else
                model.selected
    }


updateMany : List ( Key, Label ) -> Model -> Model
updateMany items model =
    List.foldl (\( k, v ) -> updateItem k v) model items


removeMany : List Key -> Model -> Model
removeMany items model =
    List.foldl removeItem model items


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MsgNoop ->
            ( model, Cmd.none )

        MsgItemSelected key ->
            ( doSelect key <|
                { model
                    | active = False
                }
            , Cmd.none
            )

        MsgToggleMenu ->
            ( { model | active = not model.active }, Cmd.none )

        MsgCloseMenu ->
            ( { model | active = False }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.active then
        Browser.Events.onMouseUp <|
            JD.succeed MsgCloseMenu

    else
        Sub.none


view model =
    div
        [ class "ui selection dropdown"
        , classList
            [ ( "active", model.active )
            , ( "visible", model.active )
            , ( "fluid", model.fluid )
            ]
        ]
        [ div
            [ style "position" "absolute"
            , style "left" "0"
            , style "right" "0"
            , style "top" "0"
            , style "bottom" "0"
            , onClick MsgToggleMenu
            ]
            []
        , i [ class "dropdown icon", onClick MsgToggleMenu ]
            []
        , div [ class "text", classList [ ( "default", model.selected == Nothing ) ] ]
            [ text <|
                Maybe.withDefault model.placeholder <|
                    Maybe.map
                        (\k ->
                            Maybe.withDefault model.placeholder <|
                                Dict.get k model.items
                        )
                        model.selected
            ]
        , div
            [ class "menu"
            , classList
                [ ( "active", model.active )
                , ( "visible", model.active )
                ]
            , style "display"
                (if model.active then
                    "block"

                 else
                    "none"
                )
            ]
            (List.map
                (\( k, v ) ->
                    div [ class "item", onClick (MsgItemSelected k) ]
                        [ text v ]
                )
             <|
                Dict.toList model.items
            )
        ]

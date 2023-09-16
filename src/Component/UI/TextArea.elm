module Component.UI.TextArea exposing (..)

import Component.UI.Common exposing (CSSValue, Size, size2String)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Util exposing (maybeToList)


type alias Model msg =
    { value : String
    , placeholder : String
    , lines : Int
    , size : Maybe Size
    , onInput : Maybe (String -> msg)
    , onClick : Maybe msg
    , width : Maybe CSSValue
    , height : Maybe CSSValue
    , isDisabled : Bool
    }


init : Model msg
init =
    { value = ""
    , placeholder = ""
    , lines = 3
    , size = Nothing
    , onInput = Nothing
    , onClick = Nothing
    , width = Nothing
    , height = Nothing
    , isDisabled = False
    }


view : Model msg -> Html msg
view model =
    let
        sizeStr =
            Maybe.withDefault "" (Maybe.map (size2String >> (++) " ") model.size)

        attributes =
            [ value model.value
            , placeholder model.placeholder
            , rows model.lines
            ]
                ++ maybeToList (Maybe.map onInput model.onInput)
                ++ maybeToList (Maybe.map onClick model.onClick)

        attributesForm =
            maybeToList (Maybe.map (style "width") model.width)
                ++ maybeToList (Maybe.map (style "height") model.height)
    in
    div ([ class ("ui" ++ sizeStr ++ " form") ] ++ attributesForm)
        [ div
            [ class
                (if model.isDisabled then
                    "disabled "

                 else
                    "" ++ "field"
                )
            ]
            [ textarea attributes []
            ]
        ]

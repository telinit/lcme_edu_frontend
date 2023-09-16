module Component.UI.InputBox exposing (..)

import Component.UI.Common exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Util exposing (maybeToList)


type LabelType
    = LabelTypeGeneric
    | LabelTypeCornered


type alias Label =
    { side : Side
    , type_ : LabelType
    , text : String
    }


type alias Icon msg =
    { type_ : IconType msg
    , side : Side
    }


type alias Model msg =
    { value : String
    , placeholder : String
    , label : Maybe Label
    , icon : Maybe (Icon msg)
    , isDisabled : Bool
    , isErrored : Bool
    , isTransparent : Bool
    , isFluid : Bool
    , size : Maybe Size
    , onInput : Maybe (String -> msg)
    , onClick : Maybe msg
    }


init : Model msg
init =
    { value = ""
    , placeholder = ""
    , label = Nothing
    , icon = Nothing
    , isDisabled = False
    , isErrored = False
    , isTransparent = False
    , isFluid = False
    , size = Nothing
    , onInput = Nothing
    , onClick = Nothing
    }


view : Model msg -> Html msg
view props =
    let
        classError =
            ( "error", props.isErrored )

        classTransparent =
            ( "transparent", props.isTransparent )

        classLabel =
            case props.label of
                Just label ->
                    case ( label.type_, label.side ) of
                        ( LabelTypeGeneric, Left ) ->
                            ( "labeled", True )

                        ( LabelTypeGeneric, Right ) ->
                            ( "right labeled", True )

                        ( LabelTypeCornered, Left ) ->
                            ( "left corner labeled", True )

                        ( LabelTypeCornered, Right ) ->
                            ( "corner labeled", True )

                Nothing ->
                    ( "", False )

        classIcon =
            case props.icon of
                Just icon ->
                    case icon.side of
                        Left ->
                            ( "left icon", True )

                        Right ->
                            ( "icon", True )

                Nothing ->
                    ( "", False )

        classSize =
            case props.size of
                Just size ->
                    (size2String size, True)

                Nothing ->
                    ( "", False )

        classFluid =
            if props.isFluid then
                ( "fluid", True )

            else
                ( "", False )

        childLabel =
            case props.label of
                Just label ->
                    let
                        labelSubClasses =
                            case ( label.type_, label.side ) of
                                ( LabelTypeGeneric, Left ) ->
                                    ( "ui label", True )

                                ( LabelTypeGeneric, Right ) ->
                                    ( "ui label", True )

                                ( LabelTypeCornered, Left ) ->
                                    ( "ui left corner label", True )

                                ( LabelTypeCornered, Right ) ->
                                    ( "ui corner label", True )
                    in
                    div [ classList [ labelSubClasses ] ]
                        [ text label.text
                        ]

                Nothing ->
                    text ""

        childIcon =
            case props.icon of
                Just icon ->
                    viewIcon icon.type_

                Nothing ->
                    text ""
    in
    div
        [ classList
            [ ( "ui", True )
            , classFluid
            , ( "input", True )
            , classError
            , classLabel
            , classTransparent
            , classIcon
            , classSize
            ]
        ]
    <|
        List.concat
            [ if
                Maybe.withDefault False <|
                    Maybe.map (.side >> (==) Left) props.label
              then
                [ childLabel ]

              else
                []
            , if
                Maybe.withDefault False <|
                    Maybe.map (.side >> (==) Left) props.icon
              then
                [ childIcon ]

              else
                []
            , [ input
                    ([ placeholder props.placeholder
                     , type_ "text"
                     , value props.value
                     ]
                        ++ (maybeToList <| Maybe.map onInput props.onInput)
                        ++ (maybeToList <| Maybe.map onClick props.onClick)
                    )
                    []
              ]
            , if
                Maybe.withDefault False <|
                    Maybe.map (.side >> (==) Right) props.icon
              then
                [ childIcon ]

              else
                []
            , if
                Maybe.withDefault False <|
                    Maybe.map (.side >> (==) Right) props.label
              then
                [ childLabel ]

              else
                []
            ]

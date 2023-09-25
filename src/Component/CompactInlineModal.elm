module Component.CompactInlineModal exposing (..)

import Component.UI.Common exposing (ButtonKind, Color, IconType, buttonKind2Label)
import Component.UI.InputBox as InputBox
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Util exposing (maybeToList)


type alias Action msg =
    { label : String
    , onClick : msg
    , isDisabled : Bool
    , color : Maybe Color
    }


type alias Model msg =
    { header : String
    , onClose : Maybe msg
    , body : Html msg
    , actions : List (Action msg)
    }


type alias TextPrompt msg =
    { header : String
    , prompt : String
    , currentValue : String
    , validation : Maybe (String -> Bool)
    , onInput : Maybe (String -> msg)
    , onConfirm : Maybe msg
    , onCancel : Maybe msg
    }


type alias MessageBox msg =
    { title : String
    , prompt : Html msg
    , buttons : List ButtonKind
    , onClick : ButtonKind -> msg
    }


initAction : String -> msg -> Action msg
initAction label onClick =
    { label = label
    , onClick = onClick
    , isDisabled = False
    , color = Nothing
    }


actionSetDisabled : Bool -> Action msg -> Action msg
actionSetDisabled val action =
    { action | isDisabled = val }


init : Html msg -> Maybe msg -> Model msg
init body onClose =
    { header = ""
    , onClose = onClose
    , body = body
    , actions = []
    }


view : Model msg -> Html msg
view model =
    let
        header =
            case model.header of
                "" ->
                    span [] []

                h ->
                    h4 [] [ text h ]

        close =
            case model.onClose of
                Nothing ->
                    text ""

                Just msg ->
                    i [ class "close icon", onClick msg, style "cursor" "pointer" ] []

        action act =
            button
                [ classList <|
                    [ ( "mini ui button", True ) ]
                        ++ (maybeToList <| Maybe.map (\c -> ( c, act.isDisabled )) act.color)
                        ++ [ ( "disabled", act.isDisabled ) ]
                , onClick act.onClick
                ]
                [ text act.label ]
    in
    div
        [ style "width" "100%"
        , style "height" "100%"
        , style "background" "rgba(0, 0, 0, 0.5)"
        , style "z-index" "10"
        , style "position" "absolute"
        , class "row center-xs middle-xs m-0"
        ]
        [ div
            [ class "col p-10"
            , style "background" "white"
            , style "display" "initial"
            , style "border-radius" "5px"
            ]
            [ div [ class "row between-xs ml-5 mr-5" ] [ header, close ]
            , div [ class "start-xs" ] [ model.body ]
            , div [ class "row end-xs mt-10" ] <| List.map action model.actions
            ]
        ]


initTextInput : TextPrompt msg -> Model msg
initTextInput textPrompt =
    let
        input_ =
            InputBox.init

        body =
            div []
                [ div [] [ text textPrompt.prompt ]
                , div []
                    [ InputBox.view
                        { input_
                            | value = textPrompt.currentValue
                            , onInput = textPrompt.onInput
                        }
                    ]
                ]

        init_ =
            init body Nothing

        notValidated =
            not <|
                Maybe.withDefault True <|
                    Maybe.map ((|>) textPrompt.currentValue) textPrompt.validation
    in
    { init_
        | header = textPrompt.header
        , actions =
            (maybeToList <| Maybe.map (initAction "Отмена") textPrompt.onCancel)
                ++ (maybeToList <| Maybe.map (initAction "OK" >> actionSetDisabled notValidated) textPrompt.onConfirm)
    }


initMessageBox : MessageBox msg -> Model msg
initMessageBox { title, prompt, buttons, onClick } =
    let
        toAction btn =
            initAction (buttonKind2Label btn) (onClick btn)
    in
    { header = title
    , onClose = Nothing
    , body = prompt
    , actions = List.map toAction buttons
    }

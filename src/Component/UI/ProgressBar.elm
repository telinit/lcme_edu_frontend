module Component.UI.ProgressBar exposing (..)

import Component.UI.Common exposing (Color, Size, size2String)
import Html exposing (..)
import Html.Attributes exposing (..)
import Util exposing (maybeToList)


type Progress
    = ProgressPercents
    | ProgressText String


type alias Model =
    { progressPercent : Int
    , color : Maybe Color
    , isActive : Bool
    , showProgress : Maybe Progress
    , label : Maybe String
    , size : Maybe Size
    }


init : Int -> Model
init progress =
    { progressPercent = progress
    , color = Nothing
    , isActive = False
    , showProgress = Nothing
    , label = Nothing
    , size = Nothing
    }


view : Model -> Html msg
view model =
    let
        clsActive =
            [ ( "active", model.isActive ) ]

        clsProgress =
            [ ( "progress", model.showProgress /= Nothing ) ]

        clsColor =
            [ ( Maybe.withDefault "blue" model.color, True ) ]

        clsSize =
            maybeToList <|
                Maybe.map (\size -> ( size2String size, True )) model.size

        htmlLabel =
            Maybe.withDefault [] <|
                Maybe.map (\label -> [ div [ class "label" ] [ text label ] ]) model.label

        htmlProgress =
            case model.showProgress of
                Nothing ->
                    []

                Just ProgressPercents ->
                    [ div [ class "progress" ]
                        [ text <| String.fromInt model.progressPercent ++ "%" ]
                    ]

                Just (ProgressText txt) ->
                    [ div [ class "progress" ]
                        [ text txt ]
                    ]
    in
    div
        [ classList
            ([ ( "ui", True ) ]
                ++ clsSize
                ++ clsColor
                ++ clsActive
                ++ clsProgress
                ++ [ ( "progress", True ) ]
            )
        ]
        ([ div [ class "bar", style "width" (String.fromInt model.progressPercent ++ "%") ] htmlProgress ] ++ htmlLabel)


x =
    div [ class "ui active progress" ]
        [ div [ class "bar" ]
            [ div [ class "progress" ]
                []
            ]
        , div [ class "label" ]
            [ text "Uploading Files" ]
        ]

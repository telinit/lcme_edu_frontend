module Component.Stats exposing (..)

import Api exposing (task, withToken)
import Api.Data exposing (Counters)
import Api.Request.Stats exposing (statsCounters)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Styled.Attributes exposing (css)
import Util exposing (httpErrorToString, task_to_cmd)


type Msg
    = FetchCompleted Counters
    | FetchFailed String


type State
    = Loading
    | Complete Counters
    | Error String


type alias Model =
    { state : State, token : String }


doFetch : String -> Cmd Msg
doFetch token =
    task_to_cmd (httpErrorToString >> FetchFailed) FetchCompleted <| task <| withToken (Just token) statsCounters


init : String -> ( Model, Cmd Msg )
init token =
    ( { state = Loading, token = token }, doFetch token )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchCompleted obj ->
            ( { model | state = Complete obj }, Cmd.none )

        FetchFailed err ->
            ( { model | state = Error err }, Cmd.none )


view : Model -> Html Msg
view model =
    case model.state of
        Loading ->
            div [ class "ui message" ]
                [ div [ class "ui active inline loader small", style "margin-right" "1em" ] []
                , text "Загружаем статистику"
                ]

        Complete obj ->
            let
                label = [style "min-width" "100px", style "text-align" "right", style "margin-right" "1em"]
            in
            div [ class "ui segment" ]
                [ h3 [] [ text "Статистика" ]
                , div [ class "ml-10" ]
                    [ div [ class "row" ]
                        [ div ([ class "col" ] ++ label) [ text "Пользователи:" ]
                        , div [ class "col" ] [ strong [] [ text <| String.fromInt <| obj.users ] ]
                        ]
                    , div [ class "row" ]
                        [ div ([ class "col" ] ++ label) [ text "Предметы:" ]
                        , div [ class "col" ] [ strong [] [ text <| String.fromInt <| obj.courses ] ]
                        ]
                    , div [ class "row" ]
                        [ div ([ class "col" ] ++ label) [ text "Активности:" ]
                        , div [ class "col" ] [ strong [] [ text <| String.fromInt <| obj.activities ] ]
                        ]
                    , div [ class "row" ]
                        [ div ([ class "col" ] ++ label) [ text "Оценки:" ]
                        , div [ class "col" ] [ strong [] [ text <| String.fromInt <| obj.marks ] ]
                        ]
                    ]
                ]

        Error err ->
            div [ class "ui negative message" ]
                [ div [ class "header" ] [ text "Ошибка при загрузке статистики" ]
                , p [] [ text err ]
                ]

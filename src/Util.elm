module Util exposing (..)

import Array exposing (Array)
import Html exposing (Attribute, span)
import Html.Attributes exposing (style)
import Html.Events exposing (custom, preventDefaultOn, stopPropagationOn)
import Http
import Json.Decode as Json
import Task exposing (onError)


type Either a b
    = Left a
    | Right b


either_map : (a -> c) -> (b -> c) -> Either a b -> c
either_map fl fr e =
    case e of
        Left a ->
            fl a

        Right b ->
            fr b


httpErrorToString : Http.Error -> String
httpErrorToString error =
    case error of
        Http.BadUrl url ->
            "Некорректный адрес: " ++ url

        Http.Timeout ->
            "Таймаут"

        Http.NetworkError ->
            "Сетевая ошибка"

        Http.BadStatus code ->
            "Код ошибки: " ++ String.fromInt code

        Http.BadBody s ->
            "Некорректный формат данных: " ++ s


maybe_to_task : Maybe a -> Task.Task () a
maybe_to_task =
    Maybe.map Task.succeed >> Maybe.withDefault (Task.fail ())


task_to_cmd : (error -> a) -> (value -> a) -> Task.Task error value -> Cmd a
task_to_cmd on_err on_success =
    let
        on_result r =
            case r of
                Ok x ->
                    on_success x

                Err x ->
                    on_err x
    in
    Task.attempt on_result


task_map_to_bool : Task.Task a b -> Task.Task Never Bool
task_map_to_bool =
    Task.map (\_ -> True) >> Task.onError (\_ -> Task.succeed False)


onClickPrevent : msg -> Attribute msg
onClickPrevent msg =
    preventDefaultOn "click" (Json.map (\x -> ( x, True )) (Json.succeed msg))


onClickStop : msg -> Attribute msg
onClickStop msg =
    stopPropagationOn "click" (Json.map (\x -> ( x, True )) (Json.succeed msg))


onClickPreventStop : msg -> Attribute msg
onClickPreventStop msg =
    custom "click" <| Json.succeed { message = msg, stopPropagation = True, preventDefault = True }


link_span attrs body =
    span ([ style "color" "#4183C4", style "cursor" "pointer" ] ++ attrs) body


arrayUpdate : Int -> (a -> a) -> Array a -> Array a
arrayUpdate ix transform array =
    case Array.get ix array of
        Just el ->
            Array.set ix (transform el) array

        Nothing ->
            array

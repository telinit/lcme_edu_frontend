module Component.MultiTask exposing (..)

import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http exposing (Error(..))
import Task exposing (Task)
import Util exposing (arrayUpdate, task_to_cmd)


type Msg e a
    = TaskCompleted Int a
    | TaskFailed Int e
    | TaskFinishedAll (List (Result e a))


type State e a
    = Running
    | Complete a
    | Error e


type alias TaskState e a =
    ( String, State e a, Task e a )


type alias Model e a =
    { task_states : Array (TaskState e a)
    , tasks_left : Int
    }


doFetch : Int -> Task e a -> Cmd (Msg e a)
doFetch idx task =
    task_to_cmd (TaskFailed idx) (TaskCompleted idx) <| task


init : List ( Task e a, String ) -> ( Model e a, Cmd (Msg e a) )
init tasks =
    let
        states =
            Array.map (\( t, label ) -> ( label, Running, t )) <|
                Array.fromList tasks
    in
    ( { task_states = states
      , tasks_left = Array.length states
      }
    , Cmd.batch <|
        List.indexedMap (\i ( t, _ ) -> doFetch i t) tasks
    )


collectResults : Model e a -> List (Result e a)
collectResults model =
    let
        state2result state =
            case state of
                Running ->
                    Nothing

                Complete r ->
                    Just (Ok r)

                Error e ->
                    Just (Err e)
    in
    List.filterMap identity <|
        Array.toList <|
            Array.map (state2result << (\( _, s, _ ) -> s)) <|
                model.task_states


update : Msg e a -> Model e a -> ( Model e a, Cmd (Msg e a) )
update msg model =
    case msg of
        TaskCompleted i res ->
            let
                new_model =
                    { model
                        | task_states = arrayUpdate i (\( l, _, t ) -> ( l, Complete res, t )) model.task_states
                        , tasks_left = model.tasks_left - 1
                    }
            in
            ( new_model
            , if model.tasks_left <= 1 then
                Task.perform (\_ -> TaskFinishedAll <| collectResults new_model) <| Task.succeed ()

              else
                Cmd.none
            )

        TaskFailed i err ->
            ( { model
                | task_states = arrayUpdate i (\( l, _, t ) -> ( l, Error err, t )) model.task_states
              }
            , case err of
                --BadStatus 401 -> Task.perform (\_ -> MsgUnauthorized) <| Task.succeed ()
                _ ->
                    Cmd.none
            )

        TaskFinishedAll _ ->
            ( model, Cmd.none )


viewTask : (a -> String) -> (e -> String) -> TaskState e a -> Html (Msg e a)
viewTask show_result show_error ( label, s, _ ) =
    let
        item icon t =
            div [ class "item" ]
                [ div [ class "content row" ]
                    [ div [ class "col" ] [ icon ]
                    , div [ class "col" ]
                        [ div [ class "header" ]
                            [ text label
                            ]
                        , text t
                        ]
                    ]
                ]
    in
    case s of
        Running ->
            (item <| div [ class "ui active inline loader small", style "margin-right" "1em" ] []) <|
                ""

        Complete res ->
            item (i [ class "check icon", style "margin-right" "1em", style "color" "green" ] []) <|
                show_result res

        Error err ->
            item (i [ class "exclamation icon", style "margin-right" "1em", style "color" "red" ] []) <|
                show_error err


view : (a -> String) -> (e -> String) -> Model e a -> Html (Msg e a)
view show_result show_error model =
    div [ class "ui segment " ]
        [ div [ class "ui relaxed divided list" ] <|
            Array.toList <|
                Array.map (viewTask show_result show_error) model.task_states
        ]

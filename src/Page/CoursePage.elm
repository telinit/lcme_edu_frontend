module Page.CoursePage exposing (..)

import Api.Data exposing (Activity, CourseRead)
import Component.MultiTask as MultiTask exposing (Msg(..))
import Html exposing (..)
import Html.Attributes exposing (class)
import Http exposing (Error(..))
import Task
import Util exposing (httpErrorToString)


type State
    = Fetching (MultiTask.Model Http.Error FetchResult)
    | FetchDone CourseRead (List Activity)
    | FetchFailed String


type Msg
    = MsgFetch (MultiTask.Msg Http.Error FetchResult)


type FetchResult
    = ResCourse CourseRead
    | ResActivities (List Activity)


type alias Model =
    { state : State
    , token : String
    }


showFetchResult : FetchResult -> String
showFetchResult fetchResult =
    case fetchResult of
        ResCourse courseRead ->
            courseRead.title

        ResActivities activities ->
            "Активностей: " ++ (String.fromInt <| List.length activities)


init : String -> String -> ( Model, Cmd Msg )
init token id =
    let
        ( m, c ) =
            MultiTask.init
                [ ( Task.succeed (ResActivities []), "Получаем активности" )
                , ( Task.fail Timeout, "Получение чего-то" )
                ]

        -- TODO
    in
    ( { state = Fetching m, token = token }, Cmd.map MsgFetch c )


collectFetchResults : List (Result e FetchResult) -> Maybe ( CourseRead, List Activity )
collectFetchResults fetchResults =
    case fetchResults of
        [ Ok (ResCourse c), Ok (ResActivities a) ] ->
            Just ( c, a )

        [ Ok (ResActivities a), Ok (ResCourse c) ] ->
            Just ( c, a )

        _ ->
            Nothing


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.state ) of
        ( MsgFetch msg_, Fetching model_ ) ->
            let
                ( m, c ) =
                    MultiTask.update msg_ model_
            in
            case msg_ of
                TaskFinishedAll results ->
                    case collectFetchResults results of
                        Just ( c_, a ) ->
                            ( { model | state = FetchDone c_ a }, Cmd.none )

                        Nothing ->
                            ( { model | state = FetchFailed "Не удалось разобрать результаты запросов" }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    case model.state of
        Fetching model_ ->
            let
                fetcher =
                    MultiTask.view showFetchResult httpErrorToString model_
            in
            div [ class "ui text container" ] [ Html.map MsgFetch fetcher ]

        FetchDone courseRead activities ->
            text "Done"

        FetchFailed err ->
            text ("Failed" ++ err)

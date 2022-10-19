module Page.CoursePage exposing (..)

import Api exposing (task, withQuery, withToken)
import Api.Data exposing (Activity, CourseEnrollment, CourseRead)
import Api.Request.Activity exposing (activityList)
import Api.Request.Course exposing (courseEnrollmentList, courseRead)
import Component.MultiTask as MultiTask exposing (Msg(..))
import Html exposing (..)
import Html.Attributes exposing (class, title)
import Http exposing (Error(..))
import Process
import Task exposing (andThen)
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
    | ResEnrollments (List CourseEnrollment)


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

        ResEnrollments _ ->
            "OK"


taskCourse token cid =
    Task.map ResCourse <| task <| withToken (Just token) <| courseRead cid


taskActivities token cid =
    Task.map ResActivities <| task <| withQuery [("course", Just cid)] <| withToken (Just token) <| activityList

taskEnrollments token cid =
    Task.map ResEnrollments <| task <| withQuery [("course", Just cid)] <| withToken (Just token) <| courseEnrollmentList

init : String -> String -> ( Model, Cmd Msg )
init token id =
    let
        ( m, c ) =
            MultiTask.init
                [ ( taskCourse token id, "Получаем данные о курсе" )
                , ( taskActivities token id, "Получаем активности" )
                , ( taskEnrollments token id, "Получаем записи на курс" )
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
                    case collectFetchResults (Debug.log "results" (results)) of
                        Just ( c_, a ) ->
                            ( { model | state = FetchDone c_ a }, Cmd.none )

                        Nothing ->
                            ( { model | state = FetchFailed "Не удалось разобрать результаты запросов" }, Cmd.none )

                _ ->
                    ( { model | state = Fetching m }, Cmd.map MsgFetch c )

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
            text ("Failed: " ++ err)

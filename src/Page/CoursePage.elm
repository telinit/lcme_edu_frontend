module Page.CoursePage exposing (..)

import Api exposing (task, withQuery, withToken)
import Api.Data exposing (Activity, CourseEnrollmentRead, CourseEnrollmentReadRole(..), CourseRead)
import Api.Request.Activity exposing (activityList)
import Api.Request.Course exposing (courseEnrollmentList, courseRead)
import Component.MessageBox as MessageBox exposing (Type(..))
import Component.MultiTask as MultiTask exposing (Msg(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Http exposing (Error(..))
import Task
import Util exposing (httpErrorToString)
import Uuid


type State
    = Fetching (MultiTask.Model Http.Error FetchResult)
    | FetchDone CourseRead
    | FetchFailed String


type Msg
    = MsgFetch (MultiTask.Msg Http.Error FetchResult)


type FetchResult
    = ResCourse CourseRead
    | ResActivities (List Activity)
    | ResEnrollments (List CourseEnrollmentRead)


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
    Task.map ResActivities <| task <| withQuery [ ( "course", Just cid ) ] <| withToken (Just token) <| activityList


taskEnrollments token cid =
    Task.map ResEnrollments <| task <| withQuery [ ( "course", Just cid ) ] <| withToken (Just token) <| courseEnrollmentList


init : String -> String -> ( Model, Cmd Msg )
init token id =
    let
        ( m, c ) =
            MultiTask.init
                [ ( taskCourse token id, "Получаем данные о курсе" )

                --, ( taskActivities token id, "Получаем активности" )
                --, ( taskEnrollments token id, "Получаем записи на курс" )
                ]

        -- TODO
    in
    ( { state = Fetching m, token = token }, Cmd.map MsgFetch c )


collectFetchResults : List (Result e FetchResult) -> Maybe CourseRead
collectFetchResults fetchResults =
    case fetchResults of
        --[ Ok (ResCourse crs), Ok (ResActivities act), Ok (ResEnrollments enr) ] ->
        --    Just ( crs, act, enr )
        [ Ok (ResCourse crs) ] ->
            Just crs

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
                    case collectFetchResults (Debug.log "results" results) of
                        Just c_ ->
                            ( { model | state = FetchDone c_ }, Cmd.none )

                        Nothing ->
                            ( { model | state = FetchFailed "Не удалось разобрать результаты запросов" }, Cmd.none )

                _ ->
                    ( { model | state = Fetching m }, Cmd.map MsgFetch c )

        ( _, _ ) ->
            ( model, Cmd.none )


viewActivity : Activity -> Html Msg
viewActivity activity =
    div [ class "text container segment ui" ] [ h2 [] [ text activity.title ] ]


viewCourse : CourseRead -> Html Msg
viewCourse courseRead =
    let
        breadcrumbs =
            div [ class "ui large breadcrumb" ]
                [ a [ class "section", href "/courses" ]
                    [ text "Предметы" ]
                , i [ class "right chevron icon divider" ]
                    []
                , div [ class "active section" ]
                    [ text courseRead.title ]
                ]

        header =
            let
                default_cover_url =
                    "/img/course_cover.webp"

                default_logo_url =
                    "/img/course.jpg"

                cover_img =
                    Maybe.withDefault default_cover_url <|
                        Maybe.map (\f -> Maybe.withDefault default_cover_url <| Maybe.map Uuid.toString f.id) courseRead.cover

                logo_img =
                    Maybe.withDefault default_logo_url <|
                        Maybe.map (\f -> Maybe.withDefault default_cover_url <| Maybe.map Uuid.toString f.id) courseRead.logo

                for_class =
                    let
                        classes =
                            [ class "users icon", style "color" "#679", style "white-space" "nowrap" ]
                    in
                    case ( courseRead.forClass, courseRead.forSpecialization ) of
                        ( Just cls, Just spec ) ->
                            span []
                                [ i classes []
                                , text <| cls ++ " класс (" ++ spec.name ++ " направление)"
                                ]

                        ( Just cls, Nothing ) ->
                            span []
                                [ i classes []
                                , text <| cls ++ " класс"
                                ]

                        ( _, _ ) ->
                            text ""

                for_group =
                    case courseRead.forGroup of
                        Just g ->
                            span [ style "white-space" "nowrap" ]
                                [ i [ class "list ol icon", style "color" "#679" ] []
                                , text <| g
                                ]

                        Nothing ->
                            text ""

                description =
                    if String.trim courseRead.description == "" then
                        "(нет описания)"

                    else
                        courseRead.description

                teacher =
                    case List.head <| List.filter (\e -> e.role == CourseEnrollmentReadRoleT) courseRead.enrollments of
                        Just t ->
                            let
                                full_name =
                                    Maybe.withDefault "" t.person.firstName
                                        ++ " "
                                        ++ Maybe.withDefault "" t.person.lastName

                                name =
                                    case t.person.id of
                                        Just id ->
                                            a [ href ("/user/" ++ Uuid.toString id) ] [ text full_name ]

                                        Nothing ->
                                            text full_name
                            in
                            span [ style "white-space" "nowrap" ]
                                [ i [ class "user icon", style "color" "#679" ] []
                                , text
                                    "Преподаватель: "
                                , name
                                ]

                        Nothing ->
                            text ""
            in
            div
                [ style "background" ("linear-gradient( rgba(0, 0, 0, 0.8), rgba(0, 0, 0, 0.8) ), url('" ++ cover_img ++ "')")
                , style "padding" "1em"
                , style "margin" "1em"
                , style "overflow" "hidden"
                , style "color" "white"
                , class "row center-xs"
                ]
                [ div
                    [ class "col-sm-3 col-xs center-xs"
                    , style "margin-right" "1em"
                    , style "min-width" "300px"
                    , style "max-width" "300px"
                    ]
                    [ img
                        [ src logo_img
                        , style "object-fit" "cover"
                        , style "object-position" "center"
                        , style "width" "100%"
                        , style "height" "300px"
                        ]
                        []
                    ]
                , div [ class "col-sm between-xs row start-xs", style "margin" "1em", style "flex-flow" "column nowrap" ]
                    [ div []
                        [ h1 [] [ text courseRead.title ]
                        , p [ style "max-height" "180px", style "overflow" "hidden", style "margin-left" "2em" ] [ text description ]
                        ]
                    , div [ class "row around-xs", style "margin-top" "2em" ]
                        [ for_class
                        , for_group
                        , teacher
                        ]
                    ]
                ]

        activities =
            List.map viewActivity courseRead.activities
    in
    div []
        [ breadcrumbs
        , header
        , div [ class "col center-xs" ] activities
        ]


view : Model -> Html Msg
view model =
    case model.state of
        Fetching model_ ->
            let
                fetcher =
                    MultiTask.view showFetchResult httpErrorToString model_
            in
            div [ class "ui text container" ] [ Html.map MsgFetch fetcher ]

        FetchDone courseRead ->
            viewCourse courseRead

        FetchFailed err ->
            MessageBox.view Error Nothing "Ошибка" ("Не удалось получить данные курса: " ++ err)

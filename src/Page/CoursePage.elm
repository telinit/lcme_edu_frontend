module Page.CoursePage exposing (..)

import Api exposing (task, withQuery, withToken)
import Api.Data exposing (Activity, CourseDeep, CourseEnrollmentRead, CourseEnrollmentReadRole(..), User)
import Api.Request.Activity exposing (activityList)
import Api.Request.Course exposing (courseEnrollmentList, courseGetDeep, courseRead)
import Component.MessageBox as MessageBox exposing (Type(..))
import Component.Misc exposing (user_link)
import Component.Modal as Modal
import Component.MultiTask as MultiTask exposing (Msg(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http exposing (Error(..))
import Page.CourseListPage exposing (empty_to_nothing)
import Task
import Util exposing (get_id_str, httpErrorToString, user_full_name)


type State
    = Fetching (MultiTask.Model Http.Error FetchResult)
    | FetchDone CourseDeep
    | FetchFailed String


type Msg
    = MsgFetch (MultiTask.Msg Http.Error FetchResult)
    | MsgClickMembers
    | MsgCloseMembers


type FetchResult
    = ResCourse CourseDeep


type alias Model =
    { state : State
    , token : String
    , roles : List String
    , show_modal : Bool
    }


showFetchResult : FetchResult -> String
showFetchResult fetchResult =
    case fetchResult of
        ResCourse courseRead ->
            courseRead.title


taskCourse token cid =
    Task.map ResCourse <| task <| withToken (Just token) <| courseGetDeep cid


init : String -> String -> List String -> ( Model, Cmd Msg )
init token course_id roles =
    let
        ( m, c ) =
            MultiTask.init
                [ ( taskCourse token course_id, "Получаем данные о курсе" )
                ]

        -- TODO
    in
    ( { state = Fetching m, token = token, roles = roles, show_modal = False }, Cmd.map MsgFetch c )


collectFetchResults : List (Result e FetchResult) -> Maybe CourseDeep
collectFetchResults fetchResults =
    case fetchResults of
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
                    case collectFetchResults results of
                        Just c_ ->
                            ( { model | state = FetchDone c_ }, Cmd.none )

                        Nothing ->
                            ( { model | state = FetchFailed "Не удалось разобрать результаты запросов" }, Cmd.none )

                _ ->
                    ( { model | state = Fetching m }, Cmd.map MsgFetch c )

        ( MsgClickMembers, _ ) ->
            ( { model | show_modal = True }, Cmd.none )

        ( MsgCloseMembers, _ ) ->
            ( { model | show_modal = False }, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )


viewActivity : Activity -> Html Msg
viewActivity activity =
    div [ class "text container segment ui" ] [ h2 [] [ text activity.title ] ]


viewCourse : CourseDeep -> Model -> Html Msg
viewCourse courseRead model =
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
                        Maybe.map (\f -> "/api/file/" ++ get_id_str f ++ "/download") courseRead.cover

                logo_img =
                    Maybe.withDefault default_logo_url <|
                        Maybe.map (\f -> "/api/file/" ++ get_id_str f ++ "/download") courseRead.logo

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
                    case empty_to_nothing courseRead.forGroup of
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
                            span [ style "white-space" "nowrap" ]
                                [ i [ class "user icon", style "color" "#679" ] []
                                , text
                                    "Преподаватель: "
                                , a [ href <| "/profile/" ++ get_id_str t.person ] [ text <| user_full_name t.person ]
                                ]

                        Nothing ->
                            text ""

                buttons =
                    List.filterMap identity
                        [ if List.any (\r -> List.member r model.roles) [ "teacher", "staff", "admin" ] then
                            Just <|
                                a [ href <| "/marks/course/" ++ get_id_str courseRead ]
                                    [ button [ class "ui button" ]
                                        [ i [ class "chart bar outline icon" ] []
                                        , text "Оценки"
                                        ]
                                    ]

                          else
                            Nothing
                        , Just <|
                            button [ class "ui button", onClick MsgClickMembers ]
                                [ i [ class "users icon" ] []
                                , text "Участники"
                                ]
                        ]
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
                        [ div [ class "row between-xs middle-xs", style "margin-bottom" "0.5em" ]
                            [ h1 [ class "col", style "margin" "0" ] [ text courseRead.title ]
                            , div [ class "col" ] buttons
                            ]
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

        members =
            let
                teachers =
                    List.map .person <| List.filter (\enr -> enr.role == CourseEnrollmentReadRoleT) courseRead.enrollments

                students =
                    List.map .person <| List.filter (\enr -> enr.role == CourseEnrollmentReadRoleS) courseRead.enrollments

                user_list =
                    List.map (user_link >> (\el -> div [ style "margin" "1em" ] [ el ]))
            in
            div []
                [ h3 [] [ text "Преподаватели" ]
                , div [ style "padding-left" "1em" ] <| user_list teachers
                , h3 [] [ text "Учащиеся" ]
                , div [ style "padding-left" "1em" ] <| user_list students
                ]

        modal do_show =
            Modal.view "members" "Участники" members MsgCloseMembers [ ( "Закрыть", MsgCloseMembers ) ] do_show
    in
    div []
        [ modal model.show_modal
        , breadcrumbs
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
            viewCourse courseRead model

        FetchFailed err ->
            MessageBox.view Error Nothing "Ошибка" ("Не удалось получить данные курса: " ++ err)

module Page.CoursePage exposing (..)

import Api exposing (ext_task, task, withQuery, withToken)
import Api.Data exposing (Activity, CourseDeep, CourseEnrollmentRead, CourseEnrollmentReadRole(..), UserDeep)
import Api.Request.Activity exposing (activityCreate, activityList)
import Api.Request.Course exposing (courseEnrollmentList, courseGetDeep, courseRead)
import Component.MessageBox as MessageBox exposing (Type(..))
import Component.Misc exposing (user_link)
import Component.Modal as Modal
import Component.MultiTask as MultiTask exposing (Msg(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error(..))
import Page.CourseListPage exposing (empty_to_nothing)
import Set
import Task
import Time exposing (millisToPosix)
import Util exposing (get_id, get_id_str, httpErrorToString, isJust, task_to_cmd, user_full_name)


type State
    = Fetching (MultiTask.Model Http.Error FetchResult)
    | FetchDone CourseDeep
    | FetchFailed String


type Msg
    = MsgFetch (MultiTask.Msg Http.Error FetchResult)
    | MsgClickMembers
    | MsgCloseMembers
    | MsgAddActivity
    | MsgAddActivityChangeTitle String
    | MsgAddActivityDoAdd
    | MsgActivityCreated Activity
    | MsgCloseAddActivity
    | MsgNoop


type FetchResult
    = ResCourse CourseDeep


type alias AddActivityModel =
    { show_form : Bool
    , title : String
    }


type alias Model =
    { state : State
    , token : String
    , user : UserDeep
    , show_members : Bool
    , add_activity : AddActivityModel
    , is_staff : Bool
    , teaching_here : Bool
    }


showFetchResult : FetchResult -> String
showFetchResult fetchResult =
    case fetchResult of
        ResCourse courseRead ->
            courseRead.title


taskCourse token cid =
    Task.map ResCourse <| task <| withToken (Just token) <| courseGetDeep cid


init : String -> String -> UserDeep -> ( Model, Cmd Msg )
init token course_id user =
    let
        ( m, c ) =
            MultiTask.init
                [ ( taskCourse token course_id, "Получаем данные о курсе" )
                ]
    in
    ( { state = Fetching m
      , token = token
      , user = user
      , show_members = False
      , add_activity =
            { show_form = False
            , title = ""
            }
      , is_staff = not <| Set.isEmpty <| Set.intersect (Set.fromList <| Maybe.withDefault [] user.roles) (Set.fromList [ "admin", "staff" ])
      , teaching_here = False
      }
    , Cmd.map MsgFetch c
    )


collectFetchResults : List (Result e FetchResult) -> Maybe CourseDeep
collectFetchResults fetchResults =
    case fetchResults of
        [ Ok (ResCourse crs) ] ->
            Just crs

        _ ->
            Nothing


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ add_activity } as model) =
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
                            ( { model
                                | state = FetchDone c_
                                , teaching_here =
                                    List.any
                                        (\enr ->
                                            enr.role == CourseEnrollmentReadRoleT && enr.person.id == model.user.id
                                        )
                                        c_.enrollments
                              }
                            , Cmd.none
                            )

                        Nothing ->
                            ( { model | state = FetchFailed "Не удалось разобрать результаты запросов" }, Cmd.none )

                _ ->
                    ( { model | state = Fetching m }, Cmd.map MsgFetch c )

        ( MsgClickMembers, _ ) ->
            ( { model | show_members = True }, Cmd.none )

        ( MsgCloseMembers, _ ) ->
            ( { model | show_members = False }, Cmd.none )

        ( MsgAddActivity, _ ) ->
            ( { model | add_activity = { add_activity | show_form = True } }, Cmd.none )

        ( MsgCloseAddActivity, _ ) ->
            ( { model | add_activity = { add_activity | show_form = False } }, Cmd.none )

        ( MsgAddActivityChangeTitle t, _ ) ->
            ( { model | add_activity = { add_activity | title = t } }, Cmd.none )

        ( MsgAddActivityDoAdd, FetchDone course ) ->
            ( { model | add_activity = { add_activity | title = "", show_form = False } }
            , task_to_cmd (\_ -> MsgNoop) MsgActivityCreated <|
                ext_task identity model.token [] <|
                    activityCreate
                        { id = Nothing
                        , createdAt = Nothing
                        , updatedAt = Nothing
                        , type_ = Nothing
                        , title = add_activity.title
                        , keywords = Nothing
                        , isHidden = Just False
                        , marksLimit = Just 2
                        , order = 1 + (Maybe.withDefault 0 <| List.maximum <| List.map .order course.activities)
                        , date = millisToPosix 0
                        , group = Nothing
                        , body = Nothing
                        , dueDate = Nothing
                        , link = Nothing
                        , embed = Nothing
                        , finalType = Nothing
                        , course = get_id course
                        , files = Nothing
                        }
            )

        ( MsgActivityCreated act, FetchDone course ) ->
            ( { model | state = FetchDone { course | activities = act :: course.activities } }, Cmd.none )

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
                        [ if model.is_staff || model.teaching_here then
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
            List.map viewActivity <| List.sortBy .order courseRead.activities

        members =
            let
                teachers =
                    List.map .person <| List.filter (\enr -> enr.role == CourseEnrollmentReadRoleT) courseRead.enrollments

                students =
                    List.map .person <| List.filter (\enr -> enr.role == CourseEnrollmentReadRoleS) courseRead.enrollments

                user_list =
                    List.map (user_link Nothing >> (\el -> div [ style "margin" "1em" ] [ el ]))
            in
            div []
                [ h3 [] [ text "Преподаватели" ]
                , div [ style "padding-left" "1em" ] <| user_list teachers
                , h3 [] [ text "Учащиеся" ]
                , div [ style "padding-left" "1em" ] <| user_list students
                ]

        add_activity_form =
            Html.form [ class "ui form" ]
                [ div [ class "field" ]
                    [ label []
                        [ text "Название темы" ]
                    , input [ onInput MsgAddActivityChangeTitle, placeholder "Название темы", type_ "text", value model.add_activity.title ]
                        []
                    ]
                ]

        modal_members do_show =
            Modal.view
                "members"
                "Участники"
                members
                MsgCloseMembers
                [ ( "Закрыть", MsgCloseMembers ) ]
                do_show

        modal_add_activity do_show =
            Modal.view
                "members"
                "Добавить активность"
                add_activity_form
                MsgCloseAddActivity
                [ ( "Закрыть", MsgCloseAddActivity ), ( "Добавить", MsgAddActivityDoAdd ) ]
                do_show

        activities_title =
            h1 [ class "row between-xs" ]
                [ text "Содержание"
                , if model.is_staff || model.teaching_here then
                    button [ class "ui button green", onClick MsgAddActivity ] [ i [ class "icon plus" ] [], text "Добавить" ]

                  else
                    text ""
                ]
    in
    div [ style "padding-bottom" "3em" ]
        [ modal_members model.show_members
        , modal_add_activity model.add_activity.show_form
        , breadcrumbs
        , header
        , activities_title
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
            MessageBox.view Error Nothing (text "Ошибка") (text <| "Не удалось получить данные курса: " ++ err)

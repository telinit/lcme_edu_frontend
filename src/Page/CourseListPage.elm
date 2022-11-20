module Page.CourseListPage exposing (..)

import Api exposing (ext_task, task, withToken)
import Api.Data exposing (CourseShallow, EducationSpecialization, File)
import Api.Request.Course exposing (courseList)
import Api.Request.Education exposing (educationSpecializationList)
import Component.MultiTask as MT
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Util exposing (dictGroupBy, httpErrorToString, task_to_cmd)
import Uuid exposing (Uuid)


type Msg
    = CourseListFetchFailed String
    | MsgFetch (MT.Msg Http.Error FetchedData)


type FetchedData
    = FetchedCourses (List CourseShallow)
    | FetchedSpecs (List EducationSpecialization)


type State
    = Loading (MT.Model Http.Error FetchedData)
    | Completed (List CourseShallow) (Dict String EducationSpecialization)
    | Error String


type GroupBy
    = GroupByNone
    | GroupByClass


type alias Model =
    { state : State, token : String, group_by : GroupBy }


empty_to_nothing : Maybe String -> Maybe String
empty_to_nothing x =
    case x of
        Just "" ->
            Nothing

        _ ->
            x


groupBy : GroupBy -> List CourseShallow -> Dict String EducationSpecialization -> Dict String (List CourseShallow)
groupBy group_by courses specs =
    case group_by of
        GroupByNone ->
            Dict.fromList [ ( "", courses ) ]

        GroupByClass ->
            let
                key course =
                    case ( empty_to_nothing course.forClass, course.forSpecialization ) of
                        ( Nothing, _ ) ->
                            "Остальное"

                        ( Just class, Nothing ) ->
                            class

                        ( Just class, Just spec_id ) ->
                            class
                                ++ " ("
                                ++ (Maybe.withDefault "Неизвестное" <|
                                        Maybe.map .name <|
                                            Dict.get (Uuid.toString spec_id) specs
                                   )
                                ++ " направление)"
            in
            dictGroupBy key courses


init : String -> ( Model, Cmd Msg )
init token =
    let
        ( m, c ) =
            MT.init
                [ ( ext_task FetchedCourses token [] courseList, "Получаем список курсов" )
                , ( ext_task FetchedSpecs token [] educationSpecializationList, "Получаем список специализаций" )
                ]
    in
    ( { state = Loading m, token = token, group_by = GroupByClass }, Cmd.map MsgFetch c )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.state ) of
        ( CourseListFetchFailed err, _ ) ->
            ( { model | state = Error err }, Cmd.none )

        ( MsgFetch msg_, Loading model_ ) ->
            let
                ( m, c ) =
                    MT.update msg_ model_
            in
            case msg_ of
                MT.TaskFinishedAll [ Ok (FetchedCourses courses), Ok (FetchedSpecs specs) ] ->
                    ( { model
                        | state =
                            Completed courses <|
                                Dict.fromList <|
                                    List.filterMap (\s -> Maybe.map (\id_ -> ( Uuid.toString id_, s )) s.id) specs
                      }
                    , Cmd.map MsgFetch c
                    )

                _ ->
                    ( { model | state = Loading m }, Cmd.map MsgFetch c )

        ( _, _ ) ->
            ( model, Cmd.none )


viewControls : Html Msg
viewControls =
    text ""


courseImg : Maybe Uuid -> Html Msg
courseImg mb =
    case mb of
        Just file ->
            --TODO: Change with an actual URL
            img [ src ("/file/" ++ Uuid.toString file ++ "/download") ] []

        Nothing ->
            img [ src "/img/course.jpg" ] []


viewCourse : CourseShallow -> Html Msg
viewCourse course =
    a [ class "card", href (Maybe.withDefault "" <| Maybe.map (\id -> "/course/" ++ Uuid.toString id) course.id) ]
        [ div [ class "image" ] [ courseImg course.logo ]
        , div [ class "content" ]
            [ div [ class "header" ] [ text course.title ]
            , div [ class "meta" ] []
            , div
                [ class "description"
                , style "max-height" "300px"
                , style "overflow" "hidden"
                ]
                [ text <| String.trim course.description
                ]
            ]
        , div [ class "extra content row around-xs" ] <|
            List.filterMap identity
                [ Maybe.map (\c -> div [ class "col-xs" ] [ i [ class "users icon" ] [], text (c ++ " класс") ]) course.forClass
                , Maybe.map (\g -> div [ class "col-xs" ] [ i [ class "list ol icon" ] [], text g ]) <| empty_to_nothing course.forGroup
                ]
        ]


view : Model -> Html Msg
view model =
    let
        view_courses cs =
            [ div
                [ class "ui link cards"
                , style "display" "inline-flex"
                , style "margin" "0 -50px"
                ]
                (List.map viewCourse cs)
            ]

        body =
            case model.state of
                Completed [] _ ->
                    [ div [ class "row center-xs" ]
                        [ h2 [] [ text "У вас нет курсов" ] ]
                    ]

                Completed courses specs ->
                    case model.group_by of
                        GroupByNone ->
                            view_courses courses

                        _ ->
                            let
                                grouped =
                                    groupBy model.group_by courses specs
                            in
                            List.concat <|
                                List.map (\( g, cs ) -> [ h2 [] [ text g ] ] ++ view_courses cs) <|
                                    Dict.toList grouped

                Error err ->
                    [ div [ class "ui negative message" ]
                        [ div [ class "header" ] [ text "Ошибка при попытке получения списка предметов" ]
                        , p [] [ text err ]
                        ]
                    ]

                Loading m ->
                    [ Html.map MsgFetch <| MT.view (\_ -> "OK") httpErrorToString m ]
    in
    div [ class "center-xs" ] <|
        [ h1 [] [ text "Доступные предметы" ]
        , viewControls
        ]
            ++ body

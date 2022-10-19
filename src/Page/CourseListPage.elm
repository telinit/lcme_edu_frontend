module Page.CourseListPage exposing (..)

import Api exposing (task, withToken)
import Api.Data exposing (CourseRead, File)
import Api.Request.Course exposing (courseList)
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Util exposing (httpErrorToString, task_to_cmd)
import Uuid exposing (Uuid)


type Msg
    = GotCourses (List CourseRead)
    | CourseListFetchFailed String
    | Retry


type State
    = Loading
    | Completed (List CourseRead)
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


dictGroupBy : (b -> comparable) -> List b -> Dict comparable (List b)
dictGroupBy key list =
    let
        f x acc =
            Dict.update (key x) (Just << Maybe.withDefault [ x ] << Maybe.map (\old_list -> x :: old_list)) acc
    in
    List.foldl f Dict.empty list


groupBy : GroupBy -> List CourseRead -> Dict String (List CourseRead)
groupBy group_by courses =
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

                        ( Just class, Just spec ) ->
                            class ++ " (" ++ spec.name ++ " направление)"
            in
            dictGroupBy key courses


doFetchCourses : String -> Cmd Msg
doFetchCourses token =
    task_to_cmd (httpErrorToString >> CourseListFetchFailed) GotCourses <| task <| withToken (Just token) courseList


init : String -> ( Model, Cmd Msg )
init token =
    ( { state = Loading, token = token, group_by = GroupByClass }, doFetchCourses token )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotCourses cs ->
            ( { model
                | state =
                    Completed <|
                        List.map
                            (\c ->
                                { c
                                    | forClass = empty_to_nothing c.forClass
                                    , forGroup = empty_to_nothing c.forGroup
                                }
                            )
                            cs
              }
            , Cmd.none
            )

        CourseListFetchFailed err ->
            ( { model | state = Error err }, Cmd.none )

        Retry ->
            ( { model | state = Loading }, doFetchCourses model.token )


viewControls : Html Msg
viewControls =
    text ""


courseImg : Maybe File -> Html Msg
courseImg mb =
    case mb of
        Just file ->
            --TODO: Change with an actual URL
            img [ src ("/file/" ++ (Maybe.withDefault "" <| Maybe.map Uuid.toString file.id) ++ "/download") ] []

        Nothing ->
            img [ src "/img/course.jpg" ] []


viewCourse : CourseRead -> Html Msg
viewCourse course =
    a [ class "card", href (Maybe.withDefault "" <| Maybe.map (\id -> "/course/" ++ Uuid.toString id) course.id) ]
        [ div [ class "image" ] [ courseImg course.logo ]
        , div [ class "content" ]
            [ div [ class "header" ] [ text course.title ]
            , div [ class "meta" ] []
            , div [ class "description" ] []
            ]
        , div [ class "extra content" ]
            [ span [ class "" ]
                (Maybe.withDefault [] <| Maybe.map (\c -> [ i [ class "users icon" ] [], text (c ++ " класс") ]) course.forClass)
            , span [ class "right floated" ]
                (Maybe.withDefault [] <| Maybe.map (\g -> [ i [ class "list ol icon" ] [], text g ]) course.forGroup)
            ]
        ]


view : Model -> Html Msg
view model =
    let
        view_courses cs =
            [ div [ class "ui link cards" ] (List.map viewCourse cs) ]

        body =
            case model.state of
                Completed [] ->
                    [ div [ class "row center-xs" ]
                        [ h2 [] [ text "У вас нет курсов" ] ]
                    ]

                Completed courses ->
                    case model.group_by of
                        GroupByNone ->
                            view_courses courses

                        _ ->
                            let
                                grouped =
                                    groupBy model.group_by courses
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

                Loading ->
                    [ div [ class "ui message" ]
                        [ div [ class "ui active inline loader small", style "margin-right" "1em" ] []
                        , text "Загружаем список предметов"
                        ]
                    ]
    in
    div [] <|
        [ h1 [] [ text "Ваши предметы" ]
        , viewControls
        ]
            ++ body

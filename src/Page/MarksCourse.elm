module Page.MarksCourse exposing (..)

import Api.Data exposing (CourseDeep)
import Component.MarkTable as MT
import Component.MultiTask exposing (Msg(..))
import Html exposing (Html, a, div, i, text)
import Html.Attributes exposing (class, href, style)
import Util exposing (get_id_str)
import Uuid exposing (Uuid)


type Msg
    = MsgTable MT.Msg


type alias Model =
    { table : MT.Model
    , token : String
    , course : Maybe CourseDeep
    }


init : String -> Uuid -> Maybe Uuid -> ( Model, Cmd Msg )
init token course_id teacher_id =
    let
        ( m, c ) =
            MT.initForCourse token course_id teacher_id
    in
    ( { table = m, token = token, course = Nothing }, Cmd.map MsgTable c )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MsgTable msg_ ->
            let
                ( m, c ) =
                    MT.update msg_ model.table
            in
            case msg_ of
                MT.MsgFetch (TaskCompleted _ (MT.FetchedCourse course)) ->
                    ( { model | table = m, course = Just course }, Cmd.map MsgTable c )

                _ ->
                    ( { model | table = m }, Cmd.map MsgTable c )


view : Model -> Html Msg
view model =
    let
        breadcrumbs course_ =
            case course_ of
                Just course ->
                    div [ class "ui large breadcrumb" ]
                        [ a [ class "section", href "/courses" ]
                            [ text "Предметы" ]
                        , i [ class "right chevron icon divider" ]
                            []
                        , a [ class "section", href <| "/course/" ++ get_id_str course ]
                            [ text course.title ]
                        , i [ class "right chevron icon divider" ]
                            []
                        , div [ class "active section" ]
                            [ text "Оценки" ]
                        ]

                Nothing ->
                    div [ class "ui large breadcrumb" ]
                        [ a [ class "section", href "/courses" ]
                            [ text "Предметы" ]
                        , i [ class "right chevron icon divider" ]
                            []
                        , div [ class "ui active inline loader tiny", style "margin-right" "1em" ] []
                        ]
    in
    div []
        [ breadcrumbs model.course
        , div
            [ class "row center-xs mt-20"
            , style "position" "absolute"
            , style "left" "0"
            , style "right" "0"
            ]
            [ div [class "col"] [Html.map MsgTable <| MT.view model.table]
            ]
        ]

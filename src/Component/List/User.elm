module Component.List.User exposing (..)

import Api exposing (ext_task)
import Api.Data exposing (EducationSpecialization, UserShallow)
import Api.Request.Education exposing (educationSpecializationList)
import Api.Request.User exposing (userList)
import Component.Misc exposing (user_link)
import Component.MultiTask as MT
import Component.Select as Select
import Css.Transitions exposing (background)
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onCheck, onInput)
import Http
import Page.CourseListPage exposing (empty_to_nothing)
import Util exposing (get_id_str, httpErrorToString, user_full_name)
import Uuid


type Msg
    = MsgLoading (MT.Msg Http.Error LoadingResult)
    | MsgSpecSelect Select.Msg
    | MsgSelectUser String Bool
    | MsgOnInputSearchText String
    | MsgOnInputCurrentClass String


type alias Filter =
    { searchText : String
    , currentClass : String
    , currentSpec : Select.Model
    }


type LoadingResult
    = LoadingResultUsers (List UserShallow)
    | LoadingResultSpecs (List EducationSpecialization)


type State
    = Loading (MT.Model Http.Error LoadingResult)
    | Idle Filter (Dict String UserShallow)


type alias Model =
    { state : State
    , token : String
    , selected : Dict String UserShallow
    , selectable : Bool
    }


showLoadingResult : LoadingResult -> String
showLoadingResult loadingResult =
    case loadingResult of
        LoadingResultUsers _ ->
            "OK"

        LoadingResultSpecs _ ->
            "OK"


applyFilter : Filter -> List UserShallow -> List UserShallow
applyFilter filter users =
    let
        mb =
            Maybe.withDefault ""

        filterUser : UserShallow -> Bool
        filterUser u =
            let
                uStr =
                    mb u.firstName
                        ++ " "
                        ++ mb u.lastName
                        ++ " "
                        ++ mb u.middleName

                mSpec =
                    case ( empty_to_nothing filter.currentSpec.selected, u.currentSpec ) of
                        ( Nothing, _ ) ->
                            True

                        ( Just _, Nothing ) ->
                            False

                        ( Just selID, Just uSpec ) ->
                            selID == get_id_str uSpec
            in
            String.contains (String.toLower filter.searchText) (String.toLower uStr)
                && String.contains (String.toLower filter.currentClass) (String.toLower <| mb u.currentClass)
                && mSpec
    in
    List.filter filterUser users


setSelectable : Bool -> Model -> Model
setSelectable selectable model =
    { model | selectable = selectable }


getSelected : Model -> List UserShallow
getSelected model =
    Dict.values model.selected


init : String -> ( Model, Cmd Msg )
init token =
    let
        ( m, c ) =
            MT.init
                [ ( ext_task LoadingResultUsers token [] userList, "Загружаем пользователей" )
                , ( ext_task LoadingResultSpecs token [] educationSpecializationList, "Загружаем направления" )
                ]
    in
    ( { state = Loading m
      , token = token
      , selected = Dict.empty
      , selectable = True
      }
    , Cmd.map MsgLoading c
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MsgLoading msg_ ->
            case model.state of
                Loading model_ ->
                    let
                        ( m, c ) =
                            MT.update msg_ model_
                    in
                    case msg_ of
                        MT.TaskFinishedAll [ Ok (LoadingResultUsers users), Ok (LoadingResultSpecs specs) ] ->
                            let
                                ( sm, sc ) =
                                    Select.init "Направление" True <|
                                        Dict.fromList <|
                                            [ ( "", "Все" ) ]
                                                ++ List.map
                                                    (\s ->
                                                        ( Maybe.withDefault "" <|
                                                            Maybe.map Uuid.toString s.id
                                                        , s.name
                                                        )
                                                    )
                                                    specs
                            in
                            ( { model
                                | state =
                                    Idle
                                        { searchText = ""
                                        , currentClass = ""
                                        , currentSpec = sm
                                        }
                                        (Dict.fromList <| List.map (\u -> ( get_id_str u, u )) users)
                              }
                            , Cmd.map MsgSpecSelect sc
                            )

                        _ ->
                            ( { model | state = Loading m }, Cmd.map MsgLoading c )

                Idle _ _ ->
                    ( model, Cmd.none )

        MsgSpecSelect msg_ ->
            case model.state of
                Idle flt usr ->
                    let
                        ( m, c ) =
                            Select.update msg_ flt.currentSpec
                    in
                    ( { model | state = Idle { flt | currentSpec = m } usr }, Cmd.map MsgSpecSelect c )

                Loading _ ->
                    ( model, Cmd.none )

        MsgSelectUser sUID bSelected ->
            case model.state of
                Idle _ users ->
                    if bSelected then
                        ( { model
                            | selected = Dict.update sUID (\_ -> Dict.get sUID users) model.selected
                          }
                        , Cmd.none
                        )

                    else
                        ( { model | selected = Dict.remove sUID model.selected }, Cmd.none )

                Loading _ ->
                    ( model, Cmd.none )

        MsgOnInputSearchText v ->
            case model.state of
                Idle filters users ->
                    ( { model | state = Idle { filters | searchText = v } users }, Cmd.none )

                Loading _ ->
                    ( model, Cmd.none )

        MsgOnInputCurrentClass v ->
            case model.state of
                Idle filters users ->
                    ( { model | state = Idle { filters | currentClass = v } users }, Cmd.none )

                Loading _ ->
                    ( model, Cmd.none )


viewFilter : Filter -> Html Msg
viewFilter flt =
    div [ class "ui segment col-xs-12", style "background-color" "#EEE" ]
        [ div [ class "row mb-10" ]
            [ div [ class "ui fluid input col-xs-12" ]
                [ input
                    [ type_ "text"
                    , value flt.searchText
                    , placeholder "ФИО"
                    , onInput MsgOnInputSearchText
                    ]
                    []
                ]
            ]
        , div [ class "row" ]
            [ div [ class "col-xs-12 col-sm-6" ]
                [ div [ class "ui fluid input" ]
                    [ input
                        [ type_ "text"
                        , value flt.currentClass
                        , placeholder "Класс"
                        , onInput MsgOnInputCurrentClass
                        ]
                        []
                    ]
                ]
            , div [ class "col-xs-12 col-sm-6" ]
                [ div [ class "ui fluid input" ]
                    [ Html.map MsgSpecSelect <| Select.view flt.currentSpec
                    ]
                ]
            ]
        ]


viewUser : Bool -> Bool -> UserShallow -> Html Msg
viewUser selectable selected user =
    div [ class "row m-10 mt-20 middle-xs", style "font-size" "16pt" ]
        [ if selectable then
            div [ class "ui checkbox", style "scale" "1.5" ]
                [ input
                    [ attribute "tabindex" "0"
                    , type_ "checkbox"
                    , checked selected
                    , onCheck (MsgSelectUser <| get_id_str user)
                    ]
                    []
                , label [] []
                ]

          else
            text ""
        , user_link Nothing user
        ]


viewUsers : Model -> Html Msg
viewUsers model =
    case model.state of
        Idle filter users ->
            let
                filtered =
                    List.take 100 <|
                        List.sortBy user_full_name <|
                            applyFilter filter <|
                                Dict.values users
            in
            div [ class "col-xs-12" ]
                [ div [] <|
                    List.map (\u -> viewUser model.selectable (Dict.member (get_id_str u) model.selected) u) filtered
                , if List.length filtered >= 100 then
                    div
                        [ class "row center-xs middle-xs"
                        , style "font-size" "10pt"
                        , style "color" "#777"
                        ]
                        [ text "Отображаются первые 100 пользователей" ]

                  else
                    text ""
                ]

        _ ->
            text "User.viewUsers: ERR"


view : Model -> Html Msg
view model =
    case model.state of
        Loading model_ ->
            Html.map MsgLoading <|
                MT.view showLoadingResult httpErrorToString model_

        Idle filter _ ->
            div [ style "min-height" "250px" ]
                [ div [ class "row" ] [ viewFilter filter ]
                , div [ class "row" ] [ viewUsers model ]
                ]

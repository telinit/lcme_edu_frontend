module Page.UserProfile exposing (..)

import Api exposing (ext_task)
import Api.Data exposing (UserDeep)
import Api.Request.User exposing (userGetDeep)
import Component.MultiTask as MT exposing (Msg(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Util exposing (get_id, httpErrorToString, user_deep_to_shallow, user_full_name, user_has_any_role)
import Uuid exposing (Uuid)


type Msg
    = MsgTask (MT.Msg Http.Error TaskResult)
    | MsgChangeEmail
    | MsgChangePassword


type TaskResult
    = TaskResultUser UserDeep


type State
    = Loading (MT.Model Http.Error TaskResult)
    | Complete UserDeep


type alias Model =
    { token : String
    , state : State
    , for_uid : Uuid
    , changing_email : Bool
    , changing_password : Bool
    }


init : String -> UserDeep -> Maybe Uuid -> ( Model, Cmd Msg )
init token user mb_profile_id =
    case mb_profile_id of
        Just uid ->
            let
                ( m, c ) =
                    MT.init
                        [ ( ext_task TaskResultUser token [] <| userGetDeep <| Uuid.toString uid, "Загрузка профиля" )
                        ]
            in
            ( { token = token
              , state = Loading m
              , for_uid = uid
              , changing_email = False
              , changing_password = False
              }
            , Cmd.map MsgTask c
            )

        Nothing ->
            ( { token = token
              , state = Complete user
              , for_uid = get_id user
              , changing_email = False
              , changing_password = False
              }
            , Cmd.none
            )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.state ) of
        ( MsgTask msg_, Loading model_ ) ->
            let
                ( m, c ) =
                    MT.update msg_ model_
            in
            case msg_ of
                TaskFinishedAll [ Ok (TaskResultUser user) ] ->
                    ( { model | state = Complete user }, Cmd.map MsgTask c )

                _ ->
                    ( { model | state = Loading m }, Cmd.map MsgTask c )

        ( MsgChangeEmail, Complete model_ ) ->
            ( { model | changing_email = True }, Cmd.none )

        ( MsgChangePassword, Complete model_ ) ->
            ( { model | changing_password = True }, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )


viewRole : String -> Html Msg
viewRole role =
    case role of
        "admin" ->
            span [ style "color" "#C00" ]
                [ i [ class "icon superpowers mr-10" ] []
                , text "Администратор"
                ]

        "staff" ->
            span [ style "color" "#EC7F00FF" ]
                [ i [ class "icon user mr-10" ] []
                , text "Сотрудник ЛНМО"
                ]

        "teacher" ->
            span [ style "color" "#5569EEFF" ]
                [ i [ class "icon user mr-10" ] []
                , text "Преподаватель"
                ]

        "student" ->
            span []
                [ i [ class "icon user mr-10" ] []
                , text "Учащийся"
                ]

        "parent" ->
            span []
                [ i [ class "icon user mr-10" ] []
                , text "Родитель"
                ]

        _ ->
            text ""


viewEducation : Model -> Html Msg
viewEducation model =
    text "Edu"


view : Model -> Html Msg
view model =
    case model.state of
        Loading model_ ->
            div [ class "ui text container" ]
                [ Html.map MsgTask <| MT.view (\_ -> "OK") httpErrorToString model_
                ]

        Complete user ->
            let
                fio =
                    user_full_name <| user_deep_to_shallow user

                roles =
                    Maybe.withDefault (text "(нет)") <| Maybe.map (List.map (viewRole >> List.singleton >> div [ class "row", style "width" "100%" ]) >> div []) user.roles

                show_email =
                    user_has_any_role user [ "staff", "admin" ] || model.for_uid == get_id user

                show_password =
                    show_email

                email_row =
                    div [ class "ml-15 row between-xs", style "text-align" "left" ]
                      [ if model.changing_email then
                          div [ class "ui input mr-10" ]
                              [ input [ placeholder "Новый адрес", type_ "text" ]
                                  []
                              ]
                    
                        else
                          span [] [ text <| Maybe.withDefault "" user.email ]
                      , button [ class "ui button", onClick MsgChangeEmail ]
                          ( if model.changing_email then
                              [i [class "check icon", style "color" "green"] [], text "Применить"]
                    
                            else
                              [i [class "edit outline icon", style "color" "rgb(65, 131, 196)"] [], text "Изменить"]
                          )
                      ]

                password_row =
                    div [ class "ml-15 row middle-xs between-xs", style "text-align" "left" ]
                      [ if model.changing_password then
                          div [ class "ui input mr-10" ]
                              [ input [ placeholder "Новый пароль", type_ "text" ]
                                  []
                              ]
                    
                        else
                          span [ style "font-size" "16pt" ] [ text "*****" ]
                      , button [ class "ui button", onClick MsgChangePassword ]
                          ( if model.changing_password then
                              [i [class "check icon", style "color" "green"] [], text "Применить"]
                    
                            else
                              [i [class "edit outline icon", style "color" "rgb(65, 131, 196)"] [], text "Изменить"]
                          )
                      ]
            in
            div []
                [ div [ class "row center-xs m-10" ] [ h1 [] [ text "Профиль пользователя" ] ]
                , div [ class "row center-xs start-md" ]
                    [ div [ class "col-12-xs col-3-sm m-10", style "min-height" "200px" ]
                        [ img [ src <| Maybe.withDefault "/img/user.png" user.avatar ] []
                        ]
                    , div [ class "col-12-xs col-9-sm m-10" ]
                        [ h3 [] [ text "Личная информация" ]
                        , table []
                            [ tbody []
                                [ tr []
                                    [ td
                                        [ style "text-align" "right"
                                        , style "min-width" "80px"
                                        , style "font-weight" "bold"
                                        ]
                                        [ text "ФИО:" ]
                                    , td [ style "min-width" "400px", style "text-align" "left" ]
                                        [ span [ class "ml-15" ] [ text fio ] ]
                                    ]
                                , tr []
                                    [ td
                                        [ style "text-align" "right"
                                        , style "vertical-align" "top"
                                        , style "font-weight" "bold"
                                        ]
                                        [ text "Роли:" ]
                                    , td []
                                        [ div [ class "ml-20", style "text-align" "left" ] [ roles ] ]
                                    ]
                                , if show_email then
                                    tr []
                                        [ td
                                            [ style "text-align" "right"
                                            , style "vertical-align" "middle"
                                            , style "font-weight" "bold"
                                            ]
                                            [ text "Email:" ]
                                        , td []
                                            [ email_row
                                            ]
                                        ]

                                  else
                                    text ""
                                , if show_password then
                                    tr []
                                        [ td
                                            [ style "text-align" "right"
                                            , style "vertical-align" "middle"
                                            , style "font-weight" "bold"
                                            ]
                                            [ text "Пароль:" ]
                                        , td []
                                            [ password_row
                                            ]
                                        ]

                                  else
                                    text ""
                                ]
                            ]
                        ]
                    ]
                , div [ class "row center-xs start-md mt-10" ]
                    [ div []
                        [ h1 [] [ text "Образование" ]
                        , div [] [ viewEducation model ]
                        ]
                    ]
                ]

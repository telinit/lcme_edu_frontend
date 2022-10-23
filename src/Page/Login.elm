module Page.Login exposing (..)

import Api exposing (send, task, withToken)
import Api.Data exposing (Token, User)
import Api.Request.User exposing (userLogin, userSelf)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Ports exposing (setStorage)
import Task exposing (mapError)
import Time
import Util exposing (httpErrorToString, link_span, task_to_cmd)


type UserMessage
    = None
    | Info String
    | Error String


type ModelState
    = Login
    | PasswordReset
    | CheckingStored
    | LoggingIn
    | ResettingPassword
    | Success { token : String, user : User }


type alias Model =
    { username : String
    , password : String
    , message : UserMessage
    , state : ModelState
    , token : String
    }


type Msg
    = DoLogin
    | DoPasswordReset
    | ShowLogin
    | ShowPasswordReset
    | LoginCompleted Token
    | LoginFailed String
    | CheckSessionFailed String
    | CloseMessage
    | ModelSetUsername String
    | ModelSetPassword String


doLogin : String -> String -> Cmd Msg
doLogin username password =
    let
        onResult r =
            case r of
                Ok token ->
                    LoginCompleted token

                Err (Http.BadStatus 403) ->
                    LoginFailed "Неправильно указаны данные учетной записи"

                Err e ->
                    LoginFailed <| httpErrorToString e
    in
    userLogin { username = username, password = password } |> send onResult


doCheckSession : String -> Cmd Msg
doCheckSession token =
    let
        hide_error =
            mapError (\_ -> Nothing)

        task_user =
            withToken (Just token) userSelf
                |> task
                |> mapError
                    (\e ->
                        Just <|
                            "Произошла ошибка при попытке восстановить текущую сессию. Возможно, имеются проблемы "
                                ++ "с вашим интенет-подключением или сервер API в данный момент недоступен: "
                                ++ httpErrorToString e
                    )

        task_date =
            Time.now |> hide_error
    in
    Task.map2 (\x y -> ( x, y )) task_user task_date
        |> task_to_cmd
            (\err ->
                if token == "" then
                    ShowLogin

                else
                    CheckSessionFailed <| Maybe.withDefault "" err
            )
            (\( user, time ) -> LoginCompleted { key = token, user = user })


doSaveToken : String -> Cmd Msg
doSaveToken token =
    setStorage { key = "token", value = token }



-- TODO: Password reset


doPasswordReset : String -> Cmd Msg
doPasswordReset username =
    Cmd.none


init : String -> ( Model, Cmd Msg )
init token =
    ( { username = "", password = "", message = None, state = CheckingStored, token = token }, doCheckSession token )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.state ) of
        ( DoLogin, Login ) ->
            ( { model | state = LoggingIn }, doLogin model.username model.password )

        ( DoPasswordReset, PasswordReset ) ->
            ( { model | state = ResettingPassword }, doPasswordReset model.username )

        ( CheckSessionFailed err, CheckingStored ) ->
            ( { model | message = Error err, state = Login }, Cmd.none )

        ( ShowPasswordReset, _ ) ->
            ( { model | state = PasswordReset, message = None }, Cmd.none )

        ( ShowLogin, _ ) ->
            ( { model | state = Login, message = None }, Cmd.none )

        ( LoginCompleted token, _ ) ->
            ( { model | state = Success { token = token.key, user = token.user }, message = None }, doSaveToken token.key )

        ( LoginFailed reason, _ ) ->
            ( { model | state = Login, message = Error reason }, Cmd.none )

        ( CloseMessage, _ ) ->
            ( { model | message = None }, Cmd.none )

        ( ModelSetUsername u, _ ) ->
            ( { model | username = u }, Cmd.none )

        ( ModelSetPassword p, _ ) ->
            ( { model | password = p }, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    let
        blue_button label on_click =
            div [ class "ui fluid large blue submit button", onClick on_click ] [ text label ]

        progress txt =
            div [ class "ui message" ] [ div [ class "ui active inline loader small" ] [], text <| "  " ++ txt ]

        msg m =
            case m of
                None ->
                    text ""

                Info s ->
                    div [ class "ui message" ]
                        [ i [ class "close icon", onClick CloseMessage ] []
                        , div [ class "header" ] [ text "Ошибка входа" ]
                        , p [] [ text s ]
                        ]

                Error s ->
                    div [ class "ui negative message" ]
                        [ i [ class "close icon", onClick CloseMessage ] []
                        , div [ class "header" ] [ text "Ошибка входа" ]
                        , p [] [ text s ]
                        ]

        pw_reset =
            div [ class "ui message" ] [ text "Забыли пароль?  ", link_span [ onClick ShowPasswordReset ] [ text "Восстановите" ], text " его." ]

        back_to_login =
            div [ class "ui message" ] [ link_span [ onClick ShowLogin ] [ text "Назад" ], text " к форме входа." ]

        form =
            case model.state of
                Login ->
                    div []
                        [ Html.form [ class "ui large form", onSubmit DoLogin ]
                            [ div [ class "ui stacked segment" ]
                                [ viewField "text" model.username "Логин" "user" ModelSetUsername
                                , viewField "password" model.password "Пароль" "lock" ModelSetPassword
                                , blue_button "Войти" DoLogin
                                ]
                            ]
                        , pw_reset
                        ]

                PasswordReset ->
                    div []
                        [ Html.form [ class "ui large form", onSubmit DoPasswordReset ]
                            [ div [ class "ui stacked segment" ]
                                [ viewField "text" model.username "Логин" "user" ModelSetUsername
                                , blue_button "Восстановить" DoPasswordReset
                                ]
                            ]
                        , back_to_login
                        ]

                Success { token, user } ->
                    let
                        a =
                            "Аноним"

                        nm =
                            case user.firstName of
                                Just "" ->
                                    a

                                Nothing ->
                                    a

                                Just x ->
                                    x
                    in
                    div [ class "ui message" ] [ text <| "Привет, " ++ nm ]

                CheckingStored ->
                    progress "Проверяем текущую сессию"

                LoggingIn ->
                    progress "Выполняется вход"

                ResettingPassword ->
                    progress "Выполняется сброс пароля"
    in
    div
        [ class "row center-xs middle-xs"
        , style "height" "100%"
        , style "background-color" "#EEE"
        ]
        [ div [ class "col-4" ]
            [ div [ class "box", style "width" "400px" ]
                [ h2 [ class "ui blue image header" ] [ div [ class "content" ] [ text "Вход в систему" ] ]
                , form
                , msg model.message
                ]
            ]
        ]


viewField field_type value_ placeholder_ icon on_input =
    div [ class "field" ]
        [ div [ class "ui left icon input" ]
            [ i [ classList [ ( icon, True ), ( "icon", True ) ] ] []
            , input [ type_ field_type, value value_, placeholder placeholder_, onInput on_input ] []
            ]
        ]

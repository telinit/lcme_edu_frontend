module Page.Login exposing (..)

import Api exposing (send)
import Api.Data exposing (Token)
import Api.Request.User exposing (userLogin, userSelf)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Util exposing (httpErrorToString)


type Model
    = Login { username : String, password : String }
    | PasswordReset { username : String }
    | Working String
    | Success { token : Token }
    | Error String


type Msg
    = DoLogin
    | DoPasswordReset
    | ShowPasswordReset
    | LoginCompleted Token
    | LoginFailed String
    | CloseError
    | ModelSetUsername String
    | ModelSetPassword String


init : () -> ( Model, Cmd Msg )
init () =
    ( Login { username = "", password = "" }, Cmd.none )


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



-- TODO: Password reset


doPasswordReset : String -> Cmd Msg
doPasswordReset username =
    Cmd.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( DoLogin, Login { username, password } ) ->
            ( Working "Выполняется вход", doLogin username password )

        ( DoPasswordReset, PasswordReset { username } ) ->
            ( Working "Выполняется сброс пароля", doPasswordReset username )

        ( ShowPasswordReset, Login { username } ) ->
            ( PasswordReset { username = username }, Cmd.none )

        ( ShowPasswordReset, _ ) ->
            ( PasswordReset { username = "" }, Cmd.none )

        ( LoginCompleted token, Working _ ) ->
            ( Success { token = token }, Cmd.none )

        ( LoginFailed reason, _ ) ->
            ( Error reason, Cmd.none )

        ( CloseError, _ ) ->
            init ()

        ( ModelSetUsername u, Login login ) ->
            ( Login { login | username = u }, Cmd.none )

        ( ModelSetPassword p, Login login ) ->
            ( Login { login | password = p }, Cmd.none )

        ( ModelSetUsername u, PasswordReset pr ) ->
            ( PasswordReset { pr | username = u }, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    let
        blue_button label on_click =
            div [ class "ui fluid large blue submit button", onClick on_click ] [ text label ]

        pw_reset =
            div [ class "ui message" ] [ text "Забыли пароль?  ", a [ href "", onClick ShowPasswordReset ] [ text "Восстановите" ], text " его." ]

        form =
            case model of
                Login { username, password } ->
                    div []
                        [ Html.form [ class "ui large form", onSubmit DoLogin ]
                            [ div [ class "ui stacked segment" ]
                                [ viewField "text" username "Логин" "user" ModelSetUsername
                                , viewField "password" password "Пароль" "lock" ModelSetPassword
                                , blue_button "Войти" DoLogin
                                ]
                            ]
                        , pw_reset
                        ]

                Error err ->
                    div []
                        [ div [ class "ui negative message" ]
                            [ -- i [ class "close icon", onClick CloseError ] []
                              div [ class "header" ] [ text "Ошибка входа" ]
                            , p [] [ text err ]
                            ]
                        , blue_button "Попробовать еще раз" CloseError
                        , pw_reset
                        ]

                PasswordReset { username } ->
                    Html.form [ class "ui large form", onSubmit DoPasswordReset ]
                        [ div [ class "ui stacked segment" ]
                            [ viewField "text" username "Логин" "user" ModelSetUsername
                            , blue_button "Восстановить" DoPasswordReset
                            ]
                        ]

                Working txt ->
                    div [ class "ui message" ] [ div [ class "ui active inline loader small" ] [], text <| "  " ++ txt ]

                Success { token } ->
                    let
                        a =
                            "Аноним"

                        nm =
                            case token.user.firstName of
                                Just "" ->
                                    a

                                Nothing ->
                                    a

                                Just x ->
                                    x
                    in
                    div [ class "ui message" ] [ text <| "Привет, " ++ nm ]
    in
    div
        [ class "ui middle aligned center aligned grid"
        , style "height" "100%"
        , style "background-color" "#EEE"
        ]
        [ div [ class "column", style "max-width" "400px" ]
            [ h2 [ class "ui blue image header" ] [ div [ class "content" ] [ text "Вход в систему" ] ]
            , form
            ]
        ]


viewField field_type value_ placeholder_ icon on_input =
    div [ class "field" ]
        [ div [ class "ui left icon input" ]
            [ i [ classList [ ( icon, True ), ( "icon", True ) ] ] []
            , input [ type_ field_type, value value_, placeholder placeholder_, onInput on_input ] []
            ]
        ]

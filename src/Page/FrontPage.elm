module Page.FrontPage exposing (..)

import Api.Data exposing (UserDeep)
import Component.MessageBox as MessageBox
import Component.Stats as Stats
import Html exposing (Html, a, div, h1, p, text)
import Html.Attributes exposing (class, href)
import Task
import Time exposing (Posix, Zone)
import Util exposing (user_deep_to_shallow, user_full_name)


type Msg
    = MsgStats Stats.Msg
    | MsgCurrentTime Posix
    | MsgGotTZ Zone


type TimeOfDay
    = Morning
    | Day
    | Evening
    | Night


type alias Model =
    { stats : Stats.Model
    , tod : Maybe TimeOfDay
    , user : UserDeep
    , tz : Maybe Zone
    }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every 1000 MsgCurrentTime


init : String -> UserDeep -> ( Model, Cmd Msg )
init token user =
    let
        ( m, c ) =
            Stats.init token
    in
    ( { stats = m
      , tod = Nothing
      , user = user
      , tz = Nothing
      }
    , Cmd.batch
        [ Cmd.map MsgStats c
        , Task.perform MsgGotTZ Time.here
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MsgStats msg_ ->
            let
                ( m, c ) =
                    Stats.update msg_ model.stats
            in
            ( { model | stats = m }, Cmd.map MsgStats c )

        MsgCurrentTime time ->
            let
                hour =
                    Time.toHour (Maybe.withDefault Time.utc model.tz) time

                tod =
                    if hour >= 22 then
                        Night

                    else if hour >= 17 then
                        Evening

                    else if hour >= 11 then
                        Day

                    else if hour >= 7 then
                        Morning

                    else
                        Night
            in
            ( { model | tod = Just tod }, Cmd.none )

        MsgGotTZ zone ->
            ( { model | tz = Just zone }, Cmd.none )


greetTOD : TimeOfDay -> String
greetTOD timeOfDay =
    case timeOfDay of
        Morning ->
            "Доброе утро"

        Day ->
            "Добрый день"

        Evening ->
            "Добрый вечер"

        Night ->
            "Доброй ночи"


view : Model -> Html Msg
view model =
    let
        tod =
            case ( model.tz, model.tod ) of
                ( Just _, Just tod_ ) ->
                    greetTOD tod_

                ( _, _ ) ->
                    "Здравствуйте"

        email_banner =
            MessageBox.view
                MessageBox.Warning
                False
                Nothing
                (text "Не указан email")
                (div []
                    [ text "Убедительно просим указать актуальный адрес вашей электронной почты в вашем "
                    , a [href "/profile"] [text "профиле"]
                    , text ". "
                    , text
                        "Он может понадобиться для восстановления доступа к аккаунту и получения важных оповещений."
                    ]
                )

        email_is_empty =
            Maybe.withDefault True <| Maybe.map (\email -> String.trim email == "") model.user.email

        mb =
            Maybe.withDefault ""
    in
    div []
        [ h1 [] [ text <| tod ++ ", " ++ mb model.user.firstName ++ " " ++ mb model.user.middleName ]
        , div [ class "row" ]
            [ div [ class "col-xs-12 col-md-9" ]
                [ if email_is_empty then
                    email_banner

                  else
                    text ""
                , p [] [
                    text "Приветствуем вас на образовательном портале ЛНМО. Для перехода к интересующим вас разделам, воспользуйтесь меню сверху."
                ]
                ]
            , div [ class "col-xs-12 col-md-3" ]
                [ Html.map MsgStats <| Stats.view model.stats
                ]
            ]
        ]

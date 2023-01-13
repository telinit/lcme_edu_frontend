module Page.UserProfile exposing (..)

import Api exposing (ext_task)
import Api.Data exposing (EducationShallow, Olympiad, OlympiadParticipation, UserDeep)
import Api.Request.Olympiad exposing (olympiadList, olympiadParticipationList)
import Api.Request.User exposing (userGetDeep, userImpersonate, userSetEmail, userSetPassword)
import Browser.Navigation as Url
import Component.Misc exposing (user_link)
import Component.MultiTask as MT exposing (Msg(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error)
import Task
import Time exposing (Zone, utc)
import Util exposing (get_id_str, httpErrorToString, link_span, maybeOrElse, posixToFullDate, taskGetTZ, user_deep_to_shallow, user_full_name, user_has_any_role, zip)
import Uuid exposing (Uuid)


type SettingState
    = SettingStateUnset
    | SettingStateShow String
    | SettingStateChangePrompt String
    | SettingStateChanging String
    | SettingStateChangeError String
    | SettingStateChangeDone


type Msg
    = MsgTask (MT.Msg Http.Error TaskResult)
    | MsgNewEmailValue String
    | MsgNewPasswordValue String
    | MsgChangeEmail
    | MsgChangePassword
    | MsgChangeEmailDone (Result String ())
    | MsgChangePasswordDone (Result String ())
    | MsgOnClickImpersonate
    | MsgImpersonationFinished (Result Error ())
    | MsgOnClickAddOlympiad


type TaskResult
    = TaskResultUser UserDeep
    | TaskResultTZ Zone
    | TaskResultOlympiad (List Olympiad)
    | TaskResultOlympiadParticipation (List OlympiadParticipation)


type State
    = StateLoading (MT.Model Http.Error TaskResult)
    | StateComplete UserDeep (List Olympiad) (List OlympiadParticipation)


type alias Model =
    { token : String
    , state : State
    , current_user : UserDeep
    , user_id : Maybe Uuid
    , state_email : SettingState
    , state_password : SettingState
    , result_impersonation : Maybe (Result Error ())
    , tz : Zone
    }


doChangeEmail : String -> String -> String -> Cmd Msg
doChangeEmail token user_id email =
    Task.attempt MsgChangeEmailDone <|
        Task.mapError httpErrorToString <|
            ext_task identity token [] <|
                userSetEmail user_id { email = email }


doChangePassword : String -> String -> String -> Cmd Msg
doChangePassword token user_id password =
    Task.attempt MsgChangePasswordDone <|
        Task.mapError httpErrorToString <|
            ext_task identity token [] <|
                userSetPassword user_id { password = password }


init : String -> UserDeep -> Maybe Uuid -> ( Model, Cmd Msg )
init token current_user profile_id =
    let
        mbUID =
            maybeOrElse profile_id current_user.id

        sUID =
            Maybe.withDefault "" <| Maybe.map Uuid.toString <| mbUID

        taskUser =
            case profile_id of
                Just _ ->
                    ext_task TaskResultUser token [] <| userGetDeep sUID

                Nothing ->
                    Task.succeed (TaskResultUser current_user)

        ( m, c ) =
            MT.init
                [ ( taskGetTZ TaskResultTZ
                  , "Получение таймзоны"
                  )
                , ( taskUser
                  , "Загрузка профиля"
                  )
                , ( ext_task TaskResultOlympiad token [ ( "participations__person", sUID ) ] olympiadList
                  , "Загрузка олимпиад"
                  )
                , ( ext_task TaskResultOlympiadParticipation token [ ( "person", sUID ) ] olympiadParticipationList
                  , "Загрузка олимпиад (участие)"
                  )
                ]
    in
    ( { token = token
      , current_user = current_user
      , state = StateLoading m
      , user_id = mbUID
      , state_email = SettingStateUnset
      , state_password = SettingStateUnset
      , result_impersonation = Nothing
      , tz = utc
      }
    , Cmd.map MsgTask c
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.state ) of
        ( MsgTask msg_, StateLoading model_ ) ->
            let
                ( m, c ) =
                    MT.update msg_ model_
            in
            case msg_ of
                TaskFinishedAll [ Ok (TaskResultTZ tz), Ok (TaskResultUser user), Ok (TaskResultOlympiad olymp), Ok (TaskResultOlympiadParticipation part) ] ->
                    ( { model
                        | state = StateComplete user olymp part
                        , state_email = SettingStateShow <| Maybe.withDefault "" user.email
                        , state_password = SettingStateShow ""
                        , tz = tz
                      }
                    , Cmd.map MsgTask c
                    )

                _ ->
                    ( { model | state = StateLoading m }, Cmd.map MsgTask c )

        ( MsgChangeEmail, StateComplete user olymp part ) ->
            case model.state_email of
                SettingStateShow old ->
                    ( { model | state_email = SettingStateChangePrompt old }, Cmd.none )

                SettingStateChangePrompt old ->
                    ( { model | state_email = SettingStateChanging old }
                    , doChangeEmail model.token (Maybe.withDefault "" <| Maybe.map Uuid.toString model.user_id) old
                    )

                _ ->
                    ( model, Cmd.none )

        ( MsgChangePassword, StateComplete user olymp part ) ->
            case model.state_password of
                SettingStateShow old ->
                    ( { model | state_password = SettingStateChangePrompt old }, Cmd.none )

                SettingStateChangePrompt old ->
                    ( { model | state_password = SettingStateChanging old }
                    , doChangePassword
                        model.token
                        (Maybe.withDefault "" <| Maybe.map Uuid.toString model.user_id)
                        old
                    )

                _ ->
                    ( model, Cmd.none )

        ( MsgNewEmailValue val, StateComplete user olymp part ) ->
            case model.state_email of
                SettingStateChangePrompt _ ->
                    ( { model | state_email = SettingStateChangePrompt val }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ( MsgNewPasswordValue val, StateComplete user olymp part ) ->
            case model.state_password of
                SettingStateChangePrompt _ ->
                    ( { model | state_password = SettingStateChangePrompt val }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ( MsgChangeEmailDone res, StateComplete user olymp part ) ->
            case res of
                Ok _ ->
                    ( { model | state_email = SettingStateChangeDone }, Cmd.none )

                Err e ->
                    ( { model | state_email = SettingStateChangeError e }, Cmd.none )

        ( MsgChangePasswordDone res, StateComplete user olymp part ) ->
            case res of
                Ok _ ->
                    ( { model | state_password = SettingStateChangeDone }, Cmd.none )

                Err e ->
                    ( { model | state_password = SettingStateChangeError e }, Cmd.none )

        ( MsgOnClickImpersonate, StateComplete user olymp part ) ->
            ( model
            , Task.attempt MsgImpersonationFinished <|
                ext_task identity model.token [] <|
                    userImpersonate <|
                        Maybe.withDefault "" <|
                            Maybe.map Uuid.toString user.id
            )

        ( MsgImpersonationFinished res, _ ) ->
            let
                new_model =
                    { model | result_impersonation = Just res }
            in
            case res of
                Ok _ ->
                    ( new_model, Url.load "/login" )

                Err error ->
                    ( new_model, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )


viewRole : String -> Html Msg
viewRole role =
    let
        ( color, icon, label ) =
            case role of
                "admin" ->
                    ( "#C00", "superpowers", "Администратор" )

                "staff" ->
                    ( "#EC7F00FF", "user", "Сотрудник ЛНМО" )

                "teacher" ->
                    ( "#5569EEFF", "user", "Преподаватель" )

                "student" ->
                    ( "", "user", "Учащийся" )

                "parent" ->
                    ( "", "user", "Родитель" )

                _ ->
                    ( "", "", "" )
    in
    span [ class "mr-10", style "color" color ]
        [ i [ class <| "icon " ++ icon ++ " mr-10" ] []
        , text label
        ]


viewEducation : EducationShallow -> Html Msg
viewEducation edu =
    let
        dep =
            let
                view_spec s i_ c o =
                    div
                        [ style "color" c
                        , style "font-size" "large"
                        , style "white-space" "nowrap"
                        , class "row center-xs"
                        ]
                        [ div [ class "", style "font-size" "xx-large" ]
                            [ i [ class (i_ ++ " icon"), style "position" "relative", style "top" "0px" ] [] ]
                        , div [ class " start-xs" ]
                            [ div [] [ text s ]
                            , div [ class "ml-10", style "color" "initial" ] [ text o ]
                            ]
                        ]
            in
            case ( edu.specialization.name, edu.specialization.department.name, edu.specialization.department.organization.nameShort ) of
                ( "Математическое", _, Just "ЛНМО" ) ->
                    view_spec "Математическое направление" "qrcode" "#2185d0" "ЛНМО"

                ( "Биологическое", _, Just "ЛНМО" ) ->
                    view_spec "Биологическое направление" "leaf" "#21ba45" "ЛНМО"

                ( "Инженерное", _, Just "ЛНМО" ) ->
                    view_spec "Инженерное направление" "cogs" "#db2828" "ЛНМО"

                ( "Гуманитарное", _, Just "ЛНМО" ) ->
                    view_spec "Гуманитарное направление" "users" "#fbbd08" "ЛНМО"

                ( "Академическое", _, Just "ЛНМО" ) ->
                    view_spec "Академическое направление" "book" "#00b5ad" "ЛНМО"

                ( s, _, Just o ) ->
                    view_spec s "question" "black" o

                ( s, _, Nothing ) ->
                    view_spec s "question" "black" "Неизвестная организация"

        start =
            div []
                [ div [ style "font-size" "8pt", style "color" "#555" ] [ text "Начало:" ]
                , div [ class "ml-10", style "font-size" "14pt" ] [ text <| posixToFullDate Time.utc edu.started ]
                ]

        finish =
            div []
                [ div [ style "font-size" "8pt", style "color" "#555" ] [ text "Конец:" ]
                , div [ class "ml-10", style "font-size" "14pt" ]
                    [ text <|
                        Maybe.withDefault "По настоящее время" <|
                            Maybe.map (posixToFullDate Time.utc) <|
                                edu.finished
                    ]
                ]
    in
    div [ class "row middle-xs center-xs between-md start-md ui segment" ]
        [ div [ class "col-xs-12 col-md middle-xs mt-10" ] [ dep ]
        , div [ class "col-xs-12 col-md mt-10 mb-10 ml-100" ] [ start ]
        , div [ class "col-xs-12 col-md" ] [ finish ]
        ]


viewOlympiad : Bool -> ( Zone, Olympiad, OlympiadParticipation ) -> Html Msg
viewOlympiad canEdit ( tz, olympiad, part ) =
    let
        olymp =
            [ div [ class "row nowrap middle-xs center-xs" ]
                [ div [ class "col-xs" ]
                    [ div [ class "row start-xs", style "font-size" "x-large" ] [ text olympiad.name ]
                    , div [ class "row ml-10" ] [ text <| Maybe.withDefault "" olympiad.organization ]
                    ]
                ]
            ]

        date =
            [ div [ style "font-size" "8pt", style "color" "#555", class "center-xs start-sm" ] [ text "Дата:" ]
            , div [ class "ml-10", style "font-size" "14pt" ]
                [ text <| Maybe.withDefault "(Не указана)" <| Maybe.map (posixToFullDate tz) part.date
                ]
            ]

        award =
            [ div [ style "font-size" "8pt", style "color" "#555", class "center-xs start-sm" ] [ text "Награда:" ]
            , div [ class "ml-10", style "font-size" "14pt" ]
                [ text <| Maybe.withDefault "(Не указана)" part.award
                ]
            ]
    in
    div [ class "row ui segment" ]
        [ div [ class "row col-xs-12 col-sm-2 middle-xs center-xs start-sm" ]
            [ img [ src "/img/olympiad.png", width 100, height 100 ] []
            ]
        , div [ class "row nowrap col-sm-10 middle-xs center-xs between-lg" ]
            [ div [ class "col-xs-12 col-md center-xs start-lg mt-10" ] olymp
            , div [ class "col-xs-12 col-md-3 mt-10 mb-10 ml-100" ] date
            , div [ class "col-xs-12 col-md-2" ] award
            ]
        ]


viewEmailRow : Model -> Html Msg
viewEmailRow model =
    let
        v =
            case ( model.state_email, model.state ) of
                ( SettingStateUnset, StateComplete user olymp part ) ->
                    []

                ( SettingStateShow s, StateComplete user olymp part ) ->
                    [ text s
                    , div [ class "col-xs-12 p-0" ]
                        [ link_span [ onClick MsgChangeEmail ]
                            [ i [ class "edit outline icon", style "color" "rgb(65, 131, 196)" ] []
                            , text "Изменить"
                            ]
                        ]
                    ]

                ( SettingStateChangePrompt s, StateComplete user olymp part ) ->
                    [ div [ class "ui input mr-10" ]
                        [ input
                            [ placeholder "Новый адрес"
                            , type_ "text"
                            , value s
                            , onInput MsgNewEmailValue
                            ]
                            []
                        ]
                    , button [ class "ui button", onClick MsgChangeEmail ]
                        [ i [ class "check icon", style "color" "green" ] []
                        , text "Применить"
                        ]
                    ]

                ( SettingStateChanging s, StateComplete user olymp part ) ->
                    [ div [ class "ui disabled input mr-10" ]
                        [ input
                            [ placeholder "Новый адрес"
                            , type_ "text"
                            , value s
                            ]
                            []
                        ]
                    , button [ class "ui disabled button", onClick MsgChangeEmail ]
                        [ div [ class "ui active inline loader small" ] []
                        , span [ class "pl-10" ] [ text "Применить" ]
                        ]
                    ]

                ( SettingStateChangeError err, StateComplete user olymp part ) ->
                    [ h3 []
                        [ i [ style "color" "rgb(219, 40, 40)", class "x icon" ] []
                        , text <| "Ошибка: " ++ err
                        ]
                    ]

                ( SettingStateChangeDone, StateComplete user olymp part ) ->
                    [ h3 []
                        [ i [ style "color" "rgb(33, 186, 69)", class "check icon" ] []
                        , text "Email изменен."
                        ]
                    ]

                ( _, _ ) ->
                    []
    in
    div [ class "ml-15 row between-xs", style "text-align" "left" ] v


viewPassword : Model -> Html Msg
viewPassword model =
    let
        v =
            case ( model.state_password, model.state ) of
                ( SettingStateUnset, StateComplete user olymp part ) ->
                    []

                ( SettingStateShow s, StateComplete user olymp part ) ->
                    [ text s
                    , div [ class "col-xs-12 p-0" ]
                        [ link_span [ onClick MsgChangePassword ]
                            [ i [ class "edit outline icon", style "color" "rgb(65, 131, 196)" ] []
                            , text "Изменить"
                            ]
                        ]
                    ]

                ( SettingStateChangePrompt s, StateComplete user olymp part ) ->
                    [ div [ class "ui input mr-10" ]
                        [ input
                            [ placeholder "Новый пароль"
                            , type_ "password"
                            , value s
                            , onInput MsgNewPasswordValue
                            ]
                            []
                        ]
                    , button [ class "ui button", onClick MsgChangePassword ]
                        [ i [ class "check icon", style "color" "green" ] []
                        , text "Применить"
                        ]
                    ]

                ( SettingStateChanging s, StateComplete user olymp part ) ->
                    [ div [ class "ui disabled input mr-10" ]
                        [ input
                            [ placeholder "Новый пароль"
                            , type_ "password"
                            , value s
                            ]
                            []
                        ]
                    , button
                        [ class "ui disabled button"
                        , onClick MsgChangePassword
                        ]
                        [ div [ class "ui active inline loader small" ] []
                        , span [ class "pl-10" ] [ text "Применить" ]
                        ]
                    ]

                ( SettingStateChangeError err, StateComplete user olymp part ) ->
                    [ h3 []
                        [ i [ style "color" "rgb(219, 40, 40)", class "x icon" ] []
                        , text <| "Ошибка: " ++ err
                        ]
                    ]

                ( SettingStateChangeDone, StateComplete user olymp part ) ->
                    [ h3 []
                        [ i [ style "color" "rgb(33, 186, 69)", class "check icon" ] []
                        , text "Пароль изменен."
                        ]
                    ]

                ( _, _ ) ->
                    []
    in
    div [ class "ml-15 row between-xs", style "text-align" "left" ] v


view : Model -> Html Msg
view model =
    case model.state of
        StateLoading model_ ->
            div [ class "ui text container" ]
                [ Html.map MsgTask <| MT.view (\_ -> "OK") httpErrorToString model_
                ]

        StateComplete user olymp olympPart ->
            let
                fio =
                    user_full_name <| user_deep_to_shallow user

                roles =
                    Maybe.withDefault (text "") <|
                        Maybe.map (List.map viewRole >> div []) user.roles

                is_admin =
                    user_has_any_role model.current_user [ "admin" ]

                is_own_page =
                    model.current_user.id == user.id

                is_staff_or_own_page =
                    user_has_any_role model.current_user [ "staff", "admin" ] || is_own_page

                is_related =
                    is_parent || is_child

                is_parent =
                    List.any ((==) model.current_user.id) <|
                        List.map .id <|
                            user.parents

                is_child =
                    List.any ((==) model.current_user.id) <|
                        List.map .id <|
                            user.children

                show_email =
                    is_staff_or_own_page

                show_password =
                    is_staff_or_own_page

                show_parents =
                    is_staff_or_own_page || is_related

                show_children =
                    is_staff_or_own_page || is_related

                can_manage_olympiads =
                    is_staff_or_own_page || is_parent

                education =
                    List.map viewEducation <| List.sortBy (.started >> Time.posixToMillis >> (*) -1) user.education

                olympiads =
                    List.map
                        (\( o, p ) ->
                            viewOlympiad can_manage_olympiads ( model.tz, o, p )
                        )
                    <|
                        zip olymp olympPart

                impersonation_icon =
                    case model.result_impersonation of
                        Just (Ok _) ->
                            i [ class "check icon" ] []

                        Just (Err _) ->
                            i [ class "x icon" ] []

                        Nothing ->
                            i [ class "key icon" ] []
            in
            div [ class "ml-10 mr-10" ]
                [ div [ class "row center-xs start-lg" ]
                    [ div [ class "col m-10" ]
                        [ img
                            [ class "row center-xs"
                            , src <| Maybe.withDefault "/img/user.png" user.avatar
                            , width 300
                            , height 300
                            ]
                            []
                        ]
                    , div [ class "col-xs-12 col-md-8 m-10" ]
                        [ h1 [] [ text fio ]
                        , div [ class "ml-20 mb-30" ] [ roles ]
                        , div [class "row center-xs start-sm"]
                            [ table [ style "font-size" "12pt", style "margin" "0" ]
                                [ tbody []
                                    [ Maybe.withDefault (text "") <|
                                        Maybe.map
                                            (\cls ->
                                                tr []
                                                    [ td
                                                        [ style "text-align" "right"
                                                        , style "vertical-align" "top"
                                                        , style "font-weight" "bold"
                                                        , class "pb-20"
                                                        ]
                                                        [ text "Класс:" ]
                                                    , td [ style "vertical-align" "top" ]
                                                        [ span [ class "ml-10" ] [ text cls ]
                                                        ]
                                                    ]
                                            )
                                            user.currentClass
                                    , if show_parents then
                                        tr []
                                            [ td
                                                [ style "text-align" "right"
                                                , style "vertical-align" "top"
                                                , style "font-weight" "bold"
                                                , class "pb-20"
                                                ]
                                                [ text "Родители:" ]
                                            , td [ style "vertical-align" "top" ]
                                                [ div [ class "ml-15" ]
                                                    (if user.parents == [] then
                                                        [ span [] [ text "(нет)" ] ]

                                                     else
                                                        List.map (user_link Nothing >> List.singleton >> div []) user.parents
                                                    )
                                                ]
                                            ]

                                      else
                                        text ""
                                    , if show_children then
                                        tr []
                                            [ td
                                                [ style "text-align" "right"
                                                , style "vertical-align" "top"
                                                , style "font-weight" "bold"
                                                , class "pb-20"
                                                ]
                                                [ text "Дети:" ]
                                            , td [ style "vertical-align" "top" ]
                                                [ div [ class "ml-15" ]
                                                    (if user.children == [] then
                                                        [ span [] [ text "(нет)" ] ]

                                                     else
                                                        List.map (user_link Nothing >> List.singleton >> div []) user.children
                                                    )
                                                ]
                                            ]

                                      else
                                        text ""
                                    , if show_email then
                                        tr [ style "min-height" "45px" ]
                                            [ td
                                                [ style "text-align" "right"
                                                , style "vertical-align" "top"
                                                , style "font-weight" "bold"
                                                , class "pb-20"
                                                ]
                                                [ text "Email:" ]
                                            , td [ style "vertical-align" "top" ]
                                                [ viewEmailRow model ]
                                            ]

                                      else
                                        text ""
                                    , if show_password then
                                        tr [ style "min-height" "45px" ]
                                            [ td
                                                [ style "text-align" "right"
                                                , style "vertical-align" "top"
                                                , style "font-weight" "bold"
                                                , class "pb-20"
                                                ]
                                                [ text "Пароль:" ]
                                            , td [ style "vertical-align" "top" ]
                                                [ viewPassword model ]
                                            ]

                                      else
                                        text ""
                                    ]
                                ]
                            ]
                        ]
                    ]
                , div [ class "row center-xs start-lg" ]
                    [ div [ class "col-xs-12 col-sm-6 col-md-4 col-lg-3" ]
                        [ if (is_staff_or_own_page || is_related) && not is_own_page then
                            div [ class "row center-xs mb-10" ]
                                [ a [ class "col-xs-12", href <| "/marks/student/" ++ get_id_str user ]
                                    [ button [ class "ui fluid button" ]
                                        [ i [ class "chart bar outline icon" ] []
                                        , text "Оценки"
                                        ]
                                    ]
                                ]

                          else
                            text ""
                        , if is_admin && not is_own_page then
                            div [ class "row center-xs" ]
                                [ a [ class "col-xs-12", onClick MsgOnClickImpersonate ]
                                    [ button [ class "ui fluid button" ]
                                        [ impersonation_icon
                                        , text "Зайти от имени пользователя"
                                        ]
                                    ]
                                ]

                          else
                            text ""
                        ]
                    ]
                , div [ class "row center-xs start-sm mt-30" ]
                    [ div [ class "col-xs-12" ]
                        [ h1 [] [ text "Образование" ]
                        , if user.education == [] then
                            span [ class "ml-20" ] [ text "(Нет данных)" ]

                          else
                            div [] education
                        ]
                    ]
                , div [ class "row center-xs start-md mt-30" ]
                    [ div [ class "col-xs-12" ]
                        [ h1 [ class "row center-xs between-sm" ]
                            [ div [ class "col-xs-12 col-sm-1" ] [ text "Олимпиады" ]
                            , if can_manage_olympiads then
                                div [ class "col-xs-12 col-sm-3 center-xs end-sm" ]
                                    [ button [ class "ui green button", onClick MsgOnClickAddOlympiad ]
                                        [ i [ class "plus icon" ] []
                                        , text "Добавить"
                                        ]
                                    ]

                              else
                                div [] []
                            ]
                        , if olympiads == [] then
                            span [ class "ml-20" ] [ text "(Нет данных)" ]

                          else
                            div [] olympiads
                        ]
                    ]
                , div [ class "p-10" ] []
                ]

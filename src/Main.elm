module Main exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Api.Data exposing (Token)
import Browser
import Browser.Navigation as Nav
import Debug exposing (log)
import Html exposing (Html, text)
import Page.CourseListPage as CourseListPage
import Page.CoursePage as CoursePage
import Page.DefaultLayout as DefaultLayout
import Page.Login as Login
import Page.NotFound as NotFound
import Url exposing (Url)
import Url.Parser exposing ((</>), map, oneOf, parse, s, string, top)
import Util exposing (Either(..), either_map)


main : Program State Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = UrlRequested
        }


type alias State =
    { token : String }


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , init_url : String
    , token : Either String Token
    , page : Page
    , layout : Layout
    }


type Layout
    = NoneLayout
    | DefaultLayout DefaultLayout.Model


type Page
    = Blank
    | Login Login.Model
    | MainPage
    | CourseListPage CourseListPage.Model
    | CoursePage CoursePage.Model
    | NotFound


type ParsedUrl
    = UrlNotFound
    | UrlLogin
    | UrlLogout
    | UrlMainPage
    | UrlCourseList
    | UrlCourse String
    | UrlMarksOwn
    | UrlMarksOfPerson String
    | UrlMarksOfCourse String
    | UrlProfileOwn
    | UrlProfileOfUser String
    | UrlMessages
    | UrlNews


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url
    | DefaultLayoutMsg DefaultLayout.Msg
    | LoginMsg Login.Msg
    | CourseListPageMsg CourseListPage.Msg
    | CoursePageMsg CoursePage.Msg


parse_url : Url -> ParsedUrl
parse_url url =
    Maybe.withDefault UrlNotFound
        (parse
            (oneOf
                [ map UrlMainPage top
                , map UrlLogin (s "login")
                , map UrlLogout (s "logout")
                , map UrlCourseList (s "courses")
                , map UrlCourse (s "course" </> string)
                , map UrlMarksOwn (s "marks")
                , map UrlMarksOfPerson (s "marks" </> s "user" </> string)
                , map UrlMarksOfCourse (s "marks" </> s "course" </> string)
                , map UrlProfileOwn (s "profile")
                , map UrlProfileOfUser (s "profile" </> string)
                , map UrlMessages (s "messages")
                , map UrlNews (s "news")
                ]
            )
            url
        )


init : State -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init { token } url key =
    ( { key = key, url = url, init_url = Url.toString url, token = Left token, page = Blank, layout = NoneLayout }
    , Cmd.batch [ Nav.pushUrl key "/login" ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page, model.layout ) of
        ( DefaultLayoutMsg msg_, _, DefaultLayout l ) ->
            let
                ( model_, cmd_ ) =
                    DefaultLayout.update msg_ l
            in
            ( { model | layout = DefaultLayout model_ }, Cmd.map DefaultLayoutMsg cmd_ )

        ( UrlRequested urlRequest, _, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ( UrlChanged url, _, _ ) ->
            let
                ( new_model, cmd ) =
                    case ( parse_url url, model.token ) of
                        ( UrlNotFound, _ ) ->
                            ( { model | page = NotFound, layout = NoneLayout }, Cmd.none )

                        ( UrlLogout, _ ) ->
                            ( { model | page = Blank, token = Left "", layout = NoneLayout }
                            , Cmd.batch
                                [ Cmd.map LoginMsg <| Login.doSaveToken ""
                                , Nav.pushUrl model.key "/login"
                                ]
                            )

                        ( UrlLogin, token ) ->
                            let
                                ( m, c ) =
                                    Login.init <| either_map identity .key token
                            in
                            ( { model | page = Login m, layout = NoneLayout }, Cmd.map LoginMsg c )

                        ( UrlMainPage, Right token ) ->
                            let
                                ( layout_, cmd_ ) =
                                    DefaultLayout.init token.user
                            in
                            ( { model | page = MainPage, layout = DefaultLayout layout_ }, Cmd.map DefaultLayoutMsg cmd_ )

                        ( UrlCourse id, Right token ) ->
                            let
                                ( layout_, cmd_1 ) =
                                    DefaultLayout.init token.user

                                ( model_, cmd_2 ) =
                                    CoursePage.init token.key id
                            in
                            ( { model | page = CoursePage model_, layout = DefaultLayout layout_ }
                            , Cmd.batch
                                [ Cmd.map DefaultLayoutMsg cmd_1
                                , Cmd.map CoursePageMsg cmd_2
                                ]
                            )

                        ( UrlCourseList, Right token ) ->
                            let
                                ( layout_, cmd_1 ) =
                                    DefaultLayout.init token.user

                                ( model_, cmd_2 ) =
                                    CourseListPage.init token.key
                            in
                            ( { model
                                | page = CourseListPage model_
                                , layout = DefaultLayout layout_
                              }
                            , Cmd.batch
                                [ Cmd.map DefaultLayoutMsg cmd_1
                                , Cmd.map CourseListPageMsg cmd_2
                                ]
                            )

                        ( UrlMarksOwn, Right token ) ->
                            ( { model | page = Blank }, Cmd.none )

                        ( UrlMarksOfPerson string, Right token ) ->
                            ( { model | page = Blank }, Cmd.none )

                        ( UrlMarksOfCourse string, Right token ) ->
                            ( { model | page = Blank }, Cmd.none )

                        ( UrlProfileOwn, Right token ) ->
                            ( { model | page = Blank }, Cmd.none )

                        ( UrlProfileOfUser string, Right token ) ->
                            ( { model | page = Blank }, Cmd.none )

                        ( UrlMessages, Right token ) ->
                            ( { model | page = Blank }, Cmd.none )

                        ( UrlNews, Right token ) ->
                            ( { model | page = Blank }, Cmd.none )

                        ( _, _ ) ->
                            ( { model | page = Blank }, Cmd.none )
            in
            ( { new_model | url = log "url changed" url }
            , cmd
            )

        ( LoginMsg ((Login.LoginCompleted token) as msg_), Login model_, _ ) ->
            let
                ( m, c ) =
                    Login.update msg_ model_
            in
            ( { model | token = Right token, page = Login m }, Cmd.batch [ Cmd.map LoginMsg c, Nav.pushUrl model.key model.init_url ] )

        ( LoginMsg msg_, Login model_, _ ) ->
            let
                ( m, c ) =
                    Login.update msg_ model_
            in
            ( { model | page = Login m }, Cmd.map LoginMsg c )

        ( CourseListPageMsg msg_, CourseListPage model_, DefaultLayout layout_ ) ->
            let
                ( model__, cmd_ ) =
                    CourseListPage.update msg_ model_
            in
            ( { model | page = CourseListPage model__ }, Cmd.map CourseListPageMsg cmd_ )

        ( CoursePageMsg msg_, CoursePage model_, DefaultLayout layout_ ) ->
            let
                ( model__, cmd_ ) =
                    CoursePage.update msg_ model_
            in
            ( { model | page = CoursePage model__ }, Cmd.map CoursePageMsg cmd_ )

        ( _, _, _ ) ->
            -- FIXME: remove this general case and add more specific ones
            ( model, Cmd.none )



--
-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


viewPage : Model -> Html Msg
viewPage model =
    case model.page of
        Login m ->
            Html.map LoginMsg <| Login.view m

        MainPage ->
            text "MainPage"

        CourseListPage model_ ->
            Html.map CourseListPageMsg <| CourseListPage.view model_

        CoursePage model_ ->
            Html.map CoursePageMsg <| CoursePage.view model_

        NotFound ->
            NotFound.view

        Blank ->
            text ""


viewLayout : Model -> Html Msg -> Html Msg
viewLayout model body =
    case model.layout of
        NoneLayout ->
            body

        DefaultLayout model_ ->
            DefaultLayout.view DefaultLayoutMsg model_ body


view : Model -> Browser.Document Msg
view model =
    { title = "ЛНМО | Образовательный портал"
    , body = [ viewLayout model <| viewPage model ]
    }

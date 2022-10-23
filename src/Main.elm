module Main exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Api.Data exposing (Token)
import Browser
import Browser.Navigation as Nav
import Debug exposing (log)
import Html exposing (Html, text)
import Page.CourseListPage as CourseListPage
import Page.CoursePage as CoursePage
import Page.DefaultLayout as DefaultLayout
import Page.FatalError as FatalError
import Page.Login as Login
import Page.MarksCourse as MarksCourse
import Page.MarksStudent as MarksStudent
import Page.NotFound as NotFound
import Url exposing (Url)
import Url.Parser exposing ((</>), map, oneOf, parse, s, string, top)
import Util exposing (Either(..), either_map, get_id_str)


main : Program State Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = MsgUrlChanged
        , onUrlRequest = MsgUrlRequested
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
    = LayoutNone
    | LayoutDefault DefaultLayout.Model


type Page
    = PageBlank
    | PageLogin Login.Model
    | PageMain
    | PageCourseList CourseListPage.Model
    | PageCourse CoursePage.Model
    | PageMarksOfStudent MarksStudent.Model
    | PageMarksOfCourse MarksCourse.Model
    | PageNotFound
    | PageFatalError String


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
    = MsgUrlRequested Browser.UrlRequest
    | MsgUrlChanged Url.Url
    | MsgDefaultLayout DefaultLayout.Msg
    | MsgLogin Login.Msg
    | MsgCourseListPage CourseListPage.Msg
    | MsgCoursePage CoursePage.Msg
    | MsgPageMarksOfStudent MarksStudent.Msg
    | MsgPageMarksOfCourse MarksCourse.Msg
    | MsgUnauthorized


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
    ( { key = key
      , url = url
      , init_url = Url.toString url
      , token = Left token
      , page = PageBlank
      , layout = LayoutNone
      }
    , Cmd.batch [ Nav.pushUrl key "/login" ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page, model.layout ) of
        ( MsgDefaultLayout msg_, _, LayoutDefault l ) ->
            let
                ( model_, cmd_ ) =
                    DefaultLayout.update msg_ l
            in
            ( { model | layout = LayoutDefault model_ }, Cmd.map MsgDefaultLayout cmd_ )

        ( MsgUrlRequested urlRequest, _, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ( MsgUrlChanged url, _, _ ) ->
            let
                ( new_model, cmd ) =
                    case ( parse_url url, model.token ) of
                        ( UrlNotFound, _ ) ->
                            ( { model | page = PageNotFound, layout = LayoutNone }, Cmd.none )

                        ( UrlLogout, _ ) ->
                            ( { model | page = PageBlank, token = Left "", layout = LayoutNone }
                            , Cmd.batch
                                [ Cmd.map MsgLogin <| Login.doSaveToken ""
                                , Nav.pushUrl model.key "/login"
                                ]
                            )

                        ( UrlLogin, token ) ->
                            let
                                ( m, c ) =
                                    Login.init <| either_map identity .key token
                            in
                            ( { model | page = PageLogin m, layout = LayoutNone }, Cmd.map MsgLogin c )

                        ( UrlMainPage, Right token ) ->
                            let
                                ( layout_, cmd_ ) =
                                    DefaultLayout.init token.user
                            in
                            ( { model | page = PageMain, layout = LayoutDefault layout_ }, Cmd.map MsgDefaultLayout cmd_ )

                        ( UrlCourse id, Right token ) ->
                            let
                                ( layout_, cmd_1 ) =
                                    DefaultLayout.init token.user

                                ( model_, cmd_2 ) =
                                    CoursePage.init token.key id
                            in
                            ( { model | page = PageCourse model_, layout = LayoutDefault layout_ }
                            , Cmd.batch
                                [ Cmd.map MsgDefaultLayout cmd_1
                                , Cmd.map MsgCoursePage cmd_2
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
                                | page = PageCourseList model_
                                , layout = LayoutDefault layout_
                              }
                            , Cmd.batch
                                [ Cmd.map MsgDefaultLayout cmd_1
                                , Cmd.map MsgCourseListPage cmd_2
                                ]
                            )

                        ( UrlMarksOwn, Right token ) ->
                            let
                                ( layout_, cmd_1 ) =
                                    DefaultLayout.init token.user

                                ( model_, cmd_2 ) =
                                    MarksStudent.init token.key (get_id_str token.user)
                            in
                            ( { model
                                | page = PageMarksOfStudent model_
                                , layout = LayoutDefault layout_
                              }
                            , Cmd.batch
                                [ Cmd.map MsgDefaultLayout cmd_1
                                , Cmd.map MsgPageMarksOfStudent cmd_2
                                ]
                            )

                        ( UrlMarksOfPerson id, Right token ) ->
                            let
                                ( layout_, cmd_1 ) =
                                    DefaultLayout.init token.user

                                ( model_, cmd_2 ) =
                                    MarksStudent.init token.key id
                            in
                            ( { model
                                | page = PageMarksOfStudent model_
                                , layout = LayoutDefault layout_
                              }
                            , Cmd.batch
                                [ Cmd.map MsgDefaultLayout cmd_1
                                , Cmd.map MsgPageMarksOfStudent cmd_2
                                ]
                            )

                        ( UrlMarksOfCourse string, Right token ) ->
                            ( { model | page = PageBlank }, Cmd.none )

                        ( UrlProfileOwn, Right token ) ->
                            ( { model | page = PageBlank }, Cmd.none )

                        ( UrlProfileOfUser string, Right token ) ->
                            ( { model | page = PageBlank }, Cmd.none )

                        ( UrlMessages, Right token ) ->
                            ( { model | page = PageBlank }, Cmd.none )

                        ( UrlNews, Right token ) ->
                            ( { model | page = PageBlank }, Cmd.none )

                        ( _, _ ) ->
                            ( { model | page = PageBlank }, Cmd.none )
            in
            ( { new_model | url = log "url changed" url }
            , cmd
            )

        ( MsgLogin ((Login.LoginCompleted token) as msg_), PageLogin model_, _ ) ->
            let
                ( m, c ) =
                    Login.update msg_ model_
            in
            ( { model | token = Right token, page = PageLogin m }
            , Cmd.batch
                [ Cmd.map MsgLogin c
                , Nav.pushUrl model.key (if String.endsWith "/login" (Debug.log "model.init_url" (model.init_url)) then "/" else model.init_url)
                ]
            )

        ( MsgLogin msg_, PageLogin model_, _ ) ->
            let
                ( m, c ) =
                    Login.update msg_ model_
            in
            ( { model | page = PageLogin m }, Cmd.map MsgLogin c )

        ( MsgCourseListPage msg_, PageCourseList model_, LayoutDefault layout_ ) ->
            let
                ( model__, cmd_ ) =
                    CourseListPage.update msg_ model_
            in
            ( { model | page = PageCourseList model__ }, Cmd.map MsgCourseListPage cmd_ )

        ( MsgCoursePage msg_, PageCourse model_, LayoutDefault layout_ ) ->
            let
                ( model__, cmd_ ) =
                    CoursePage.update msg_ model_
            in
            ( { model | page = PageCourse model__ }, Cmd.map MsgCoursePage cmd_ )

        ( MsgPageMarksOfStudent msg_, PageMarksOfStudent model_, LayoutDefault layout_ ) ->
            let
                ( model__, cmd_ ) =
                    MarksStudent.update msg_ model_
            in
            ( { model | page = PageMarksOfStudent model__ }, Cmd.map MsgPageMarksOfStudent cmd_ )

        ( MsgPageMarksOfCourse msg_, PageMarksOfCourse model_, LayoutDefault layout_ ) ->
            let
                ( model__, cmd_ ) =
                    MarksCourse.update msg_ model_
            in
            ( { model | page = PageMarksOfCourse model__ }, Cmd.map MsgPageMarksOfCourse cmd_ )

        ( MsgUnauthorized, _, _ ) ->
            ( { model | page = PageBlank, token = Left "", layout = LayoutNone }
            , Cmd.batch
                [ Cmd.map MsgLogin <| Login.doSaveToken ""
                , Nav.pushUrl model.key "/login"
                ]
            )

        ( x, y, z ) ->
            ( { model | page = PageFatalError <| Debug.toString ( x, y, z ), layout = LayoutNone }, Cmd.none )



--
-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


viewPage : Model -> Html Msg
viewPage model =
    case model.page of
        PageLogin m ->
            Html.map MsgLogin <| Login.view m

        PageMain ->
            text "MainPage"

        PageCourseList model_ ->
            Html.map MsgCourseListPage <| CourseListPage.view model_

        PageCourse model_ ->
            Html.map MsgCoursePage <| CoursePage.view model_

        PageNotFound ->
            NotFound.view

        PageBlank ->
            text ""

        PageMarksOfStudent model_ ->
            Html.map MsgPageMarksOfStudent <| MarksStudent.view model_

        PageMarksOfCourse model_ ->
            Html.map MsgPageMarksOfCourse <| MarksCourse.view model_

        PageFatalError string ->
            FatalError.view string


viewLayout : Model -> Html Msg -> Html Msg
viewLayout model body =
    case model.layout of
        LayoutNone ->
            body

        LayoutDefault model_ ->
            DefaultLayout.view MsgDefaultLayout model_ body


view : Model -> Browser.Document Msg
view model =
    { title = "ЛНМО | Образовательный портал"
    , body = [ viewLayout model <| viewPage model ]
    }

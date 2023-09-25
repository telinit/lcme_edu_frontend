module Main exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Api.Data exposing (Token)
import Browser
import Browser.Navigation as Nav
import Html exposing (Html, text)
import Page.Admin.AdminPage as AdminPage
import Page.Course.CoursePage as CoursePage
import Page.CourseListPage as CourseListPage
import Page.DefaultLayout as DefaultLayout
import Page.FatalError as FatalError
import Page.FrontPage as FrontPage
import Page.Login as Login
import Page.MarksCourse as MarksCourse
import Page.MarksStudent as MarksStudent
import Page.NotFound as NotFound
import Page.UserProfile as PageUserProfile
import Ports exposing (scrollIdIntoView)
import Task
import Url exposing (Url)
import Url.Parser exposing ((</>), (<?>), map, oneOf, parse, query, s, string, top)
import Url.Parser.Query as Query
import Util exposing (Either(..), either_map)
import Uuid exposing (Uuid)


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
    { token : String
    , hostname : String
    }


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
    | PageFront FrontPage.Model
    | PageCourseList CourseListPage.Model
    | PageCourse CoursePage.Model
    | PageMarksOfStudent MarksStudent.Model
    | PageMarksOfCourse MarksCourse.Model
    | PageUserProfile PageUserProfile.Model
    | PageNotFound
    | PageFatalError Page String
    | PageAdmin AdminPage.Model


type ParsedUrl
    = UrlNotFound
    | UrlLogin
    | UrlLogout
    | UrlPageFront
    | UrlCourseList Bool
    | UrlCourse String
    | UrlMarks
    | UrlMarksOfPerson Uuid
    | UrlMarksOfCourse Uuid
    | UrlProfileOwn
    | UrlProfileOfUser Uuid
    | UrlMessages
    | UrlNews
    | UrlPasswordReset (Maybe String)
    | UrlAdmin


type Msg
    = MsgUrlRequested Browser.UrlRequest
    | MsgUrlChanged Url.Url
    | MsgDefaultLayout DefaultLayout.Msg
    | MsgPageLogin Login.Msg
    | MsgPageFront FrontPage.Msg
    | MsgPageCourseList CourseListPage.Msg
    | MsgPageCourse CoursePage.Msg
    | MsgPageMarksOfStudent MarksStudent.Msg
    | MsgPageMarksOfCourse MarksCourse.Msg
    | MsgPageUserProfile PageUserProfile.Msg
    | MsgPageAdmin AdminPage.Msg
    | MsgUnauthorized


parse_url : Url -> ParsedUrl
parse_url url =
    Maybe.withDefault UrlNotFound
        (parse
            (oneOf
                [ map UrlPageFront top
                , map UrlPasswordReset (s "login" </> s "password_reset" <?> Query.string "token")
                , map UrlLogin (s "login")
                , map UrlLogout (s "logout")
                , map (UrlCourseList True) (s "courses" </> s "archive")
                , map (UrlCourseList False) (s "courses")
                , map UrlCourse (s "course" </> string)
                , map UrlMarks (s "marks")
                , map (Maybe.withDefault UrlNotFound << Maybe.map UrlMarksOfPerson << Uuid.fromString) (s "marks" </> s "student" </> string)
                , map (Maybe.withDefault UrlNotFound << Maybe.map UrlMarksOfCourse << Uuid.fromString) (s "marks" </> s "course" </> string)
                , map UrlProfileOwn (s "profile")
                , map (Maybe.withDefault UrlNotFound << Maybe.map UrlProfileOfUser << Uuid.fromString) (s "profile" </> string)
                , map UrlMessages (s "messages")
                , map UrlNews (s "news")
                , map UrlAdmin (s "admin")
                ]
            )
            url
        )


init : State -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init { token, hostname } url key =
    let
        urlStr =
            Url.toString url

        urlParsed =
            parse_url url

        initUrl =
            case urlParsed of
                UrlLogin ->
                    "/"

                UrlPasswordReset _ ->
                    "/"

                _ ->
                    urlStr
    in
    ( { key = key
      , url = url
      , init_url = initUrl
      , token = Left token
      , page = PageBlank
      , layout = LayoutNone
      }
    , case urlParsed of
        UrlPasswordReset _ ->
            Task.perform identity <| Task.succeed (MsgUrlChanged url)

        _ ->
            Nav.pushUrl key "/login"
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
                    ( model
                    , Cmd.batch
                        [ Nav.pushUrl model.key (Url.toString url)
                        ]
                    )

                Browser.External href ->
                    ( model, Nav.load href )

        ( MsgUrlChanged url, _, _ ) ->
            let
                ( new_model, cmd ) =
                    case ( parse_url url, model.token ) of
                        ( UrlNotFound, _ ) ->
                            ( { model | page = PageNotFound, layout = LayoutNone }, Cmd.none )

                        ( UrlLogout, _ ) ->
                            ( { model | page = PageBlank, token = Left "", layout = LayoutNone, init_url = "/" }
                            , Cmd.batch
                                [ Cmd.map MsgPageLogin <| Login.doSaveToken ""
                                , Nav.pushUrl model.key "/login"
                                ]
                            )

                        ( UrlLogin, token ) ->
                            let
                                ( m, c ) =
                                    Login.init model.key <| either_map identity .key token
                            in
                            ( { model | page = PageLogin m, layout = LayoutNone }, Cmd.map MsgPageLogin c )

                        ( UrlPageFront, Right token ) ->
                            let
                                ( layout_, cmd_1 ) =
                                    DefaultLayout.init token.user

                                ( model_, cmd_2 ) =
                                    FrontPage.init token.key token.user
                            in
                            ( { model | page = PageFront model_, layout = LayoutDefault layout_ }
                            , Cmd.batch
                                [ Cmd.map MsgDefaultLayout cmd_1
                                , Cmd.map MsgPageFront cmd_2
                                ]
                            )

                        ( UrlCourse id, Right token ) ->
                            let
                                ( layout_, cmd_1 ) =
                                    DefaultLayout.init token.user

                                ( model_, cmd_2 ) =
                                    CoursePage.init token.key id token.user
                            in
                            ( { model | page = PageCourse model_, layout = LayoutDefault layout_ }
                            , Cmd.batch
                                [ Cmd.map MsgDefaultLayout cmd_1
                                , Cmd.map MsgPageCourse cmd_2
                                ]
                            )

                        ( UrlCourseList archived, Right token ) ->
                            let
                                ( layout_, cmd_1 ) =
                                    DefaultLayout.init token.user

                                ( model_, cmd_2 ) =
                                    CourseListPage.init token.key archived
                            in
                            ( { model
                                | page = PageCourseList model_
                                , layout = LayoutDefault layout_
                              }
                            , Cmd.batch
                                [ Cmd.map MsgDefaultLayout cmd_1
                                , Cmd.map MsgPageCourseList cmd_2
                                ]
                            )

                        ( UrlMarks, Right token ) ->
                            let
                                ( layout_, cmd_1 ) =
                                    DefaultLayout.init token.user

                                ( model_, cmd_2 ) =
                                    MarksStudent.init token.key token.user Nothing
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
                                    MarksStudent.init token.key token.user (Just id)
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

                        ( UrlMarksOfCourse course_id, Right token ) ->
                            let
                                ( layout_, cmd_1 ) =
                                    DefaultLayout.init token.user

                                ( model_, cmd_2 ) =
                                    MarksCourse.init token.key course_id token.user.id
                            in
                            ( { model
                                | page = PageMarksOfCourse model_
                                , layout = LayoutDefault layout_
                              }
                            , Cmd.batch
                                [ Cmd.map MsgDefaultLayout cmd_1
                                , Cmd.map MsgPageMarksOfCourse cmd_2
                                ]
                            )

                        ( UrlProfileOwn, Right token ) ->
                            let
                                ( layout_, cmd_1 ) =
                                    DefaultLayout.init token.user

                                ( model_, cmd_2 ) =
                                    PageUserProfile.init token.key token.user token.user.id
                            in
                            ( { model
                                | page = PageUserProfile model_
                                , layout = LayoutDefault layout_
                              }
                            , Cmd.batch
                                [ Cmd.map MsgDefaultLayout cmd_1
                                , Cmd.map MsgPageUserProfile cmd_2
                                ]
                            )

                        ( UrlProfileOfUser uid, Right token ) ->
                            let
                                ( layout_, cmd_1 ) =
                                    DefaultLayout.init token.user

                                ( model_, cmd_2 ) =
                                    PageUserProfile.init token.key token.user (Just uid)
                            in
                            ( { model
                                | page = PageUserProfile model_
                                , layout = LayoutDefault layout_
                              }
                            , Cmd.batch
                                [ Cmd.map MsgDefaultLayout cmd_1
                                , Cmd.map MsgPageUserProfile cmd_2
                                ]
                            )

                        ( UrlMessages, Right token ) ->
                            ( { model | page = PageBlank }, Cmd.none )

                        ( UrlNews, Right token ) ->
                            ( { model | page = PageBlank }, Cmd.none )

                        ( UrlPasswordReset (Just token), _ ) ->
                            let
                                ( m, c ) =
                                    Login.init_password_reset_fin model.key token
                            in
                            ( { model | page = PageLogin m, layout = LayoutNone }, Cmd.map MsgPageLogin c )

                        ( UrlAdmin, Right token ) ->
                            let
                                ( layout_, cmd_1 ) =
                                    DefaultLayout.init token.user

                                ( model_, cmd_2 ) =
                                    AdminPage.init token.key
                            in
                            ( { model
                                | page = PageAdmin model_
                                , layout = LayoutDefault layout_
                              }
                            , Cmd.batch
                                [ Cmd.map MsgDefaultLayout cmd_1
                                , Cmd.map MsgPageAdmin cmd_2
                                ]
                            )

                        ( _, _ ) ->
                            ( { model | page = PageNotFound }, Cmd.none )
            in
            ( { new_model | url = url }
            , Cmd.batch [ cmd, scrollIdIntoView "main_container" ]
            )

        ( MsgPageLogin ((Login.LoginCompleted token) as msg_), PageLogin model_, _ ) ->
            let
                ( m, c ) =
                    Login.update msg_ model_
            in
            ( { model | token = Right token, page = PageLogin m }
            , Cmd.batch
                [ Cmd.map MsgPageLogin c
                , Nav.pushUrl model.key
                    (if String.endsWith "/login" model.init_url then
                        "/"

                     else
                        model.init_url
                    )
                ]
            )

        ( MsgPageLogin msg_, PageLogin model_, _ ) ->
            let
                ( m, c ) =
                    Login.update msg_ model_
            in
            ( { model | page = PageLogin m }, Cmd.map MsgPageLogin c )

        ( MsgPageCourseList msg_, PageCourseList model_, LayoutDefault layout_ ) ->
            let
                ( model__, cmd_ ) =
                    CourseListPage.update msg_ model_
            in
            ( { model | page = PageCourseList model__ }, Cmd.map MsgPageCourseList cmd_ )

        ( MsgPageCourse msg_, PageCourse model_, LayoutDefault layout_ ) ->
            let
                ( model__, cmd_ ) =
                    CoursePage.update msg_ model_
            in
            ( { model | page = PageCourse model__ }, Cmd.map MsgPageCourse cmd_ )

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

        ( MsgPageUserProfile msg_, PageUserProfile model_, LayoutDefault layout_ ) ->
            let
                ( model__, cmd_ ) =
                    PageUserProfile.update msg_ model_
            in
            ( { model | page = PageUserProfile model__ }, Cmd.map MsgPageUserProfile cmd_ )

        ( MsgUnauthorized, _, _ ) ->
            ( { model | page = PageBlank, token = Left "", layout = LayoutNone }
            , Cmd.batch
                [ Cmd.map MsgPageLogin <| Login.doSaveToken ""
                , Nav.pushUrl model.key "/login"
                ]
            )

        ( MsgPageFront msg_, PageFront model_, LayoutDefault layout_ ) ->
            let
                ( model__, cmd_ ) =
                    FrontPage.update msg_ model_
            in
            ( { model | page = PageFront model__ }, Cmd.map MsgPageFront cmd_ )

        ( MsgPageAdmin msg_, PageAdmin model_, LayoutDefault layout_ ) ->
            let
                ( model__, cmd_ ) =
                    AdminPage.update msg_ model_
            in
            ( { model | page = PageAdmin model__ }, Cmd.map MsgPageAdmin cmd_ )

        _ ->
            ( model, Cmd.none )



--
-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.page of
        PageFront model_ ->
            Sub.map MsgPageFront <| FrontPage.subscriptions model_

        PageCourse model_ ->
            Sub.map MsgPageCourse <| CoursePage.subscriptions model_

        PageAdmin model_ ->
            Sub.map MsgPageAdmin <| AdminPage.subscribtions model_

        _ ->
            Sub.none



-- VIEW


viewPage : Model -> Html Msg
viewPage model =
    case model.page of
        PageLogin model_ ->
            Html.map MsgPageLogin <| Login.view model_

        PageFront model_ ->
            Html.map MsgPageFront <| FrontPage.view model_

        PageCourseList model_ ->
            Html.map MsgPageCourseList <| CourseListPage.view model_

        PageCourse model_ ->
            Html.map MsgPageCourse <| CoursePage.view model_

        PageNotFound ->
            NotFound.view

        PageBlank ->
            text ""

        PageMarksOfStudent model_ ->
            Html.map MsgPageMarksOfStudent <| MarksStudent.view model_

        PageMarksOfCourse model_ ->
            Html.map MsgPageMarksOfCourse <| MarksCourse.view model_

        PageFatalError _ string ->
            FatalError.view string

        PageUserProfile model_ ->
            Html.map MsgPageUserProfile <| PageUserProfile.view model_

        PageAdmin model_ ->
            Html.map MsgPageAdmin <| AdminPage.view model_


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

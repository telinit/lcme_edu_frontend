module Main exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, div, node, text)
import Html.Attributes exposing (class, href, rel, src)
import Page.Login as Login
import Url



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- MODEL


type Page
    = Login Login.Model
    | MainPage
    | CoursePage


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , page : Page
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        ( m, c ) =
            Login.init ()
    in
    ( Model key url (Login m), Cmd.map LoginMsg c )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | LoggedIn
    | LoginRequired
    | LoginMsg Login.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ( UrlChanged url, _ ) ->
            ( { model | url = url }
            , Cmd.none
            )

        ( LoginMsg msg_, Login model_ ) ->
            let
                ( m, c ) =
                    Login.update msg_ model_
            in
            ( { model | page = Login m }, Cmd.map LoginMsg c )

        ( _, _ ) ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


viewPage : Model -> List (Html Msg)
viewPage model =
    case model.page of
        Login m ->
            [ Html.map LoginMsg <| Login.view m ]

        MainPage ->
            []

        CoursePage ->
            []


view : Model -> Browser.Document Msg
view model =
    { title = "ЛНМО | Образовательный портал"
    , body =
        [ node
            "link"
            [ rel "stylesheet", href "semantic.css" ]
            []
        , node
            "script"
            [ src "semantic.js" ]
            []
        ]
            ++ viewPage model
    }

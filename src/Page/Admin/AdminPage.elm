module Page.Admin.AdminPage exposing (..)

import Component.MessageBox as MessageBox
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Page.Admin.ImportStudentsCSV as ImportStudentsCSV


type Subpage
    = SubpageIndex
    | SubpageImportStudents (Maybe ImportStudentsCSV.Model)


type MenuItemType
    = MenuItemTypeSubpage Subpage
    | MenuItemTypeInternalLink String
    | MenuItemTypeExternalLink String


type Msg
    = MsgChangeSubpage Subpage
    | MsgSubpageImportStudents ImportStudentsCSV.Msg


type alias Model =
    { token : String, currentSubpage : Subpage }


init : String -> ( Model, Cmd Msg )
init token =
    ( { token = token, currentSubpage = SubpageIndex }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        ignore =
            ( model, Cmd.none )
    in
    case msg of
        MsgChangeSubpage subpage ->
            case subpage of
                SubpageIndex ->
                    ( { model | currentSubpage = subpage }, Cmd.none )

                SubpageImportStudents Nothing ->
                    let
                        ( m, c ) =
                            ImportStudentsCSV.init model.token
                    in
                    ( { model | currentSubpage = SubpageImportStudents (Just m) }, Cmd.map MsgSubpageImportStudents c )

                SubpageImportStudents (Just _) ->
                    ignore

        MsgSubpageImportStudents msg_ ->
            case model.currentSubpage of
                SubpageImportStudents (Just model_) ->
                    let
                        ( m, c ) =
                            ImportStudentsCSV.update msg_ model_
                    in
                    ( { model | currentSubpage = SubpageImportStudents (Just m) }, Cmd.map MsgSubpageImportStudents c )

                _ ->
                    ( model, Cmd.none )


viewMenu : Model -> Html Msg
viewMenu model =
    let
        items : List { type_ : MenuItemType, label : String, icon : String }
        items =
            [ { type_ = MenuItemTypeSubpage (SubpageImportStudents Nothing), label = "Импорт учащихся", icon = "cog" }
            , { type_ = MenuItemTypeExternalLink "/djadmin", label = "Админка Django", icon = "cog" }
            ]

        viewMenuItem : { type_ : MenuItemType, label : String, icon : String } -> Html Msg
        viewMenuItem item =
            case item.type_ of
                MenuItemTypeSubpage subpage ->
                    a
                        [ class "ui"
                        , classList
                            [ ( "secondary segment", subpage /= model.currentSubpage )
                            , ( "tertiary segment", subpage == model.currentSubpage )
                            ]
                        , href "#"
                        , onClick (MsgChangeSubpage subpage)
                        ]
                        [ i [ class <| item.icon ++ " icon" ] []
                        , text item.label
                        ]

                MenuItemTypeInternalLink addr ->
                    a [ class "ui segment secondary", href addr ]
                        [ i [ class <| item.icon ++ " icon" ] []
                        , text item.label
                        ]

                MenuItemTypeExternalLink addr ->
                    a [ class "ui segment secondary", href addr, target "_blank" ]
                        [ i [ class <| item.icon ++ " icon" ] []
                        , text item.label
                        ]
    in
    div [ class "row ui raised horizontal segments" ] <|
        List.map viewMenuItem items


viewSubpage : Model -> Html Msg
viewSubpage model =
    let
        loading = MessageBox.view MessageBox.None True Nothing (text "") (text "Инициализация...")
    in
    case model.currentSubpage of
        SubpageIndex ->
            text "Выберите интересующий вас раздел в меню выше."

        SubpageImportStudents (Just model_) ->
            Html.map MsgSubpageImportStudents <| ImportStudentsCSV.view model_

        SubpageImportStudents Nothing ->
            loading


view : Model -> Html Msg
view model =
    div []
        [ h1 [ class "row center-xs" ] [ text "Администрирование" ]
        , div [ class "row mt-10" ]
            [ viewMenu model
            ]
        , div [ class "row mt-10" ]
            [ viewSubpage model
            ]
        ]
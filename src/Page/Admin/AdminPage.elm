module Page.Admin.AdminPage exposing (..)

import Component.MessageBox as MessageBox
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Page.Admin.ExportMarks as ExportMarks
import Page.Admin.ImportStudentsCSV as ImportStudentsCSV
import Page.Admin.ImportTeachersCSV as ImportTeachersCSV
import Page.Admin.Test as Test


type Subpage
    = SubpageIndex
    | SubpageImportStudents (Maybe ImportStudentsCSV.Model)
    | SubpageImportTeachers (Maybe ImportTeachersCSV.Model)
    | SubpageExportMarks (Maybe ExportMarks.Model)
    | SubpageTest (Maybe Test.Model)


type MenuItemType
    = MenuItemTypeSubpage Subpage
    | MenuItemTypeInternalLink String
    | MenuItemTypeExternalLink String


type Msg
    = MsgChangeSubpage Subpage
    | MsgSubpageImportStudents ImportStudentsCSV.Msg
    | MsgSubpageExportMarks ExportMarks.Msg
    | MsgSubpageTest Test.Msg
    | MsgSubpageImportTeachers ImportTeachersCSV.Msg


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

                SubpageImportStudents mbm ->
                    case mbm of
                        Nothing ->
                            let
                                ( m, c ) =
                                    ImportStudentsCSV.init model.token
                            in
                            ( { model | currentSubpage = SubpageImportStudents (Just m) }, Cmd.map MsgSubpageImportStudents c )

                        Just _ ->
                            ignore

                SubpageExportMarks mbm ->
                    case mbm of
                        Just _ ->
                            ignore

                        Nothing ->
                            let
                                ( m, c ) =
                                    ExportMarks.init ()
                            in
                            ( { model | currentSubpage = SubpageExportMarks (Just m) }, Cmd.map MsgSubpageExportMarks c )

                SubpageTest maybeModel ->
                    case maybeModel of
                        Just _ ->
                            ignore

                        Nothing ->
                            let
                                ( m, c ) =
                                    Test.init model.token
                            in
                            ( { model | currentSubpage = SubpageTest (Just m) }, Cmd.map MsgSubpageTest c )

                SubpageImportTeachers mbm ->
                    case mbm of
                        Nothing ->
                            let
                                ( m, c ) =
                                    ImportTeachersCSV.init model.token
                            in
                            ( { model | currentSubpage = SubpageImportTeachers (Just m) }, Cmd.map MsgSubpageImportTeachers c )

                        Just _ ->
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
                    ignore

        MsgSubpageExportMarks msg_ ->
            case model.currentSubpage of
                SubpageExportMarks (Just model_) ->
                    let
                        ( m, c ) =
                            ExportMarks.update msg_ model_
                    in
                    ( { model | currentSubpage = SubpageExportMarks (Just m) }, Cmd.map MsgSubpageExportMarks c )

                _ ->
                    ignore

        MsgSubpageTest msg_ ->
            case model.currentSubpage of
                SubpageTest (Just model_) ->
                    let
                        ( m, c ) =
                            Test.update msg_ model_
                    in
                    ( { model | currentSubpage = SubpageTest (Just m) }, Cmd.map MsgSubpageTest c )

                _ ->
                    ignore

        MsgSubpageImportTeachers msg_ ->
            case model.currentSubpage of
                SubpageImportTeachers (Just model_) ->
                    let
                        ( m, c ) =
                            ImportTeachersCSV.update msg_ model_
                    in
                    ( { model | currentSubpage = SubpageImportTeachers (Just m) }, Cmd.map MsgSubpageImportTeachers c )

                _ ->
                    ignore


viewMenu : Model -> Html Msg
viewMenu model =
    let
        items : List { type_ : MenuItemType, label : String, icon : String }
        items =
            [ { type_ = MenuItemTypeSubpage (SubpageImportStudents Nothing), label = "Импорт учащихся", icon = "cog" }
            , { type_ = MenuItemTypeSubpage (SubpageImportTeachers Nothing), label = "Импорт преподавателей", icon = "cog" }
            , { type_ = MenuItemTypeSubpage (SubpageExportMarks Nothing), label = "Экспорт оценок", icon = "cog" }
            , { type_ = MenuItemTypeSubpage (SubpageTest Nothing), label = "Test page", icon = "cog" }
            , { type_ = MenuItemTypeExternalLink "/djadmin", label = "Админка Django", icon = "cog" }
            , { type_ = MenuItemTypeExternalLink "/swagger", label = "Swagger API", icon = "cog" }
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
        loading =
            MessageBox.view MessageBox.None True Nothing (text "") (text "Инициализация...")
    in
    case model.currentSubpage of
        SubpageIndex ->
            text "Выберите интересующий вас раздел в меню выше."

        SubpageImportStudents mbm ->
            case mbm of
                Just model_ ->
                    Html.map MsgSubpageImportStudents <| ImportStudentsCSV.view model_

                Nothing ->
                    loading

        SubpageExportMarks mbm ->
            case mbm of
                Just model_ ->
                    Html.map MsgSubpageExportMarks <| ExportMarks.view model_

                Nothing ->
                    loading

        SubpageTest maybeModel ->
            case maybeModel of
                Just model_ ->
                    Html.map MsgSubpageTest <| Test.view model_

                Nothing ->
                    loading

        SubpageImportTeachers maybeModel ->
            case maybeModel of
                Just model_ ->
                    Html.map MsgSubpageImportTeachers <| ImportTeachersCSV.view model_

                Nothing ->
                    loading


subscribtions : Model -> Sub Msg
subscribtions model =
    case model.currentSubpage of
        SubpageIndex ->
            Sub.none

        SubpageImportStudents maybeModel ->
            Sub.none

        SubpageExportMarks maybeModel ->
            Sub.none

        SubpageTest maybeModel ->
            case maybeModel of
                Just model_ ->
                    Sub.map MsgSubpageTest (Test.subscriptions model_)

                Nothing ->
                    Sub.none

        SubpageImportTeachers maybeModel ->
            case maybeModel of
                Just model_ ->
                    Sub.map MsgSubpageImportTeachers (ImportTeachersCSV.subscriptions model_)

                Nothing ->
                    Sub.none


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

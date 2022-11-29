module Page.Admin.ImportStudentsCSV exposing (..)

import Api exposing (ext_task)
import Api.Data exposing (ImportStudentsCSVResult)
import Api.Request.User exposing (userImportStudentsCsv)
import Component.MessageBox as MessageBox
import Csv.Encode
import Csv.Parser
import File.Download
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Task
import Util exposing (httpErrorToString, zip)


type State
    = StateInput String
    | StateInProgress
    | StateFinished (Result Http.Error ImportStudentsCSVResult)


type Msg
    = MsgOnInputData String
    | MsgOnClickDownloadReport
    | MsgImportFinished (Result Http.Error ImportStudentsCSVResult)
    | MsgOnClickStartImport


type alias Model =
    { state : State
    , token : String
    }


doImport : String -> String -> Cmd Msg
doImport token data =
    Task.attempt MsgImportFinished <|
        ext_task identity token [] <|
            userImportStudentsCsv { data = data }


init : String -> ( Model, Cmd Msg )
init token =
    ( { state = StateInput ""
      , token = token
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        ignore =
            ( model, Cmd.none )
    in
    case msg of
        MsgOnInputData v ->
            case model.state of
                StateInput _ ->
                    ( { model | state = StateInput v }, Cmd.none )

                _ ->
                    ignore

        MsgOnClickDownloadReport ->
            case model.state of
                StateFinished result ->
                    case result of
                        Ok { data } ->
                            case data of
                                header :: data_ ->
                                    let
                                        encoder header_ =
                                            Csv.Encode.withFieldNames (zip header_)

                                        cmd =
                                            File.Download.string "import_result.csv" "text/csv" <|
                                                Csv.Encode.encode { encoder = encoder header, fieldSeparator = ',' } data_
                                    in
                                    ( model, cmd )

                                _ ->
                                    ( model, File.Download.string "import_result.csv" "text/csv" "" )

                        _ ->
                            ignore

                _ ->
                    ignore

        MsgImportFinished result ->
            ( { model | state = StateFinished result }, Cmd.none )

        MsgOnClickStartImport ->
            case model.state of
                StateInput data ->
                    ( { model | state = StateInProgress }, doImport model.token data )

                _ ->
                    ignore


view : Model -> Html Msg
view model =
    let
        state =
            case model.state of
                StateInput v ->
                    div []
                        [ textarea [ class "m-10", style "width" "100%", rows 20, value v, onInput MsgOnInputData ] []
                        , button [ class "ui button", onClick MsgOnClickStartImport ] [ text "Начать импорт" ]
                        ]

                StateInProgress ->
                    MessageBox.view MessageBox.None True Nothing (text "") (text "Выполняется импорт")

                StateFinished result ->
                    case result of
                        Ok _ ->
                            let
                                report =
                                    span
                                        [ style "cursor" "pointer"
                                        , style "text-decoration" "underline"
                                        , onClick MsgOnClickDownloadReport
                                        ]
                                        [ i [ class "file icon" ] [], text " файла" ]
                            in
                            div []
                                [ MessageBox.view
                                    MessageBox.Success
                                    False
                                    Nothing
                                    (text "Импорт выполнен успешно")
                                    (span [] [ text "Результат импорта можно скачать в виде CSV", report ])
                                ]

                        Err error ->
                            MessageBox.view
                                MessageBox.Error
                                False
                                Nothing
                                (text "")
                                (text <| "Ошибка иморта: " ++ httpErrorToString error)
    in
    div [ class "col-xs-12" ]
        [ h2 [] [ text "Импорт учащихся" ]
        , div [ class "col" ]
            [ p [] [ text "Введите данные для импорта в тестовое поле ниже. Формат данных - UTF-8 CSV, разделитель - запятая." ]
            , p [] [ text "Необходимые поля:" ]
            , ul []
                [ li [] [ strong [] [ text "Класс" ], text "" ]
                , li [] [ strong [] [ text "Направление" ], text "" ]
                , li [] [ strong [] [ text "Фамилия учащегося" ], text "" ]
                , li [] [ strong [] [ text "Имя учащегося" ], text "" ]
                , li [] [ strong [] [ text "Отчество учащегося" ], text "" ]
                , li [] [ strong [] [ text "Фамилия родителя 1" ], text "" ]
                , li [] [ strong [] [ text "Имя родителя 1" ], text "" ]
                , li [] [ strong [] [ text "Отчество родителя 1" ], text "" ]
                , li [] [ strong [] [ text "Фамилия родителя 2" ], text "" ]
                , li [] [ strong [] [ text "Имя родителя 2" ], text "" ]
                , li [] [ strong [] [ text "Отчество родителя 2" ], text "" ]
                ]
            , state
            ]
        , div [] []
        ]

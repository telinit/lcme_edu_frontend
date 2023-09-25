module Component.FileManager exposing (..)

import Api exposing (ext_task)
import Api.Data exposing (File, FileQuota)
import Api.Request.File exposing (fileDelete, fileList, fileMkdir, fileQuota, fileRead, fileUpdate, fileUpload)
import Api.Request.User exposing (userSelf)
import Browser.Dom as Dom
import Component.CompactInlineModal as CompactInlineModal exposing (initMessageBox)
import Component.Modal as Model
import Component.UI.Breadcrumb as Breadcrumb
import Component.UI.Common exposing (Action(..), ButtonKind(..), IconType(..), Size(..), iconFolderPlus, viewIcon)
import Component.UI.IconMenu as IconMenu
import Component.UI.InputBox as InputBox
import Component.UI.ProgressBar as ProgressBar exposing (Progress(..))
import File as ELMFile
import File.Download
import File.Select
import Html exposing (..)
import Html.Attributes exposing (attribute, class, classList, href, style)
import Html.Events exposing (onClick, onDoubleClick)
import Http
import Process
import Task
import Util exposing (get_id_str, httpErrorToString, listLast, maybeToList, onClickPrevent, onClickPreventStop, onClickStop, task_to_cmd, validateFileName)
import Uuid exposing (Uuid)


type alias APIToken =
    String


type alias SelectedFileID =
    Uuid


type alias FileOrdering =
    File -> File -> Order


type State
    = StateLoading
    | StateNormal
    | StateError String
    | StateRenamePrompt String
    | StateMakeDirPrompt String
    | StateRemovePrompt File
    | StateUploading ELMFile.File (List ELMFile.File) Int Int


type alias Model =
    { token : APIToken
    , root : Maybe File
    , path : List File
    , fileList : List File
    , selectedFile : Maybe File
    , cutFiles : List File
    , state : State
    , sorting : File -> File -> Order
    , quota : Maybe FileQuota
    }


type Msg
    = MsgListFilesDone (Result Http.Error (List File))
    | MsgFetchRootDone (Result Http.Error File)
    | MsgQuotaFetchDone (Result Http.Error (Maybe FileQuota))
    | MsgPathGoto Int (Maybe File)
    | MsgFileClicked File
    | MsgFileDoubleClicked File
    | MsgFileListClicked
    | MsgDoFileOperation FileOperation
    | MsgIgnore
    | MsgDoReturnToNormal
    | MsgOnInputRename String
    | MsgDoRename
    | MsgOnInputMkdir String
    | MsgDoMkdir
    | MsgDoRemoveFile File
    | MsgUploadFilesSelected ELMFile.File (List ELMFile.File)
    | MsgRenameDone (Result Http.Error File)
    | MsgMkdirDone (Result Http.Error File)
    | MsgRemoveDone (Result Http.Error Uuid)
    | MsgMoveDone (Result Http.Error File)
    | MsgUploadDone (Result Http.Error File)


type FileOperation
    = OPMakeDirectory
    | OPRename
    | OPDelete
    | OPDownload
    | OPUpload
    | OPCut
    | OPPaste


sortByFileName : FileOrdering
sortByFileName file1 file2 =
    compare file1.name file2.name


directoryFirst : FileOrdering -> FileOrdering
directoryFirst ord file1 file2 =
    case ( file1.mimeType, file2.mimeType ) of
        ( "inode/directory", "inode/directory" ) ->
            ord file1 file2

        ( "inode/directory", _ ) ->
            LT

        ( _, "inode/directory" ) ->
            GT

        _ ->
            ord file1 file2


defaultSorting : FileOrdering
defaultSorting =
    directoryFirst sortByFileName


doFetchRoot : APIToken -> Maybe Uuid -> Cmd Msg
doFetchRoot token mbRoot =
    case mbRoot of
        Nothing ->
            Cmd.none

        Just id ->
            Task.attempt MsgFetchRootDone <|
                ext_task
                    identity
                    token
                    []
                    (fileRead <| Uuid.toString id)


doListFiles : APIToken -> Maybe Uuid -> Cmd Msg
doListFiles token mbRoot =
    Task.attempt MsgListFilesDone <|
        ext_task
            identity
            token
            [ Maybe.withDefault ( "parent__isnull", "True" ) <|
                Maybe.map (\id -> ( "parent", Uuid.toString id )) mbRoot
            ]
            fileList


doGetQuota : APIToken -> Cmd Msg
doGetQuota token =
    let
        taskSelf =
            ext_task
                identity
                token
                []
                userSelf

        taskQuota =
            ext_task
                Just
                token
                []
                fileQuota

        task =
            taskSelf
                |> Task.andThen
                    (\self ->
                        if self.isStaff == Just True then
                            Task.succeed Nothing

                        else
                            taskQuota
                    )
    in
    Task.attempt MsgQuotaFetchDone task


doRenameFile : String -> File -> String -> Cmd Msg
doRenameFile token file newName =
    Task.attempt MsgRenameDone <|
        ext_task identity token [] <|
            fileUpdate
                (get_id_str file)
                { file | name = newName }


doMakeDir : String -> Maybe Uuid -> String -> Cmd Msg
doMakeDir token mbParentID name =
    Task.attempt MsgMkdirDone <|
        ext_task identity token [] <|
            fileMkdir
                { name = name
                , parent = mbParentID
                }


doRemoveFile : String -> Uuid -> Cmd Msg
doRemoveFile token id =
    Task.attempt MsgRemoveDone <|
        Task.map (always id) <|
            ext_task identity token [] <|
                fileDelete (Uuid.toString id)


doMoveFile : String -> File -> Maybe Uuid -> Cmd Msg
doMoveFile token file mbParentID =
    Task.attempt MsgMoveDone <|
        ext_task identity token [] <|
            fileUpdate (get_id_str file) { file | parent = mbParentID }


doUploadFile : String -> Maybe Uuid -> ELMFile.File -> Cmd Msg
doUploadFile token mbParent file =
    Task.attempt MsgUploadDone <|
        ext_task identity token [] <|
            fileUpload file mbParent


getCwd : Model -> Maybe File
getCwd model =
    if model.path == [] then
        model.root

    else
        listLast model.path


enterChildDir : File -> Model -> ( Model, Cmd Msg )
enterChildDir file model =
    if file.parent == (Maybe.andThen .id <| getCwd model) then
        ( { model
            | path = model.path ++ [ file ]
            , fileList = []
            , selectedFile = Nothing
            , state = StateLoading
          }
        , doListFiles model.token file.id
        )

    else
        ( model, Cmd.none )


init : APIToken -> Maybe Uuid -> ( Model, Cmd Msg )
init token mbRootID =
    ( { token = token
      , root = Nothing
      , state = StateLoading
      , path = []
      , fileList = []
      , cutFiles = []
      , selectedFile = Nothing
      , sorting = defaultSorting
      , quota = Nothing
      }
    , Cmd.batch [ doFetchRoot token mbRootID, doListFiles token mbRootID, doGetQuota token ]
    )


updateFileList : Model -> File -> Model
updateFileList model file =
    let
        updateFile_ f =
            if f.id == file.id then
                file

            else
                f
    in
    { model | fileList = List.sortWith model.sorting <| List.map updateFile_ model.fileList }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        ignore =
            ( model, Cmd.none )
    in
    case msg of
        MsgListFilesDone res ->
            case res of
                Ok files ->
                    ( { model | state = StateNormal, fileList = List.sortWith model.sorting files }, Cmd.none )

                Err error ->
                    ( { model | state = StateError (httpErrorToString error) }, Cmd.none )

        MsgFetchRootDone res ->
            case res of
                Ok file ->
                    ( { model | state = StateNormal, root = Just file }, Cmd.none )

                Err error ->
                    ( { model | state = StateError (httpErrorToString error) }, Cmd.none )

        MsgPathGoto int file ->
            ( { model
                | path = List.take int model.path
                , selectedFile = Nothing
              }
            , doListFiles model.token <| Maybe.andThen .id file
            )

        MsgFileClicked file ->
            ( { model | selectedFile = Just file }, Cmd.none )

        MsgFileDoubleClicked file ->
            if file.mimeType == "inode/directory" then
                enterChildDir file model

            else
                ( { model
                    | selectedFile = Just file
                  }
                , Maybe.withDefault Cmd.none <|
                    Maybe.map File.Download.url file.downloadUrl
                )

        MsgQuotaFetchDone res ->
            case res of
                Ok maybeFileQuota ->
                    ( { model | quota = maybeFileQuota }, Cmd.none )

                Err error ->
                    ( { model | state = StateError (httpErrorToString error) }, Cmd.none )

        MsgDoFileOperation op ->
            case ( model.selectedFile, op ) of
                ( Just file, OPDownload ) ->
                    ( model
                    , Maybe.withDefault Cmd.none <|
                        Maybe.map File.Download.url file.downloadUrl
                    )

                ( Just file, OPCut ) ->
                    ( { model | cutFiles = [ file ] }, Cmd.none )

                ( Just file, OPDelete ) ->
                    ( { model | state = StateRemovePrompt file }, Cmd.none )

                ( Just file, OPRename ) ->
                    ( { model | state = StateRenamePrompt file.name }, Cmd.none )

                ( _, OPUpload ) ->
                    ( model, File.Select.files [] (\f fs -> MsgUploadFilesSelected f fs) )

                ( _, OPMakeDirectory ) ->
                    ( { model | state = StateMakeDirPrompt "" }, Cmd.none )

                ( _, OPPaste ) ->
                    ( { model | cutFiles = [] }, Cmd.none )

                -- TODO
                _ ->
                    ignore

        MsgFileListClicked ->
            ( { model | selectedFile = Nothing }, Cmd.none )

        MsgIgnore ->
            ignore

        MsgDoReturnToNormal ->
            ( { model | state = StateNormal }, Cmd.none )

        MsgOnInputRename val ->
            case model.state of
                StateRenamePrompt _ ->
                    ( { model | state = StateRenamePrompt val }, Cmd.none )

                _ ->
                    ignore

        MsgDoRename ->
            case model.state of
                StateRenamePrompt newName ->
                    ( { model | state = StateNormal }
                    , Maybe.withDefault Cmd.none <|
                        Maybe.map (\file -> doRenameFile model.token file newName) model.selectedFile
                    )

                _ ->
                    ignore

        MsgOnInputMkdir val ->
            case model.state of
                StateMakeDirPrompt _ ->
                    ( { model | state = StateMakeDirPrompt val }, Cmd.none )

                _ ->
                    ignore

        MsgDoMkdir ->
            case model.state of
                StateMakeDirPrompt name ->
                    ( { model | state = StateNormal }
                    , doMakeDir model.token (Maybe.andThen .id <| getCwd model) name
                    )

                _ ->
                    ignore

        MsgDoRemoveFile file ->
            case model.state of
                StateRemovePrompt _ ->
                    ( { model | state = StateNormal }
                    , Maybe.withDefault Cmd.none <|
                        Maybe.map (\id -> doRemoveFile model.token id) <|
                            Maybe.andThen .id model.selectedFile
                    )

                _ ->
                    ignore

        MsgUploadFilesSelected current rest ->
            case model.state of
                StateNormal ->
                    let
                        totalBytes =
                            List.sum <| List.map ELMFile.size (current :: rest)
                    in
                    ( { model | state = StateUploading current rest 0 totalBytes }
                    , doUploadFile model.token (Maybe.andThen .id <| getCwd model) current
                    )

                _ ->
                    ignore

        MsgRenameDone result ->
            case result of
                Ok newFile ->
                    ( updateFileList model newFile, Cmd.none )

                Err error ->
                    ( { model | state = StateError (httpErrorToString error) }, Cmd.none )

        MsgMkdirDone result ->
            case result of
                Ok newFile ->
                    ( { model | fileList = List.sortWith model.sorting (newFile :: model.fileList) }, Cmd.none )

                Err error ->
                    ( { model | state = StateError (httpErrorToString error) }, Cmd.none )

        MsgRemoveDone result ->
            case result of
                Ok id ->
                    ( { model | fileList = List.filter (.id >> (/=) (Just id)) model.fileList }, Cmd.none )

                Err error ->
                    ( { model | state = StateError (httpErrorToString error) }, Cmd.none )

        MsgMoveDone result ->
            case result of
                Ok newFile ->
                    ( { model | fileList = List.sortWith model.sorting (newFile :: model.fileList) }, Cmd.none )

                Err error ->
                    ( { model | state = StateError (httpErrorToString error) }, Cmd.none )

        MsgUploadDone result ->
            case result of
                Ok newFile ->
                    let
                        ( newState, cmd ) =
                            case model.state of
                                StateUploading _ [] _ _ ->
                                    ( StateNormal, Cmd.none )

                                StateUploading current (next :: rest) done total ->
                                    ( StateUploading next rest (done + ELMFile.size current) total
                                    , doUploadFile model.token (Maybe.andThen .id <| getCwd model) next
                                    )

                                _ ->
                                    ( StateError
                                        "Внутрення ошибка: получен результат загрузки файла, который не ожидался"
                                    , Cmd.none
                                    )
                    in
                    ( { model
                        | fileList = List.sortWith model.sorting (newFile :: model.fileList)
                        , state = newState
                      }
                    , cmd
                    )

                Err error ->
                    ( { model | state = StateError (httpErrorToString error) }, Cmd.none )


viewMenu : Model -> Html Msg
viewMenu model =
    let
        item =
            { label = ""
            , icon = Nothing
            , onClick = Nothing
            , color = Nothing
            , isActive = False
            , isDisabled = False
            , title = Nothing
            }
    in
    IconMenu.view
        { items =
            [ [ { item
                    | icon = Just iconFolderPlus
                    , onClick = Just <| ActionMessage <| MsgDoFileOperation OPMakeDirectory
                    , title = Just "Создать каталог"
                }
              , { item
                    | icon = Just (IconGeneric "upload" "black")
                    , onClick = Just <| ActionMessage <| MsgDoFileOperation OPUpload
                    , title = Just "Загрузить на сервер"
                }
              , { item
                    | icon = Just (IconGeneric "download" "black")
                    , isDisabled =
                        Maybe.withDefault True <|
                            Maybe.map (\file -> file.mimeType == "inode/directory") model.selectedFile
                    , onClick = Just <| ActionMessage <| MsgDoFileOperation OPDownload
                    , title = Just "Скачать"
                }
              ]
            , [ { item
                    | icon = Just (IconGeneric "pencil alternate" "black")
                    , onClick = Just <| ActionMessage <| MsgDoFileOperation OPRename
                    , isDisabled = model.selectedFile == Nothing
                    , title = Just "Переименовать"
                }
              , { item
                    | icon = Just (IconGeneric "trash" "red")
                    , onClick = Just <| ActionMessage <| MsgDoFileOperation OPDelete
                    , isDisabled = model.selectedFile == Nothing
                    , title = Just "Удалить"
                }
              ]
            , [ { item
                    | icon = Just (IconGeneric "cut" "black")
                    , onClick = Just <| ActionMessage <| MsgDoFileOperation OPCut
                    , isDisabled = model.selectedFile == Nothing
                    , title = Just "Вырезать"
                }
              , { item
                    | icon = Just (IconGeneric "paste" "black")
                    , onClick = Just <| ActionMessage <| MsgDoFileOperation OPPaste
                    , isDisabled = model.cutFiles == []
                    , title = Just "Вставить"
                }
              ]
            ]
        , isVertical = False
        , isCompact = True
        , size = Just Tiny
        }


mimeType2ColoredIcon mime =
    case mime of
        "inode/directory" ->
            ( "folder", "yellow" )

        "image/png" ->
            ( "file image outline", "blue" )

        "image/jpeg" ->
            ( "file image outline", "blue" )

        "image/gif" ->
            ( "file image outline", "blue" )

        "image/bmp" ->
            ( "file image outline", "blue" )

        "text/plain" ->
            ( "file alternate outline", "back" )

        "application/pdf" ->
            ( "file pdf outline", "red" )

        "application/zip" ->
            ( "file archive outline", "green" )

        _ ->
            ( "file outline", "black" )


viewFileList : List File -> Maybe Uuid -> Html Msg
viewFileList files selectedFileID =
    let
        viewFile f isSelected =
            let
                ( icon, color ) =
                    mimeType2ColoredIcon f.mimeType
            in
            div
                [ style "display" "flex"
                , style "flex-direction" "column"
                , style "max-width" "100px"
                , style "max-height" "150px"
                , style "overflow" "hidden"
                , style "z-index" "2"
                , style "cursor" "pointer"
                , onClickPreventStop (MsgFileClicked f)
                , onDoubleClick (MsgFileDoubleClicked f)
                , classList
                    [ ( "p-10 m-5 file-item start-xs", True )
                    , ( "selected", isSelected )
                    ]
                ]
                [ div
                    [ class "row m-10 center-xs"
                    , style "font-size" "26pt"
                    ]
                    [ viewIcon (IconGeneric icon color) ]
                , div
                    [ class "row center-xs"
                    , style "font-size" "10pt"
                    , style "overflow-wrap" "anywhere"
                    ]
                    [ text <| f.name
                    ]
                ]

        filesHtml =
            List.map (\f -> viewFile f (f.id == selectedFileID)) files
    in
    div [ class "row p-10", onClick MsgFileListClicked ] <|
        if files == [] then
            [ div [ class "p-20 center-xs middle-xs col-xs-12" ] [ text "Каталог пуст" ] ]

        else
            filesHtml


viewFooter : Model -> Html Msg
viewFooter model =
    div [] [ text "" ]


view : Model -> Html Msg
view model =
    let
        rootPathItem =
            { label = ""
            , icon = Just (IconGeneric "home" "")
            , onClick = Just (ActionMessage (MsgPathGoto 0 model.root))
            }

        pathItem file i =
            { label = file.name
            , icon = Nothing
            , onClick = Just <| ActionMessage <| MsgPathGoto i <| Just file
            }

        pathItems =
            rootPathItem :: List.indexedMap (\i file -> pathItem file (i + 1)) model.path

        modal =
            case model.state of
                StateLoading ->
                    [ CompactInlineModal.view
                        { header = "Загружаем список файлов"
                        , onClose = Nothing
                        , body = text ""
                        , actions = []
                        }
                    ]

                StateNormal ->
                    []

                StateError err ->
                    [ CompactInlineModal.view <|
                        CompactInlineModal.initMessageBox
                            { title = "Ошибка"
                            , prompt = text err
                            , buttons = [ ButtonOK ]
                            , onClick = always MsgDoReturnToNormal
                            }
                    ]

                StateRenamePrompt val ->
                    [ CompactInlineModal.view <|
                        CompactInlineModal.initTextInput
                            { header = "Введите новое имя файла"
                            , prompt = ""
                            , currentValue = val
                            , validation = Just validateFileName
                            , onInput = Just MsgOnInputRename
                            , onConfirm = Just MsgDoRename
                            , onCancel = Just MsgDoReturnToNormal
                            }
                    ]

                StateMakeDirPrompt val ->
                    [ CompactInlineModal.view <|
                        CompactInlineModal.initTextInput
                            { header = "Введите имя директории"
                            , prompt = ""
                            , currentValue = val
                            , validation = Just validateFileName
                            , onInput = Just MsgOnInputMkdir
                            , onConfirm = Just MsgDoMkdir
                            , onCancel = Just MsgDoReturnToNormal
                            }
                    ]

                StateRemovePrompt file ->
                    let
                        onClick_ btn =
                            case btn of
                                ButtonYes ->
                                    MsgDoRemoveFile file

                                _ ->
                                    MsgDoReturnToNormal
                    in
                    [ CompactInlineModal.view <|
                        CompactInlineModal.initMessageBox
                            { title = "Подтверждение"
                            , prompt = span [] [ text "Действительно удалить файл ", strong [] [ text file.name ], text "?" ]
                            , buttons = [ ButtonNo, ButtonYes ]
                            , onClick = onClick_
                            }
                    ]

                StateUploading file files sizeDone sizeTotal ->
                    [ CompactInlineModal.view
                        { header = "Загрузка файлов"
                        , onClose = Nothing
                        , body =
                            div []
                                [ label []
                                    [ text <| "Загрузка файла "
                                    , strong []
                                        [ text <| ELMFile.name file
                                        ]
                                    ]
                                , ProgressBar.view
                                    { progressPercent = sizeDone * 100 // sizeTotal
                                    , color = Nothing
                                    , isActive = True
                                    , showProgress = Just ProgressPercents
                                    , label = Nothing
                                    , size = Nothing
                                    }
                                ]
                        , actions = []
                        }
                    ]
    in
    div [ class "ui segments", style "width" "100%" ]
        (modal
            ++ [ div [ class "ui secondary segment" ]
                    [ div [ style "display" "flex" ] [ viewMenu model ]
                    , div [ class "mt-10 ml-10" ] [ Breadcrumb.view pathItems ]
                    ]
               , div [ class "ui segment", style "padding" "0" ]
                    [ viewFileList model.fileList <| Maybe.andThen .id model.selectedFile
                    ]
               ]
        )

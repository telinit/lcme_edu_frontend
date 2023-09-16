module Component.FileManager exposing (..)

import Api exposing (ext_task)
import Api.Data exposing (File)
import Api.Request.File exposing (fileList, fileRead)
import Component.UI.Breadcrumb as Breadcrumb
import Component.UI.Common exposing (Action(..), IconType(..), viewIcon)
import Component.UI.IconMenu as IconMenu
import File as ELMFile
import File.Download
import Html exposing (..)
import Html.Attributes exposing (attribute, class, classList, href, style)
import Html.Events exposing (onClick, onDoubleClick)
import Http
import Task
import Util exposing (httpErrorToString, listLast, maybeToList, onClickPrevent, task_to_cmd)
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


type alias Model =
    { token : APIToken
    , root : Maybe File
    , path : List File
    , fileList : List File
    , selectedFile : Maybe SelectedFileID
    , state : State
    , sorting : File -> File -> Order
    }


type Msg
    = MsgListFilesDone (List File)
    | MsgListFilesError Http.Error
    | MsgFetchRootDone File
    | MsgFetchRootError Http.Error
    | MsgPathGoto Int (Maybe File)
    | MsgFileClicked File
    | MsgFileDoubleClicked File


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
            task_to_cmd MsgFetchRootError MsgFetchRootDone <|
                ext_task
                    identity
                    token
                    []
                    (fileRead <| Uuid.toString id)


doListFiles : APIToken -> Maybe Uuid -> Cmd Msg
doListFiles token mbRoot =
    task_to_cmd MsgListFilesError MsgListFilesDone <|
        ext_task
            identity
            token
            [ Maybe.withDefault ( "parent__isnull", "True" ) <|
                Maybe.map (\id -> ( "parent", Uuid.toString id )) mbRoot
            ]
            fileList


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
        Debug.log "file.parent /= Maybe.andThen .id model.root" ( model, Cmd.none )


init : APIToken -> Maybe Uuid -> ( Model, Cmd Msg )
init token mbRootID =
    ( { token = token
      , root = Nothing
      , state = StateLoading
      , path = []
      , fileList = []
      , selectedFile = Nothing
      , sorting = defaultSorting
      }
    , Cmd.batch [ doFetchRoot token mbRootID, doListFiles token mbRootID ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        ignore =
            ( model, Cmd.none )
    in
    case msg of
        MsgListFilesDone files ->
            ( { model | state = StateNormal, fileList = List.sortWith model.sorting files }, Cmd.none )

        MsgListFilesError error ->
            ( { model | state = StateError (httpErrorToString error) }, Cmd.none )

        MsgFetchRootDone file ->
            ( { model | state = StateNormal, root = Just file }, Cmd.none )

        MsgFetchRootError error ->
            ( { model | state = StateError (httpErrorToString error) }, Cmd.none )

        MsgPathGoto int file ->
            Debug.log
                "( { model ..."
                ( { model
                    | path = List.take int model.path
                  }
                , doListFiles model.token <| Maybe.andThen .id file
                )

        MsgFileClicked file ->
            ( { model | selectedFile = file.id }, Cmd.none )

        MsgFileDoubleClicked file ->
            if file.mimeType == "inode/directory" then
                enterChildDir file model

            else
                ( { model
                    | selectedFile = file.id
                  }
                , Maybe.withDefault Cmd.none <|
                    Maybe.map File.Download.url file.downloadUrl
                )


viewMenu : Model -> Html Msg
viewMenu model =
    let
        item =
            { label = ""
            , icon = Nothing
            , onClick = Nothing
            , color = Nothing
            , isActive = True
            , isDisabled = False
            }
    in
    IconMenu.view
        { items =
            [ { item | label = "Create" }
            , { item | label = "Rename" }
            , { item | label = "Delete" }
            ]
        , isVertical = False
        , isCompact = True
        , size = Nothing
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
                , onClick (MsgFileClicked f)
                , onDoubleClick (MsgFileDoubleClicked f)

                --, href <| Maybe.withDefault "" f.downloadUrl
                , classList
                    [ ( "p-10 m-5 file-item start-xs", True )
                    , ( "selected", Debug.log "isSelected" isSelected )
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
    div [ class "row" ] <|
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
    in
    div [ class "ui segments", style "width" "100%" ]
        [ div [ class "ui secondary segment" ]
            [ div [ style "display" "flex" ] [ viewMenu model ]
            , div [ class "mt-10 ml-10" ] [ Breadcrumb.view pathItems ]
            ]
        , div [ class "ui segment" ]
            [ viewFileList model.fileList model.selectedFile
            ]
        ]

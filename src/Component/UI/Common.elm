module Component.UI.Common exposing (..)

import Html exposing (Html, div, i)
import Html.Attributes exposing (attribute, class, style)


type Side
    = Left
    | Right


type Size
    = Mini
    | Tiny
    | Small
    | Medium
    | Large
    | Big
    | Huge
    | Massive


type ButtonKind
    = ButtonOK
    | ButtonCancel
    | ButtonRetry
    | ButtonIgnore
    | ButtonYes
    | ButtonNo
    | ButtonClose
    | ButtonSubmit
    | ButtonSave
    | ButtonDelete
    | ButtonRename
    | ButtonCustom String


type IconType msg
    = IconGeneric String Color
    | IconCustom (Html msg)


type alias CSSValue =
    String


type alias Color =
    String


type Action msg
    = ActionGotoLink String
    | ActionMessage msg


iconFolderPlus : IconType msg
iconFolderPlus =
    IconCustom
        (div []
            [ i
                [ class "folder outline icon"
                , style "margin" "0"
                ]
                []
            , i
                [ class "tiny green plus icon"
                , style "position" "relative"
                , style "right" "2px"
                , style "bottom" "-4px"
                , style "padding" "0"
                , style "margin-right" "-8px"
                ]
                []
            ]
        )


size2String : Size -> String
size2String size =
    case size of
        Mini ->
            "mini"

        Small ->
            "small"

        Large ->
            "large"

        Big ->
            "big"

        Huge ->
            "huge"

        Massive ->
            "massive"

        Tiny ->
            "tiny"

        Medium ->
            "medium"


buttonKind2Label : ButtonKind -> String
buttonKind2Label buttonKind =
    case buttonKind of
        ButtonOK ->
            "OK"

        ButtonCancel ->
            "Отмена"

        ButtonRetry ->
            "Повторить"

        ButtonIgnore ->
            "Пропустить"

        ButtonYes ->
            "Да"

        ButtonNo ->
            "Нет"

        ButtonClose ->
            "Закрыть"

        ButtonSubmit ->
            "Отправить"

        ButtonSave ->
            "Сохранить"

        ButtonDelete ->
            "Удалить"

        ButtonRename ->
            "Переименовать"

        ButtonCustom string ->
            string


viewIcon : IconType msg -> Html msg
viewIcon iconType =
    case iconType of
        IconGeneric name color ->
            i [ class <| name ++ " icon " ++ color ] []

        IconCustom html ->
            div [ class "icon" ] [ html ]

module Page.DefaultLayout exposing (..)

import Api.Data exposing (User)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Util exposing (link_span, user_has_role)


type alias Model =
    { show_sidebar : Bool
    , user : User
    }


type Msg
    = SidebarToggle
    | SidebarHide


logo classes =
    div [ class "ui middle aligned center aligned column", class classes ]
        [ a [ href "/" ]
            [ i
                [ class "braille icon large "
                , style "scale" "150%"
                , style "color" "#4183C4"
                , style "margin" "0 0 5px 0"
                ]
                []
            , h3
                [ style "display" "inline"
                , style "margin" "0 0 0 20px"
                , style "white-space" "nowrap"
                , style "color" "black"
                ]
                [ text "  Образование ЛНМО" ]
            ]
        ]


right_menu profile =
    [ div [ class "right menu" ]
        [ div [ class "item center aligned raw" ]
            [ a [ href "/profile", style "margin-right" "10px" ]
                [ i [ class "user icon large" ] []

                --, img [ src profile.avatar ] []
                , text profile.name
                ]
            , a [ class "ui button", href "/logout" ] [ text "Выйти" ]
            ]
        ]
    ]


menu items =
    List.map
        (\{ href, label, icon } ->
            a [ class "item", Html.Attributes.href href ]
                [ i [ class icon, class "icon" ] []
                , text label
                ]
        )
        items


make_header_pc : { name : String, avatar : String } -> List { href : String, label : String, icon : String } -> Html msg
make_header_pc profile items =
    div [ class "ui menu computer only grid" ]
        ([ logo "four wide column ui" ] ++ menu items ++ right_menu profile)


header_mobile =
    let
        toc =
            link_span
                [ class "toc middle aligned center aligned one wide column"
                , id "toc"
                , onClick SidebarToggle
                ]
                [ i [ class "sidebar icon large" ] [] ]
    in
    div
        [ class "ui mobile tablet only grid menu", style "margin-top" "0" ]
        [ toc, logo "fourteen wide" ]


view : (Msg -> msg) -> Model -> Html msg -> Html msg
view map_msg model html =
    let
        mb =
            Maybe.withDefault ""

        profile =
            { name = mb model.user.firstName ++ " " ++ mb model.user.lastName, avatar = "/profile.png" }

        items =
            List.filterMap identity
                [ Just { label = "Предметы", href = "/courses", icon = "book" }
                , if user_has_role model.user "student" then
                    Just { label = "Мои оценки", href = "/marks", icon = "chart bar outline" }

                  else
                    Nothing
                , Just { label = "Сообщения", href = "/messages", icon = "envelope outline" }
                , Just { label = "Администрирование", href = "/admin", icon = "cog" }
                ]

        sidebar =
            div
                [ style "display"
                    (if model.show_sidebar then
                        "initial"

                     else
                        "none"
                    )
                , style "position" "absolute"
                , style "top" "0"
                , style "left" "0"
                , style "z-index" "10"
                , style "width" "100%"
                , style "height" "100%"
                , style "background-color" "rgba(0,0,0,0.5)"
                , onClick SidebarHide
                ]
                [ div
                    [ class "ui visible sidebar vertical menu inverted"
                    , id "sidebar"

                    --, style "animation" "3s linear 1s scalex-animate"
                    ]
                    ([ div [ class "item" ] [] ] ++ menu items ++ right_menu profile)
                ]
    in
    div [ id "modal_context" ]
        [ div [ class "ui container", id "main_container" ]
            [ Html.map map_msg <| make_header_pc profile items
            , Html.map map_msg <| header_mobile
            , Html.map map_msg <| sidebar
            , html
            ]
        ]


init : User -> ( Model, Cmd Msg )
init user =
    ( { user = user, show_sidebar = False }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SidebarToggle ->
            ( { model | show_sidebar = not model.show_sidebar }, Cmd.none )

        SidebarHide ->
            ( { model | show_sidebar = False }, Cmd.none )

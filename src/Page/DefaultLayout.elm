module Page.DefaultLayout exposing (..)

import Api.Data exposing (UserDeep)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Util exposing (link_span, user_has_all_roles, user_has_any_role, user_has_role)


type alias Model =
    { show_sidebar : Bool
    , user : UserDeep
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


right_menu profile is_mobile =
    [ div [ class "right menu" ]
        [ div [ class "item raw center-xs" ]
            [ a
                [ href "/profile"
                , class <|
                    "mr-10"
                        ++ (if is_mobile then
                                " mt-15 mb-15"

                            else
                                ""
                           )
                , style "display" "block"
                ]
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
        (\{ href, label, icon, target } ->
            a
                (List.filterMap identity
                    [ Just <| class "item"
                    , Just <| Html.Attributes.href href
                    , Maybe.map Html.Attributes.target target
                    ]
                )
                [ i [ class icon, class "icon" ] []
                , text label
                ]
        )
        items


make_header_pc : { name : String, avatar : String } -> List { href : String, label : String, icon : String, target : Maybe String } -> Html msg
make_header_pc profile items =
    div [ class "ui menu computer only grid" ]
        ([ logo "four wide column ui" ] ++ menu items ++ right_menu profile False)


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
                [ Just { label = "Предметы", href = "/courses", icon = "book", target = Nothing }
                , if user_has_any_role model.user [ "parent" ] then
                    Just { label = "Оценки детей", href = "/marks", icon = "chart bar outline", target = Nothing }

                  else
                    Nothing
                , if user_has_any_role model.user [ "student" ] then
                    Just { label = "Мои оценки", href = "/marks", icon = "chart bar outline", target = Nothing }

                  else
                    Nothing
                , --, Just { label = "Сообщения", href = "/messages", icon = "envelope outline" }
                  if user_has_any_role model.user [ "admin", "staff" ] then
                    Just { label = "Администрирование", href = "/admin", icon = "cog", target = Nothing }

                  else
                    Nothing
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
                    ([ div [ class "item" ] [] ] ++ menu items ++ right_menu profile True)
                ]
    in
    div
        [ class "ui container"
        , id "main_container"
        , style "margin-left" "0"
        ]
        [ Html.map map_msg <| make_header_pc profile items
        , Html.map map_msg <| header_mobile
        , Html.map map_msg <| sidebar
        , html
        ]


init : UserDeep -> ( Model, Cmd Msg )
init user =
    ( { user = user, show_sidebar = False }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SidebarToggle ->
            ( { model | show_sidebar = not model.show_sidebar }, Cmd.none )

        SidebarHide ->
            ( { model | show_sidebar = False }, Cmd.none )

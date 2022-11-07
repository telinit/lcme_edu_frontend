module Component.Misc exposing (..)

import Api.Data exposing (UserShallow)
import Html exposing (..)
import Html.Attributes exposing (..)
import Util exposing (get_id_str, user_full_name)


user_link : Maybe String -> UserShallow -> Html msg
user_link mb_link user =
    a
        [ class "row middle-xs"
        , style "flex-wrap" "nowrap"
        , href <| Maybe.withDefault ("/profile/" ++ get_id_str user) mb_link
        ]
        --src <| Maybe.withDefault "" <| Maybe.map (\av -> av.downloadUrl) user.avatar
        [ img [ class "ui avatar image", src <| Maybe.withDefault "/img/user.png" user.avatar ] []
        , span [ style "margin-left" "0.5em" ] [ text <| user_full_name user ]
        ]

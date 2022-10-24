module Component.Misc exposing (..)

import Api.Data exposing (User)
import Html exposing (..)
import Html.Attributes exposing (..)
import Util exposing (get_id_str, user_full_name)


user_link : User -> Html msg
user_link user =
    a [ class "row middle-xs", href <| "/profile/" ++ get_id_str user ]
        --src <| Maybe.withDefault "" <| Maybe.map (\av -> av.downloadUrl) user.avatar
        [ img [ class "ui avatar image", src <| Maybe.withDefault "/img/user.png" user.avatar ] []
        , span [ style "margin-left" "0.5em" ] [ text <| user_full_name user ]
        ]

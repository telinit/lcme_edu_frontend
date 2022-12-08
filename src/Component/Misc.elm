module Component.Misc exposing (..)

import Api.Data exposing (UserShallow)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onCheck)
import Util exposing (get_id_str, user_full_name)


user_link : Maybe String -> UserShallow -> Html msg
user_link custom_link user =
    a
        [ style "flex-wrap" "nowrap"
        , href <| Maybe.withDefault ("/profile/" ++ get_id_str user) custom_link
        ]
        --src <| Maybe.withDefault "" <| Maybe.map (\av -> av.downloadUrl) user.avatar
        [ img [ class "ui avatar image", src <| Maybe.withDefault "/img/user.png" user.avatar ] []
        , span [] [ text <| user_full_name user ]
        ]


checkbox : String -> Bool -> (Bool -> msg) -> Html msg
checkbox label_ value_ onCheck_ =
    div [ class "ui checkbox" ]
        [ input [ type_ "checkbox", attribute "tabindex" "0", checked value_, onCheck onCheck_ ] []
        , label [] [ text label_ ]
        ]

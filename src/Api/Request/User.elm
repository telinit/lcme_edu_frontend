{-
   LCME EDU API
   ...

   The version of the OpenAPI document: v1
   Contact: sysadmin@lnmo.ru

   NOTE: This file is auto generated by the openapi-generator.
   https://github.com/openapitools/openapi-generator.git

   DO NOT EDIT THIS FILE MANUALLY.

   For more info on generating Elm code, see https://eriktim.github.io/openapi-elm/
-}


module Api.Request.User exposing
    ( userCreate
    , userDelete
    , userList
    , userLogin
    , userLogout
    , userPartialUpdate
    , userRead
    , userSelf
    , userSetPassword
    , userUpdate
    )

import Api
import Api.Data
import Dict
import Http
import Json.Decode
import Json.Encode


userCreate : Api.Data.User -> Api.Request Api.Data.User
userCreate data_body =
    Api.request
        "POST"
        "/user/"
        []
        []
        []
        (Just (Api.Data.encodeUser data_body))
        Api.Data.userDecoder


userDelete : String -> Api.Request ()
userDelete id_path =
    Api.request
        "DELETE"
        "/user/{id}/"
        [ ( "id", identity id_path ) ]
        []
        []
        Nothing
        (Json.Decode.succeed ())


userList : Api.Request (List Api.Data.User)
userList =
    Api.request
        "GET"
        "/user/"
        []
        []
        []
        Nothing
        (Json.Decode.list Api.Data.userDecoder)


userLogin : Api.Data.Login -> Api.Request ()
userLogin data_body =
    Api.request
        "POST"
        "/user/login/"
        []
        []
        []
        (Just (Api.Data.encodeLogin data_body))
        (Json.Decode.succeed ())


userLogout : Api.Request ()
userLogout =
    Api.request
        "GET"
        "/user/logout/"
        []
        []
        []
        Nothing
        (Json.Decode.succeed ())


userPartialUpdate : String -> Api.Data.User -> Api.Request Api.Data.User
userPartialUpdate id_path data_body =
    Api.request
        "PATCH"
        "/user/{id}/"
        [ ( "id", identity id_path ) ]
        []
        []
        (Just (Api.Data.encodeUser data_body))
        Api.Data.userDecoder


userRead : String -> Api.Request Api.Data.User
userRead id_path =
    Api.request
        "GET"
        "/user/{id}/"
        [ ( "id", identity id_path ) ]
        []
        []
        Nothing
        Api.Data.userDecoder


userSelf : Api.Request Api.Data.User
userSelf =
    Api.request
        "GET"
        "/user/self/"
        []
        []
        []
        Nothing
        Api.Data.userDecoder


userSetPassword : Api.Data.SetPassword -> Api.Request ()
userSetPassword data_body =
    Api.request
        "POST"
        "/user/set_password/"
        []
        []
        []
        (Just (Api.Data.encodeSetPassword data_body))
        (Json.Decode.succeed ())


userUpdate : String -> Api.Data.User -> Api.Request Api.Data.User
userUpdate id_path data_body =
    Api.request
        "PUT"
        "/user/{id}/"
        [ ( "id", identity id_path ) ]
        []
        []
        (Just (Api.Data.encodeUser data_body))
        Api.Data.userDecoder

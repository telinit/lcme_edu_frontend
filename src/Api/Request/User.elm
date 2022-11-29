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
    , userGetDeep
    , userImpersonate
    , userImportStudentsCsv
    , userList
    , userLogin
    , userLogout
    , userPartialUpdate
    , userRead
    , userResetPasswordComplete
    , userResetPasswordRequest
    , userSelf
    , userSetEmail
    , userSetPassword
    , userUpdate
    )

import Api
import Api.Data
import Dict
import Http
import Json.Decode
import Json.Encode


userCreate : Api.Data.UserShallow -> Api.Request Api.Data.UserShallow
userCreate data_body =
    Api.request
        "POST"
        "/user/"
        []
        []
        []
        (Just (Api.Data.encodeUserShallow data_body))
        Api.Data.userShallowDecoder


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


userGetDeep : String -> Api.Request Api.Data.UserDeep
userGetDeep id_path =
    Api.request
        "GET"
        "/user/{id}/deep/"
        [ ( "id", identity id_path ) ]
        []
        []
        Nothing
        Api.Data.userDeepDecoder


userImpersonate : String -> Api.Request ()
userImpersonate id_path =
    Api.request
        "GET"
        "/user/{id}/impersonate/"
        [ ( "id", identity id_path ) ]
        []
        []
        Nothing
        (Json.Decode.succeed ())


userImportStudentsCsv : Api.Data.ImportStudentsCSVRequest -> Api.Request Api.Data.ImportStudentsCSVResult
userImportStudentsCsv data_body =
    Api.request
        "POST"
        "/user/import_students_csv/"
        []
        []
        []
        (Just (Api.Data.encodeImportStudentsCSVRequest data_body))
        Api.Data.importStudentsCSVResultDecoder


userList : Api.Request (List Api.Data.UserShallow)
userList =
    Api.request
        "GET"
        "/user/"
        []
        []
        []
        Nothing
        (Json.Decode.list Api.Data.userShallowDecoder)


userLogin : Api.Data.Login -> Api.Request Api.Data.Token
userLogin data_body =
    Api.request
        "POST"
        "/user/login/"
        []
        []
        []
        (Just (Api.Data.encodeLogin data_body))
        Api.Data.tokenDecoder


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


userPartialUpdate : String -> Api.Data.UserShallow -> Api.Request Api.Data.UserShallow
userPartialUpdate id_path data_body =
    Api.request
        "PATCH"
        "/user/{id}/"
        [ ( "id", identity id_path ) ]
        []
        []
        (Just (Api.Data.encodeUserShallow data_body))
        Api.Data.userShallowDecoder


userRead : String -> Api.Request Api.Data.UserShallow
userRead id_path =
    Api.request
        "GET"
        "/user/{id}/"
        [ ( "id", identity id_path ) ]
        []
        []
        Nothing
        Api.Data.userShallowDecoder


userResetPasswordComplete : Api.Data.ResetPasswordComplete -> Api.Request ()
userResetPasswordComplete data_body =
    Api.request
        "POST"
        "/user/reset_password_complete/"
        []
        []
        []
        (Just (Api.Data.encodeResetPasswordComplete data_body))
        (Json.Decode.succeed ())


userResetPasswordRequest : Api.Data.ResetPasswordRequest -> Api.Request ()
userResetPasswordRequest data_body =
    Api.request
        "POST"
        "/user/reset_password_request/"
        []
        []
        []
        (Just (Api.Data.encodeResetPasswordRequest data_body))
        (Json.Decode.succeed ())


userSelf : Api.Request Api.Data.UserDeep
userSelf =
    Api.request
        "GET"
        "/user/self/"
        []
        []
        []
        Nothing
        Api.Data.userDeepDecoder


userSetEmail : String -> Api.Data.SetEmail -> Api.Request ()
userSetEmail id_path data_body =
    Api.request
        "POST"
        "/user/{id}/set_email/"
        [ ( "id", identity id_path ) ]
        []
        []
        (Just (Api.Data.encodeSetEmail data_body))
        (Json.Decode.succeed ())


userSetPassword : String -> Api.Data.SetPassword -> Api.Request ()
userSetPassword id_path data_body =
    Api.request
        "POST"
        "/user/{id}/set_password/"
        [ ( "id", identity id_path ) ]
        []
        []
        (Just (Api.Data.encodeSetPassword data_body))
        (Json.Decode.succeed ())


userUpdate : String -> Api.Data.UserShallow -> Api.Request Api.Data.UserShallow
userUpdate id_path data_body =
    Api.request
        "PUT"
        "/user/{id}/"
        [ ( "id", identity id_path ) ]
        []
        []
        (Just (Api.Data.encodeUserShallow data_body))
        Api.Data.userShallowDecoder

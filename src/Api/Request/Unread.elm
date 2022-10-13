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


module Api.Request.Unread exposing
    ( unreadCreate
    , unreadDelete
    , unreadList
    , unreadPartialUpdate
    , unreadRead
    , unreadUpdate
    )

import Api
import Api.Data
import Dict
import Http
import Json.Decode
import Json.Encode



unreadCreate : Api.Data.UnreadObject -> Api.Request Api.Data.UnreadObject
unreadCreate data_body =
    Api.request
        "POST"
        "/unread/"
        []
        []
        []
        (Just (Api.Data.encodeUnreadObject data_body))
        Api.Data.unreadObjectDecoder



unreadDelete : String -> Api.Request ()
unreadDelete id_path =
    Api.request
        "DELETE"
        "/unread/{id}/"
        [ ( "id", identity id_path ) ]
        []
        []
        Nothing
        (Json.Decode.succeed ())



unreadList : Api.Request (List Api.Data.UnreadObject)
unreadList =
    Api.request
        "GET"
        "/unread/"
        []
        []
        []
        Nothing
        (Json.Decode.list Api.Data.unreadObjectDecoder)



unreadPartialUpdate : String -> Api.Data.UnreadObject -> Api.Request Api.Data.UnreadObject
unreadPartialUpdate id_path data_body =
    Api.request
        "PATCH"
        "/unread/{id}/"
        [ ( "id", identity id_path ) ]
        []
        []
        (Just (Api.Data.encodeUnreadObject data_body))
        Api.Data.unreadObjectDecoder



unreadRead : String -> Api.Request Api.Data.UnreadObject
unreadRead id_path =
    Api.request
        "GET"
        "/unread/{id}/"
        [ ( "id", identity id_path ) ]
        []
        []
        Nothing
        Api.Data.unreadObjectDecoder



unreadUpdate : String -> Api.Data.UnreadObject -> Api.Request Api.Data.UnreadObject
unreadUpdate id_path data_body =
    Api.request
        "PUT"
        "/unread/{id}/"
        [ ( "id", identity id_path ) ]
        []
        []
        (Just (Api.Data.encodeUnreadObject data_body))
        Api.Data.unreadObjectDecoder

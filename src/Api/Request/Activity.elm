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


module Api.Request.Activity exposing
    ( activityCreate
    , activityDelete
    , activityImportForCourse
    , activityList
    , activityPartialUpdate
    , activityRead
    , activityUpdate
    )

import Api
import Api.Data
import Dict
import Http
import Json.Decode
import Json.Encode


activityCreate : Api.Data.Activity -> Api.Request Api.Data.Activity
activityCreate data_body =
    Api.request
        "POST"
        "/activity/"
        []
        []
        []
        (Just (Api.Data.encodeActivity data_body))
        Api.Data.activityDecoder


activityDelete : String -> Api.Request ()
activityDelete id_path =
    Api.request
        "DELETE"
        "/activity/{id}/"
        [ ( "id", identity id_path ) ]
        []
        []
        Nothing
        (Json.Decode.succeed ())


activityImportForCourse : Api.Data.ImportForCourse -> Api.Request Api.Data.ImportForCourseResult
activityImportForCourse data_body =
    Api.request
        "POST"
        "/activity/import_for_course/"
        []
        []
        []
        (Just (Api.Data.encodeImportForCourse data_body))
        Api.Data.importForCourseResultDecoder


activityList : Api.Request (List Api.Data.Activity)
activityList =
    Api.request
        "GET"
        "/activity/"
        []
        []
        []
        Nothing
        (Json.Decode.list Api.Data.activityDecoder)


activityPartialUpdate : String -> Api.Data.Activity -> Api.Request Api.Data.Activity
activityPartialUpdate id_path data_body =
    Api.request
        "PATCH"
        "/activity/{id}/"
        [ ( "id", identity id_path ) ]
        []
        []
        (Just (Api.Data.encodeActivity data_body))
        Api.Data.activityDecoder


activityRead : String -> Api.Request Api.Data.Activity
activityRead id_path =
    Api.request
        "GET"
        "/activity/{id}/"
        [ ( "id", identity id_path ) ]
        []
        []
        Nothing
        Api.Data.activityDecoder


activityUpdate : String -> Api.Data.Activity -> Api.Request Api.Data.Activity
activityUpdate id_path data_body =
    Api.request
        "PUT"
        "/activity/{id}/"
        [ ( "id", identity id_path ) ]
        []
        []
        (Just (Api.Data.encodeActivity data_body))
        Api.Data.activityDecoder

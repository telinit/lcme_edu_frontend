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


module Api.Request.Education exposing
    ( educationCreate
    , educationDelete
    , educationList
    , educationPartialUpdate
    , educationRead
    , educationSpecializationCreate
    , educationSpecializationDelete
    , educationSpecializationList
    , educationSpecializationPartialUpdate
    , educationSpecializationRead
    , educationSpecializationUpdate
    , educationUpdate
    )

import Api
import Api.Data exposing (..)
import Dict
import Http
import Json.Decode
import Json.Encode
import Uuid exposing (Uuid)


educationCreate : Api.Data.EducationShallow -> Api.Request Api.Data.EducationShallow
educationCreate data_body =
    Api.request
        "POST"
        "/education/"
        []
        []
        []
        (Maybe.map Http.jsonBody (Just (Api.Data.encodeEducationShallow data_body)))
        Api.Data.educationShallowDecoder


educationDelete : String -> Api.Request ()
educationDelete id_path =
    Api.request
        "DELETE"
        "/education/{id}/"
        [ ( "id", identity id_path ) ]
        []
        []
        Nothing
        (Json.Decode.succeed ())


educationList : Api.Request (List Api.Data.EducationShallow)
educationList =
    Api.request
        "GET"
        "/education/"
        []
        []
        []
        Nothing
        (Json.Decode.list Api.Data.educationShallowDecoder)


educationPartialUpdate : String -> Api.Data.EducationShallow -> Api.Request Api.Data.EducationShallow
educationPartialUpdate id_path data_body =
    Api.request
        "PATCH"
        "/education/{id}/"
        [ ( "id", identity id_path ) ]
        []
        []
        (Maybe.map Http.jsonBody (Just (Api.Data.encodeEducationShallow data_body)))
        Api.Data.educationShallowDecoder


educationRead : String -> Api.Request Api.Data.EducationShallow
educationRead id_path =
    Api.request
        "GET"
        "/education/{id}/"
        [ ( "id", identity id_path ) ]
        []
        []
        Nothing
        Api.Data.educationShallowDecoder


educationSpecializationCreate : Api.Data.EducationSpecialization -> Api.Request Api.Data.EducationSpecialization
educationSpecializationCreate data_body =
    Api.request
        "POST"
        "/education/specialization/"
        []
        []
        []
        (Maybe.map Http.jsonBody (Just (Api.Data.encodeEducationSpecialization data_body)))
        Api.Data.educationSpecializationDecoder


educationSpecializationDelete : Uuid -> Api.Request ()
educationSpecializationDelete id_path =
    Api.request
        "DELETE"
        "/education/specialization/{id}/"
        [ ( "id", Uuid.toString id_path ) ]
        []
        []
        Nothing
        (Json.Decode.succeed ())


educationSpecializationList : Api.Request (List Api.Data.EducationSpecialization)
educationSpecializationList =
    Api.request
        "GET"
        "/education/specialization/"
        []
        []
        []
        Nothing
        (Json.Decode.list Api.Data.educationSpecializationDecoder)


educationSpecializationPartialUpdate : Uuid -> Api.Data.EducationSpecialization -> Api.Request Api.Data.EducationSpecialization
educationSpecializationPartialUpdate id_path data_body =
    Api.request
        "PATCH"
        "/education/specialization/{id}/"
        [ ( "id", Uuid.toString id_path ) ]
        []
        []
        (Maybe.map Http.jsonBody (Just (Api.Data.encodeEducationSpecialization data_body)))
        Api.Data.educationSpecializationDecoder


educationSpecializationRead : Uuid -> Api.Request Api.Data.EducationSpecialization
educationSpecializationRead id_path =
    Api.request
        "GET"
        "/education/specialization/{id}/"
        [ ( "id", Uuid.toString id_path ) ]
        []
        []
        Nothing
        Api.Data.educationSpecializationDecoder


educationSpecializationUpdate : Uuid -> Api.Data.EducationSpecialization -> Api.Request Api.Data.EducationSpecialization
educationSpecializationUpdate id_path data_body =
    Api.request
        "PUT"
        "/education/specialization/{id}/"
        [ ( "id", Uuid.toString id_path ) ]
        []
        []
        (Maybe.map Http.jsonBody (Just (Api.Data.encodeEducationSpecialization data_body)))
        Api.Data.educationSpecializationDecoder


educationUpdate : String -> Api.Data.EducationShallow -> Api.Request Api.Data.EducationShallow
educationUpdate id_path data_body =
    Api.request
        "PUT"
        "/education/{id}/"
        [ ( "id", identity id_path ) ]
        []
        []
        (Maybe.map Http.jsonBody (Just (Api.Data.encodeEducationShallow data_body)))
        Api.Data.educationShallowDecoder

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


module Api.Request.Common exposing
    ( commonDepartmentCreate
    , commonDepartmentDelete
    , commonDepartmentList
    , commonDepartmentPartialUpdate
    , commonDepartmentRead
    , commonDepartmentUpdate
    , commonOrganisationCreate
    , commonOrganisationDelete
    , commonOrganisationList
    , commonOrganisationPartialUpdate
    , commonOrganisationRead
    , commonOrganisationUpdate
    )

import Api
import Api.Data
import Dict
import Http
import Json.Decode
import Json.Encode
import Uuid exposing (Uuid)



commonDepartmentCreate : Api.Data.Department -> Api.Request Api.Data.Department
commonDepartmentCreate data_body =
    Api.request
        "POST"
        "/common/department/"
        []
        []
        []
        (Just (Api.Data.encodeDepartment data_body))
        Api.Data.departmentDecoder



commonDepartmentDelete : Uuid -> Api.Request ()
commonDepartmentDelete id_path =
    Api.request
        "DELETE"
        "/common/department/{id}/"
        [ ( "id", Uuid.toString id_path ) ]
        []
        []
        Nothing
        (Json.Decode.succeed ())



commonDepartmentList : Api.Request (List Api.Data.Department)
commonDepartmentList =
    Api.request
        "GET"
        "/common/department/"
        []
        []
        []
        Nothing
        (Json.Decode.list Api.Data.departmentDecoder)



commonDepartmentPartialUpdate : Uuid -> Api.Data.Department -> Api.Request Api.Data.Department
commonDepartmentPartialUpdate id_path data_body =
    Api.request
        "PATCH"
        "/common/department/{id}/"
        [ ( "id", Uuid.toString id_path ) ]
        []
        []
        (Just (Api.Data.encodeDepartment data_body))
        Api.Data.departmentDecoder



commonDepartmentRead : Uuid -> Api.Request Api.Data.Department
commonDepartmentRead id_path =
    Api.request
        "GET"
        "/common/department/{id}/"
        [ ( "id", Uuid.toString id_path ) ]
        []
        []
        Nothing
        Api.Data.departmentDecoder



commonDepartmentUpdate : Uuid -> Api.Data.Department -> Api.Request Api.Data.Department
commonDepartmentUpdate id_path data_body =
    Api.request
        "PUT"
        "/common/department/{id}/"
        [ ( "id", Uuid.toString id_path ) ]
        []
        []
        (Just (Api.Data.encodeDepartment data_body))
        Api.Data.departmentDecoder



commonOrganisationCreate : Api.Data.Organization -> Api.Request Api.Data.Organization
commonOrganisationCreate data_body =
    Api.request
        "POST"
        "/common/organisation/"
        []
        []
        []
        (Just (Api.Data.encodeOrganization data_body))
        Api.Data.organizationDecoder



commonOrganisationDelete : Uuid -> Api.Request ()
commonOrganisationDelete id_path =
    Api.request
        "DELETE"
        "/common/organisation/{id}/"
        [ ( "id", Uuid.toString id_path ) ]
        []
        []
        Nothing
        (Json.Decode.succeed ())



commonOrganisationList : Api.Request (List Api.Data.Organization)
commonOrganisationList =
    Api.request
        "GET"
        "/common/organisation/"
        []
        []
        []
        Nothing
        (Json.Decode.list Api.Data.organizationDecoder)



commonOrganisationPartialUpdate : Uuid -> Api.Data.Organization -> Api.Request Api.Data.Organization
commonOrganisationPartialUpdate id_path data_body =
    Api.request
        "PATCH"
        "/common/organisation/{id}/"
        [ ( "id", Uuid.toString id_path ) ]
        []
        []
        (Just (Api.Data.encodeOrganization data_body))
        Api.Data.organizationDecoder



commonOrganisationRead : Uuid -> Api.Request Api.Data.Organization
commonOrganisationRead id_path =
    Api.request
        "GET"
        "/common/organisation/{id}/"
        [ ( "id", Uuid.toString id_path ) ]
        []
        []
        Nothing
        Api.Data.organizationDecoder



commonOrganisationUpdate : Uuid -> Api.Data.Organization -> Api.Request Api.Data.Organization
commonOrganisationUpdate id_path data_body =
    Api.request
        "PUT"
        "/common/organisation/{id}/"
        [ ( "id", Uuid.toString id_path ) ]
        []
        []
        (Just (Api.Data.encodeOrganization data_body))
        Api.Data.organizationDecoder

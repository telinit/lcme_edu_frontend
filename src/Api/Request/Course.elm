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


module Api.Request.Course exposing
    ( courseCreate
    , courseDelete
    , courseEnrollmentCreate
    , courseEnrollmentDelete
    , courseEnrollmentList
    , courseEnrollmentPartialUpdate
    , courseEnrollmentRead
    , courseEnrollmentUpdate
    , courseList
    , coursePartialUpdate
    , courseRead
    , courseUpdate
    )

import Api
import Api.Data
import Dict
import Http
import Json.Decode
import Json.Encode



courseCreate : Api.Data.Course -> Api.Request Api.Data.Course
courseCreate data_body =
    Api.request
        "POST"
        "/course/"
        []
        []
        []
        (Just (Api.Data.encodeCourse data_body))
        Api.Data.courseDecoder



courseDelete : String -> Api.Request ()
courseDelete id_path =
    Api.request
        "DELETE"
        "/course/{id}/"
        [ ( "id", identity id_path ) ]
        []
        []
        Nothing
        (Json.Decode.succeed ())



courseEnrollmentCreate : Api.Data.CourseEnrollment -> Api.Request Api.Data.CourseEnrollment
courseEnrollmentCreate data_body =
    Api.request
        "POST"
        "/course/enrollment/"
        []
        []
        []
        (Just (Api.Data.encodeCourseEnrollment data_body))
        Api.Data.courseEnrollmentDecoder



courseEnrollmentDelete : String -> Api.Request ()
courseEnrollmentDelete id_path =
    Api.request
        "DELETE"
        "/course/enrollment/{id}/"
        [ ( "id", identity id_path ) ]
        []
        []
        Nothing
        (Json.Decode.succeed ())



courseEnrollmentList : Api.Request (List Api.Data.CourseEnrollment)
courseEnrollmentList =
    Api.request
        "GET"
        "/course/enrollment/"
        []
        []
        []
        Nothing
        (Json.Decode.list Api.Data.courseEnrollmentDecoder)



courseEnrollmentPartialUpdate : String -> Api.Data.CourseEnrollment -> Api.Request Api.Data.CourseEnrollment
courseEnrollmentPartialUpdate id_path data_body =
    Api.request
        "PATCH"
        "/course/enrollment/{id}/"
        [ ( "id", identity id_path ) ]
        []
        []
        (Just (Api.Data.encodeCourseEnrollment data_body))
        Api.Data.courseEnrollmentDecoder



courseEnrollmentRead : String -> Api.Request Api.Data.CourseEnrollment
courseEnrollmentRead id_path =
    Api.request
        "GET"
        "/course/enrollment/{id}/"
        [ ( "id", identity id_path ) ]
        []
        []
        Nothing
        Api.Data.courseEnrollmentDecoder



courseEnrollmentUpdate : String -> Api.Data.CourseEnrollment -> Api.Request Api.Data.CourseEnrollment
courseEnrollmentUpdate id_path data_body =
    Api.request
        "PUT"
        "/course/enrollment/{id}/"
        [ ( "id", identity id_path ) ]
        []
        []
        (Just (Api.Data.encodeCourseEnrollment data_body))
        Api.Data.courseEnrollmentDecoder



courseList : Api.Request (List Api.Data.Course)
courseList =
    Api.request
        "GET"
        "/course/"
        []
        []
        []
        Nothing
        (Json.Decode.list Api.Data.courseDecoder)



coursePartialUpdate : String -> Api.Data.Course -> Api.Request Api.Data.Course
coursePartialUpdate id_path data_body =
    Api.request
        "PATCH"
        "/course/{id}/"
        [ ( "id", identity id_path ) ]
        []
        []
        (Just (Api.Data.encodeCourse data_body))
        Api.Data.courseDecoder



courseRead : String -> Api.Request Api.Data.Course
courseRead id_path =
    Api.request
        "GET"
        "/course/{id}/"
        [ ( "id", identity id_path ) ]
        []
        []
        Nothing
        Api.Data.courseDecoder



courseUpdate : String -> Api.Data.Course -> Api.Request Api.Data.Course
courseUpdate id_path data_body =
    Api.request
        "PUT"
        "/course/{id}/"
        [ ( "id", identity id_path ) ]
        []
        []
        (Just (Api.Data.encodeCourse data_body))
        Api.Data.courseDecoder

module Util exposing (..)

import Api.Data exposing (UserDeep, UserShallow)
import Array exposing (Array)
import Dict exposing (Dict)
import Html exposing (Attribute, span)
import Html.Attributes exposing (style)
import Html.Events exposing (custom, preventDefaultOn, stopPropagationOn)
import Http
import Json.Decode as JD
import Task
import Time exposing (Month(..))
import Uuid exposing (Uuid)


type Either a b
    = Left a
    | Right b


user_full_name : UserShallow -> String
user_full_name user =
    let
        mb =
            Maybe.withDefault ""
    in
    mb user.lastName ++ " " ++ mb user.firstName ++ " " ++ mb user.middleName


either_map : (a -> c) -> (b -> c) -> Either a b -> c
either_map fl fr e =
    case e of
        Left a ->
            fl a

        Right b ->
            fr b


httpErrorToString : Http.Error -> String
httpErrorToString error =
    case error of
        Http.BadUrl url ->
            "Некорректный адрес: " ++ url

        Http.Timeout ->
            "Таймаут"

        Http.NetworkError ->
            "Сетевая ошибка"

        Http.BadStatus code ->
            "Код ошибки: " ++ String.fromInt code

        Http.BadBody s ->
            "Некорректный формат данных: " ++ s


maybe_to_task : Maybe a -> Task.Task () a
maybe_to_task =
    Maybe.map Task.succeed >> Maybe.withDefault (Task.fail ())


task_to_cmd : (error -> a) -> (value -> a) -> Task.Task error value -> Cmd a
task_to_cmd on_err on_success =
    let
        on_result r =
            case r of
                Ok x ->
                    on_success x

                Err x ->
                    on_err x
    in
    Task.attempt on_result


task_map_to_bool : Task.Task a b -> Task.Task Never Bool
task_map_to_bool =
    Task.map (\_ -> True) >> Task.onError (\_ -> Task.succeed False)


onClickPrevent : msg -> Attribute msg
onClickPrevent msg =
    preventDefaultOn "click" (JD.map (\x -> ( x, True )) (JD.succeed msg))


onClickStop : msg -> Attribute msg
onClickStop msg =
    stopPropagationOn "click" (JD.map (\x -> ( x, True )) (JD.succeed msg))


onClickPreventStop : msg -> Attribute msg
onClickPreventStop msg =
    custom "click" <| JD.succeed { message = msg, stopPropagation = True, preventDefault = True }


link_span attrs body =
    span ([ style "color" "#4183C4", style "cursor" "pointer" ] ++ attrs) body


arrayUpdate : Int -> (a -> a) -> Array a -> Array a
arrayUpdate ix transform array =
    case Array.get ix array of
        Just el ->
            Array.set ix (transform el) array

        Nothing ->
            array


index_by : (a -> comparable) -> List a -> Dict comparable a
index_by key list =
    Dict.fromList <| List.map (\x -> ( key x, x )) list


index_by_id : List { a | id : Maybe comparable } -> Dict comparable { a | id : Maybe comparable }
index_by_id records =
    Dict.fromList <| List.filterMap (\rec -> Maybe.map (\id -> ( id, rec )) rec.id) records



-- FIXME: Remove this later


get_id : { a | id : Maybe Uuid } -> Uuid
get_id record =
    case record.id of
        Just id ->
            id

        Nothing ->
            Debug.todo <| "get_id: " ++ Debug.toString record


get_id_str : { a | id : Maybe Uuid } -> String
get_id_str =
    Uuid.toString << get_id


dictGroupBy : (b -> comparable) -> List b -> Dict comparable (List b)
dictGroupBy key list =
    let
        f x acc =
            Dict.update (key x) (Just << Maybe.withDefault [ x ] << Maybe.map (\old_list -> x :: old_list)) acc
    in
    List.foldl f Dict.empty list


dictFromTupleListMany : List ( comparable, b ) -> Dict comparable (List b)
dictFromTupleListMany =
    let
        update_ : a -> Maybe (List a) -> Maybe (List a)
        update_ new mb =
            case mb of
                Just l ->
                    Just <| new :: l

                Nothing ->
                    Just [ new ]
    in
    List.foldl (\( a, b ) -> Dict.update a (update_ b)) Dict.empty


maybeForceJust : Maybe a -> a
maybeForceJust =
    Maybe.withDefault <| Debug.todo "maybeForceJust"


zip : List a -> List b -> List ( a, b )
zip =
    List.map2 Tuple.pair


monthToInt : Month -> Int
monthToInt month =
    case month of
        Jan ->
            1

        Feb ->
            2

        Mar ->
            3

        Apr ->
            4

        May ->
            5

        Jun ->
            6

        Jul ->
            7

        Aug ->
            8

        Sep ->
            9

        Oct ->
            10

        Nov ->
            11

        Dec ->
            12


posixToDDMMYYYY zone posix =
    let
        dd =
            String.padLeft 2 '0' <| String.fromInt <| Time.toDay zone posix

        mm =
            String.padLeft 2 '0' <| String.fromInt <| monthToInt <| Time.toMonth zone posix

        yyyy =
            String.padLeft 4 '0' <| String.fromInt <| Time.toYear zone posix
    in
    dd ++ "." ++ mm ++ "." ++ yyyy


user_has_role user role =
    Maybe.withDefault False <| Maybe.map (List.member role) user.roles


user_has_all_roles user req_roles =
    Maybe.withDefault False <|
        Maybe.map
            (\user_roles ->
                List.all (\role -> List.member role user_roles) req_roles
            )
            user.roles

user_has_any_role user req_roles =
    Maybe.withDefault False <|
        Maybe.map
            (\user_roles ->
                List.any (\role -> List.member role user_roles) req_roles
            )
            user.roles

isJust mb =
    case mb of
        Just _ ->
            True

        _ ->
            False


user_deep_to_shallow : UserDeep -> UserShallow
user_deep_to_shallow userDeep =
    { id = userDeep.id
    , roles = userDeep.roles
    , lastLogin = userDeep.lastLogin
    , isSuperuser = userDeep.isSuperuser
    , username = userDeep.username
    , firstName = userDeep.firstName
    , lastName = userDeep.lastName
    , email = userDeep.email
    , isStaff = userDeep.isStaff
    , isActive = userDeep.isActive
    , dateJoined = userDeep.dateJoined
    , createdAt = userDeep.createdAt
    , updatedAt = userDeep.updatedAt
    , middleName = userDeep.middleName
    , birthDate = userDeep.birthDate
    , avatar = userDeep.avatar
    , groups = Maybe.map (List.filterMap .id) userDeep.groups
    , userPermissions = Maybe.map (List.filterMap .id) userDeep.userPermissions
    , children = Just <| List.filterMap .id userDeep.children
    , currentClass = userDeep.currentClass
    }

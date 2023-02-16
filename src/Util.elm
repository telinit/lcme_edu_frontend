module Util exposing (..)

import Api.Data exposing (ActivityContentType(..), ActivityFinalType(..), UserDeep, UserShallow)
import Api.Time exposing (Posix)
import Array exposing (Array)
import Dict exposing (Dict)
import Html exposing (Attribute, span)
import Html.Attributes exposing (style)
import Html.Events exposing (custom, preventDefaultOn, stopPropagationOn)
import Http
import Iso8601 exposing (fromTime, toTime)
import Json.Decode as JD
import Task exposing (Task)
import Time exposing (Month(..), Zone)
import Tuple exposing (first, second)
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


zip : List a -> List b -> List ( a, b )
zip =
    List.map2 Tuple.pair


zip3 : List a -> List b -> List c -> List ( a, b, c )
zip3 =
    List.map3 (\x y z -> ( x, y, z ))


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


posixToFullDate zone posix =
    let
        dd =
            String.fromInt <| Time.toDay zone posix

        mm =
            case monthToInt <| Time.toMonth zone posix of
                1 ->
                    "января"

                2 ->
                    "февраля"

                3 ->
                    "марта"

                4 ->
                    "апреля"

                5 ->
                    "мая"

                6 ->
                    "июня"

                7 ->
                    "июля"

                8 ->
                    "августа"

                9 ->
                    "сентября"

                10 ->
                    "октября"

                11 ->
                    "ноября"

                12 ->
                    "декабря"

                _ ->
                    ""

        yyyy =
            String.padLeft 4 '0' <| String.fromInt <| Time.toYear zone posix
    in
    dd ++ " " ++ mm ++ " " ++ yyyy


posixToISODate : Time.Posix -> Maybe String
posixToISODate =
    List.head << String.split "T" << fromTime


isoDateToPosix : String -> Maybe Time.Posix
isoDateToPosix str =
    case toTime <| str ++ "T00:00:00.000Z" of
        Ok t ->
            Just t

        Err _ ->
            Nothing


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
    , children = Just <| List.filterMap .id userDeep.children
    , currentClass = userDeep.currentClass
    , currentSpec = userDeep.currentSpec
    }


finalTypeToStr act =
    case act.finalType of
        Just f ->
            case f of
                Api.Data.ActivityFinalTypeQ1 ->
                    "1 четверть"

                Api.Data.ActivityFinalTypeQ2 ->
                    "2 четверть"

                Api.Data.ActivityFinalTypeQ3 ->
                    "3 четверть"

                Api.Data.ActivityFinalTypeQ4 ->
                    "4 четверть"

                Api.Data.ActivityFinalTypeH1 ->
                    "1 полугодие"

                Api.Data.ActivityFinalTypeH2 ->
                    "2 полугодие"

                Api.Data.ActivityFinalTypeY ->
                    "Годовая оценка"

                Api.Data.ActivityFinalTypeE ->
                    "Экзамен"

                Api.Data.ActivityFinalTypeF ->
                    "Итоговая оценка"

        Nothing ->
            ""


finalTypeOrder : ActivityFinalType -> Int
finalTypeOrder ft =
    case ft of
        ActivityFinalTypeQ1 ->
            1

        ActivityFinalTypeQ2 ->
            2

        ActivityFinalTypeQ3 ->
            4

        ActivityFinalTypeQ4 ->
            5

        ActivityFinalTypeH1 ->
            3

        ActivityFinalTypeH2 ->
            6

        ActivityFinalTypeY ->
            7

        ActivityFinalTypeE ->
            8

        ActivityFinalTypeF ->
            9


maybeFilter : (a -> Bool) -> Maybe a -> Maybe a
maybeFilter pred maybe =
    case maybe of
        Just a ->
            if pred a then
                Just a

            else
                Nothing

        Nothing ->
            Nothing


assoc_update : k -> v -> List ( k, v ) -> List ( k, v )
assoc_update k v list =
    case list of
        ( k_, v_ ) :: tl ->
            if k_ == k then
                ( k, v ) :: tl

            else
                ( k_, v_ ) :: assoc_update k v tl

        [] ->
            [ ( k, v ) ]


list_insert_at i x l =
    case ( i, l ) of
        ( 0, _ ) ->
            x :: l

        ( _, hd :: tl ) ->
            hd :: list_insert_at (i - 1) x tl

        ( _, [] ) ->
            x :: l


prec doRound digits x =
    let
        m =
            10.0 ^ toFloat digits

        v =
            x * m

        tr =
            toFloat <|
                truncate
                    (if doRound then
                        toFloat <| round v

                     else
                        v
                    )
    in
    tr / m


fileSizeToISO : Int -> String
fileSizeToISO size =
    let
        tib =
            toFloat <| 1024 * 1024 * 1024 * 1024

        gib =
            toFloat <| 1024 * 1024 * 1024

        mib =
            toFloat <| 1024 * 1024

        kib =
            toFloat <| 1024

        sizef =
            toFloat size
    in
    if sizef >= tib then
        String.fromFloat (prec True 2 <| sizef / tib) ++ " ТиБ"

    else if sizef >= gib then
        String.fromFloat (prec True 2 <| sizef / gib) ++ " ГиБ"

    else if sizef >= mib then
        String.fromFloat (prec True 2 <| sizef / mib) ++ " МиБ"

    else if sizef >= kib then
        String.fromFloat (prec True 2 <| sizef / kib) ++ " КиБ"

    else
        String.fromInt size ++ " байт"


get_id_str : { a | id : Maybe Uuid } -> String
get_id_str record =
    Maybe.withDefault "" <| Maybe.map Uuid.toString record.id


resultIsOK : Result a b -> Bool
resultIsOK result =
    case result of
        Ok _ ->
            True

        Err _ ->
            False


listTakeWhile : (a -> Bool) -> List a -> List a
listTakeWhile pred =
    listSplitWhile pred >> first


listDropWhile : (a -> Bool) -> List a -> List a
listDropWhile pred =
    listSplitWhile pred >> second


listSplitWhile : (a -> Bool) -> List a -> ( List a, List a )
listSplitWhile pred =
    let
        listSplitAt1 left right =
            case right of
                [] ->
                    ( List.reverse left, [] )

                hd :: tl ->
                    if pred hd then
                        listSplitAt1 (hd :: left) tl

                    else
                        ( List.reverse left, right )
    in
    listSplitAt1 []


maybeToList : Maybe a -> List a
maybeToList mb =
    List.filterMap identity [ mb ]


listTailWithEmpty : List a -> List a
listTailWithEmpty =
    List.drop 1


eitherGetRight : Either a b -> Maybe b
eitherGetRight either =
    case either of
        Left _ ->
            Nothing

        Right b ->
            Just b


eitherGetLeft : Either a b -> Maybe a
eitherGetLeft either =
    case either of
        Left a ->
            Just a

        Right _ ->
            Nothing


dict2DGet : comparable1 -> comparable2 -> Dict comparable1 (Dict comparable2 c) -> Maybe c
dict2DGet x y =
    Dict.get x >> Maybe.withDefault Dict.empty >> Dict.get y


listUniqueNaive : List a -> List a
listUniqueNaive list =
    List.foldl
        (\x r ->
            if List.member x r then
                r

            else
                r ++ [ x ]
        )
        []
        list


taskGetTZ : (Zone -> msg) -> Task e msg
taskGetTZ mapper =
    Task.map mapper Time.here


maybeOrElse : Maybe a -> Maybe a -> Maybe a
maybeOrElse mb fallback =
    case mb of
        Just a ->
            Just a

        Nothing ->
            fallback


actCT2string : ActivityContentType -> String
actCT2string activityContentType =
    case activityContentType of
        ActivityContentTypeGEN ->
            "Тема"

        ActivityContentTypeTXT ->
            "Материал"

        ActivityContentTypeTSK ->
            "Задание"

        ActivityContentTypeLNK ->
            "Ссылка"

        ActivityContentTypeMED ->
            "Медиа-контент"

        ActivityContentTypeFIN ->
            "Итог"


maybeFlatten : Maybe (Maybe a) -> Maybe a
maybeFlatten mb =
    case mb of
        Just x ->
            x

        _ ->
            Nothing


takeLongestPrefixBy : (a -> Bool) -> List a -> ( List a, List a )
takeLongestPrefixBy function list =
    let
        takeLongestPrefixBy1 result acc rest =
            case rest of
                [] ->
                    ( result, List.reverse acc ++ rest )

                hd :: tl ->
                    if function hd then
                        takeLongestPrefixBy1 (result ++ List.reverse acc ++ [ hd ]) [] tl

                    else
                        takeLongestPrefixBy1 result (hd :: acc) tl
    in
    takeLongestPrefixBy1 [] [] list


taskGetTimeAndZone : Task a ( Zone, Posix )
taskGetTimeAndZone =
    Task.map2 (\a b -> ( a, b )) Time.here Time.now

port module Ports exposing (..)


port setStorage : { key : String, value : String } -> Cmd msg


port setStorageDone : ({ key : String, value : String } -> msg) -> Sub msg


port getStorage : { key : String } -> Cmd msg


port getStorageDone : ({ key : String, value : String } -> msg) -> Sub msg


port toggleSidebar : String -> Cmd msg

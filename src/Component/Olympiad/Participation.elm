module Participation exposing (..)

import Api.Data exposing (Olympiad, OlympiadParticipation, UserShallow)
import Html exposing (Html, text)
import Uuid exposing (Uuid)



--type alias OlympiadID =
--    Uuid
--
--
--type alias PersonID =
--    Uuid


type alias CanEdit =
    Bool


type Field
    = FieldPerson
    | FieldOlympiad
    | FieldLocation
    | FieldStage
    | FieldTeamMember
    | FieldAward
    | FieldDate


type State
    = Initializing (Maybe UserShallow) (Maybe Olympiad)
    | StateView CanEdit OlympiadParticipation Olympiad
    | StateEdit OlympiadParticipation Olympiad


type Msg
    = MsgSetField Field String


type alias Model =
    { state : State
    }


initFromExisting : OlympiadParticipation -> Olympiad -> ( Model, Cmd Msg )
initFromExisting part olymp =
    ( { state = StateView False part olymp }, Cmd.none )


initNew : ( Model, Cmd Msg )
initNew =
    ( { state = Initializing Nothing Nothing }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    text ""

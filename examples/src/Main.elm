module Main exposing (main)

import Browser
import Browser.Navigation exposing (Key)
import FeatureFlags exposing (FeatureFlags)
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as JD
import Url exposing (Url)


type alias Model =
    { flags : FeatureFlags
    }


type Msg
    = NoOp
    | SetEagerLoadInvites Bool
    | SetLargeLoginButton Bool
    | SetLargeSignupButton Bool
    | SetCustomApiDomain (Maybe String)
    | SetExperimentalAnimationLibrary Bool


init : JD.Value -> Url -> Key -> ( Model, Cmd Msg )
init flags url _ =
    ( { flags =
            FeatureFlags.or
                (FeatureFlags.fromUrl url)
                (JD.decodeValue FeatureFlags.decoder flags
                    |> Result.withDefault FeatureFlags.default
                )
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SetEagerLoadInvites bool ->
            ( { model | flags = FeatureFlags.setEagerLoadInvites bool model.flags }
            , Cmd.none
            )

        SetLargeLoginButton bool ->
            ( { model | flags = FeatureFlags.setLargeLoginButton bool model.flags }
            , Cmd.none
            )

        SetLargeSignupButton bool ->
            ( { model | flags = FeatureFlags.setLargeSignupButton bool model.flags }
            , Cmd.none
            )

        SetCustomApiDomain bool ->
            ( { model | flags = FeatureFlags.setCustomApiDomain bool model.flags }
            , Cmd.none
            )

        SetExperimentalAnimationLibrary bool ->
            ( { model | flags = FeatureFlags.setUseExperimentalAnimationLibrary bool model.flags }
            , Cmd.none
            )


type alias Handlers =
    FeatureFlags.WhenApplied Msg


type alias Viewers =
    FeatureFlags.WhenApplied (Html Msg)


handlers : Handlers
handlers =
    { eagerLoadInvites = SetEagerLoadInvites
    , largeLoginButton = SetLargeLoginButton
    , largeSignupButton = SetLargeSignupButton
    , customApiDomain = SetCustomApiDomain
    , useExperimentalAnimationLibrary = SetExperimentalAnimationLibrary
    }


viewBoolFlag : String -> (Bool -> Msg) -> Bool -> Html Msg
viewBoolFlag name toMsg isOn =
    H.div []
        [ H.text
            (name
                ++ ": "
                ++ (if isOn then
                        "On"

                    else
                        "Off"
                   )
            )
        , H.button [ HE.onClick (toMsg (not isOn)) ] [ H.text "Toggle" ]
        ]


viewMaybeStringFlag : String -> (Maybe String -> Msg) -> Maybe String -> Html Msg
viewMaybeStringFlag name toMsg status =
    H.div []
        [ H.text
            (name
                ++ ": "
                ++ (case status of
                        Nothing ->
                            "Off"

                        Just s ->
                            "On (" ++ s ++ ")"
                   )
            )
        , case status of
            Nothing ->
                H.button [ HE.onClick (toMsg (Just "")) ] [ H.text "Turn on" ]

            Just s ->
                H.div []
                    [ H.button [ HE.onClick (toMsg Nothing) ] [ H.text "Turn off" ]
                    , H.input [ HA.type_ "text", HE.onInput (Just >> toMsg), HA.value s ] []
                    ]
        ]


flagViewers : Handlers -> Viewers
flagViewers toMsg =
    { eagerLoadInvites = viewBoolFlag "Eager load invites" toMsg.eagerLoadInvites
    , largeLoginButton = viewBoolFlag "Large login button" toMsg.largeLoginButton
    , largeSignupButton = viewBoolFlag "Large signup button" toMsg.largeSignupButton
    , useExperimentalAnimationLibrary =
        viewBoolFlag "Experimental animation library" toMsg.useExperimentalAnimationLibrary
    , customApiDomain = viewMaybeStringFlag "Custom API Domain" toMsg.customApiDomain
    }


view : Handlers -> Model -> Browser.Document Msg
view toMsg { flags } =
    { title = "Demo app"
    , body =
        [ H.div []
            [ H.div []
                (H.h2 [] [ H.text "Viewing all" ]
                    :: FeatureFlags.applyToAll (flagViewers toMsg) flags
                )
            , H.div []
                (H.h2 [] [ H.text "Viewing active only" ]
                    :: FeatureFlags.applyToActive (flagViewers toMsg) flags
                )
            ]
        ]
    }


main : Program JD.Value Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view handlers
        , subscriptions = always Sub.none
        , onUrlRequest = always NoOp
        , onUrlChange = always NoOp
        }

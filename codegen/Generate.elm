module Generate exposing (main)

import CodeGen.FeatureFlags as FF
import Gen.CodeGen.Generate as Generate
import String.Extra


main : Program {} () ()
main =
    Generate.run
        [ FF.fromFlags
            [ FF.maybeString "customApiDomain"
            , FF.bool "eagerLoadInvites"
            , FF.bool "largeLoginButton"
            , FF.bool "largeSignupButton"
            , FF.bool "useExperimentalAnimationLibrary"
            ]
            |> FF.withJsonConverters
            |> FF.withUrlConverters
            |> FF.withQueryKeyFormatter (\s -> "f-" ++ String.Extra.dasherize s)
            |> FF.generate "FeatureFlags"
        ]

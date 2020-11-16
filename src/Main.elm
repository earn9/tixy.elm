module Main exposing (main)

import Browser
import Browser.Events as Events
import Html exposing (Html, button, div, text)
import Html.Attributes as Attr exposing (attribute, class)
import Html.Events as Events
import Time


type alias Model =
    { time : Float
    , input : String
    }


initialModel : Model
initialModel =
    { time = 0
    , input = "sin(t - sqrt((x-7.5)^2 + (y-6)^2))"
    }


type Msg
    = Tick Float
    | ChangeInput String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick dt ->
            ( { model | time = model.time + dt }, Cmd.none )

        ChangeInput str ->
            ( { model | input = str }, Cmd.none )


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> ( initialModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \_ -> Events.onAnimationFrameDelta Tick
        }


styleFromValue : Float -> String
styleFromValue value =
    String.concat
        [ "transform: scale("
        , String.fromFloat value
        , "); background-color: "
        , if value < 0 then
            "red"

          else
            "white"
        , ";"
        ]


tixyFn t i x y =
    sin (t - sqrt ((x - 7.5) ^ 2 + (y - 6) ^ 2))


callTixyFn t intI =
    let
        i =
            toFloat intI

        x =
            modBy 16 intI

        y =
            intI // 16
    in
    clamp -1 1 <| tixyFn (t / 1000) i (toFloat x) (toFloat y)


viewField t i =
    div [ class "field", attribute "style" (styleFromValue (callTixyFn t i)) ] []


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ Html.h1 [] [ text "tixy.elm" ]
        , div [ class "map" ] <|
            (List.range 0 255 |> List.map (viewField model.time))
        , div [ class "editor" ]
            [ Html.span [] [ text "(t,i,x,y) =>" ]
            , Html.input
                [ Attr.value model.input
                , Events.onInput ChangeInput
                , Attr.attribute "autocomplete" "off"
                , Attr.attribute "autocapitalize" "off"
                , Attr.attribute "spellcheck" "false"
                , Attr.attribute "enterkeyhint" "go"
                ]
                []
            ]
        ]

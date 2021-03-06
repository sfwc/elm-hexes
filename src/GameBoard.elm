module GameBoard exposing (..)

import Types exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Svg.Events exposing (onClick)


borders : Int -> Int -> Int -> List Border
borders cellsAcross x y =
    List.concat
        [ if y == 1 then
            [ Border Red Up ]
          else
            []
        , if x == cellsAcross then
            [ Border Blue Right ]
          else
            []
        , if y == cellsAcross then
            [ Border Red Down ]
          else
            []
        , if x == 1 then
            [ Border Blue Left ]
          else
            []
        ]


hexPoints : Float -> String
hexPoints h =
    List.range 0 5
        |> List.map
            (\n -> toFloat n * (2 * pi / 6))
        |> List.map
            (\n -> ( sin n, cos n ))
        |> List.map
            (\( x, y ) ->
                toString (x * h / 2)
                    ++ ","
                    ++ toString (y * h / 2)
            )
        |> String.join " "


hex : Float -> List (Svg.Attribute msg) -> List (Svg msg) -> Svg msg
hex h attrs children =
    polygon
        (attrs
            ++ [ class "hex", points <| hexPoints h ]
        )
        children


chevronPoints : Float -> Int -> Int -> String
chevronPoints h start len =
    List.range start (start + len)
        |> List.map
            (\n -> toFloat n * (2 * pi / 6))
        |> List.map
            (\n -> ( sin n, cos n ))
        |> List.map
            (\( x, y ) ->
                toString (x * h / 2)
                    ++ ","
                    ++ toString (y * h / 2)
            )
        |> String.join " "


chevron : Float -> Border -> Svg Msg
chevron size border =
    let
        color =
            case border of
                Border Red _ ->
                    "red"

                Border Blue _ ->
                    "blue"

                NoBorder ->
                    "transparent"

        ps =
            case border of
                Border _ Up ->
                    chevronPoints (size + 5) 2 2

                Border _ Left ->
                    chevronPoints (size + 5) 4 2

                Border _ Down ->
                    chevronPoints (size + 5) 5 2

                Border _ Right ->
                    chevronPoints (size + 5) 1 2

                _ ->
                    chevronPoints size 0 0
    in
        polyline
            [ strokeWidth "3"
            , stroke color
            , fill "transparent"
            , points ps
            , class <| "chevron " ++ color
            ]
            []


rhombusTransform : Float -> Int -> Int -> ( Float, Float )
rhombusTransform h x y =
    let
        xmod =
            h * sqrt 3 / 2

        xOffset =
            toFloat x
                * xmod
                + toFloat y
                / 2
                * xmod
                + h

        ymod =
            h * 0.75

        yOffset =
            toFloat y * ymod + h
    in
        ( xOffset, yOffset )


drawBorders : Float -> List Border -> List (Svg Msg)
drawBorders size borders =
    List.map (chevron size) borders


hexGrid : (Int -> Int -> String) -> Int -> Svg Msg
hexGrid colorize cellsAcross =
    let
        tilesize =
            100

        ( height, width ) =
            rhombusTransform tilesize cellsAcross cellsAcross
    in
        List.range 1 cellsAcross
            |> List.concatMap
                (\y ->
                    List.range 1 cellsAcross
                        |> List.map
                            (\x ->
                                g
                                    [ transform <|
                                        "translate"
                                            ++ (toString <| rhombusTransform tilesize (x - 1) (y - 1))
                                    ]
                                <|
                                    [ hex
                                        tilesize
                                        [ fill <| colorize x y
                                        , Svg.Events.onClick <|
                                            TileClick x y
                                        ]
                                        []
                                    ]
                                        ++ (drawBorders tilesize <|
                                                borders cellsAcross x y
                                           )
                            )
                )
            |> svg
                [ Svg.Attributes.class "grid-container"
                , version "1.1"
                , viewBox
                    ("0 0 "
                        ++ toString height
                        ++ " "
                        ++ (toString <| width + (tilesize / 2))
                    )
                ]

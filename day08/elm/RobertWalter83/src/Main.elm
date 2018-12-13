module Main exposing (..)

import Browser
import Html exposing (..)
import Dict exposing (Dict)
import Maybe exposing (..)
import Array exposing (Array)

type alias Model =
  { solution : (Int, Int) }

type alias NodeInfo =
  { nChildren : Int, nMetadata : Int }

type alias Stack =
  List NodeInfo

-- INIT
init : Model
init =
  let
    -- PART 1
    sum = sumMetadata input 0 [] 0
  
    -- PART 2
    (idx, values) = nodeValue input 0
  in
    { solution = (sum, List.head values |> withDefault -1) }

-- Solution part2
nodeValue : Array Int -> Int -> (Int, List Int)
nodeValue licData index =
  let
    (indexUpdated, mbNode) = processNode2 licData index
  in
    case mbNode of
      Just node ->
        if node.nChildren == 0 then
          processLeaf licData indexUpdated node
        
        else
          let
            counter = List.range 0 (node.nChildren-1) 
            (indexNew, valuesNew) = 
              List.foldl 
                (\_ (idx, values) -> 
                  let
                    (idxNew, vals) = nodeValue licData idx
                  in
                    (idxNew, List.append values vals)
                ) 
                (indexUpdated, [])
                counter
              
            valueArray = Array.fromList valuesNew
            (indexFinal, pointers) = getPointers licData indexNew node.nMetadata
            
          in
            (indexFinal, [List.foldl (\p sum -> sum + (Array.get (p-1) valueArray |> withDefault 0)) 0 pointers])
          
      Maybe.Nothing ->
        -- error 
        (0, []) 

processLeaf : Array Int -> Int -> NodeInfo -> (Int, List Int)
processLeaf licData index node =
  let
    (indexNew, metaDelta) = processMetadata licData index node.nMetadata
  in
    (indexNew, [metaDelta])
    
getPointers : Array Int -> Int -> Int -> (Int, List Int)
getPointers licData index length =
  let
    mdRange = List.range index (index+length-1)
  in
    (index+length, List.map (\indexMetadata -> (Array.get indexMetadata licData |> withDefault 0)) mdRange)
       
processNode2 : Array Int -> Int -> (Int, Maybe NodeInfo)
processNode2 licData index = 
  let
    mbChildren = Array.get index licData 
    mbMeta = Array.get (index+1) licData 
  in
    case (mbChildren, mbMeta) of
      (Just children, Just meta) ->
        (index+2, Just { nChildren = children, nMetadata = meta })
          
      (_, _) ->
        (index, Maybe.Nothing)  

-- Solution part1
sumMetadata : Array Int -> Int -> Stack -> Int -> Int
sumMetadata licData index stkNodes sum =
  case stkNodes of
    [] ->
      processNode licData index stkNodes sum    

    node :: tail ->
      if node.nChildren == 0 then
        let
          (indexNew, metaDelta) = processMetadata licData index node.nMetadata 
        in
          sumMetadata licData indexNew tail (sum+metaDelta)

      else
        processNode licData index stkNodes sum

processNode : Array Int -> Int -> Stack -> Int -> Int
processNode licData index stkNodes sum = 
  let
    mbChildren = Array.get index licData 
    mbMeta = Array.get (index+1) licData 
  in
    case (mbChildren, mbMeta) of
      (Just children, Just meta) ->
        let
          stkNew = 
            case stkNodes of
              [] ->
                [{nChildren = children, nMetadata = meta}] 
          
              node :: tail ->
                List.append [{nChildren = children, nMetadata = meta}] <| List.append [{nChildren = node.nChildren-1, nMetadata = node.nMetadata}] tail 
        in
          sumMetadata licData (index+2) stkNew sum
          
      (_, _) ->
        sum    

processMetadata : Array Int -> Int -> Int -> (Int, Int)
processMetadata licData index meta =
  let
    mdRange = List.range index (index+meta-1)
    mdDelta = List.foldl (\indexMetadata sum -> sum + (Array.get indexMetadata licData |> withDefault 0)) 0 mdRange
  in
    (index+meta, mdDelta)

getChildPointers : Array Int -> Int -> Int -> (Int, List Int)
getChildPointers licData index meta =
  let
    mdRange = List.range index (index+meta-1)
    pointers = List.map (\indexMetadata -> Array.get indexMetadata licData |> withDefault 0) mdRange
  in
    (index+meta, pointers)

-- UPDATE (no op)

type Msg = Nothing

update : Msg -> Model -> Model
update msg model =
  case msg of
    Nothing -> model 
      
-- VIEW

view : Model -> Html Msg
view model =
  div [] 
  [ div [] [ text <| "Part1:" ++ (String.fromInt <| Tuple.first model.solution ) ]
  , div [] [ text <| "Part2:" ++ (String.fromInt <| Tuple.second model.solution ) ]
  ]

-- MAIN

main = Browser.sandbox
  { init = init
  , update = update
  , view = view }


-- INPUT DATA

parse : String -> Array Int
parse data =
  String.split " " data |> List.map (\s -> String.toInt s |> withDefault -1) |> Array.fromList  


test1 =
  parse testData1

input =
  parse inputData


testData1 = 
  "2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2"

inputData =
  "7 11 6 3 5 5 3 5 1 8 0 8 9 9 2 3 4 3 3 1 1 3 1 2 2 1 1 3 1 9 0 9 4 9 6 4 7 7 4 1 1 1 2 1 1 3 3 3 1 1 1 6 0 8 3 5 3 6 4 1 1 8 1 1 2 3 1 2 1 4 4 1 4 3 5 1 5 0 8 4 1 7 2 4 7 8 7 1 3 2 2 3 1 9 0 7 1 1 4 5 5 4 6 2 1 1 2 3 2 1 1 1 1 9 0 10 9 7 8 1 1 7 8 9 9 1 3 1 2 3 3 3 1 1 2 3 4 1 4 5 3 4 1 7 0 8 4 5 7 2 2 1 8 8 3 3 1 1 2 2 1 1 9 0 11 2 3 9 3 5 3 1 3 4 4 6 3 1 2 3 3 1 3 2 3 1 9 0 7 8 1 1 6 3 5 8 1 1 2 2 3 2 1 3 1 4 1 1 4 3 6 1 8 0 8 6 8 9 5 1 1 9 2 1 1 2 2 1 2 2 1 1 8 0 10 1 3 6 1 4 2 3 4 7 6 3 1 3 3 1 3 1 1 1 7 0 8 7 7 1 6 8 5 3 7 3 3 1 3 2 1 1 1 3 4 2 4 3 3 7 1 6 0 10 6 2 4 1 8 7 7 5 1 2 1 1 1 2 1 2 1 5 0 8 7 7 1 5 4 6 4 1 1 1 1 1 3 1 5 0 7 1 1 8 7 4 8 9 1 1 2 1 3 1 2 5 2 1 1 2 3 3 6 1 5 5 3 3 7 1 7 0 10 2 9 9 7 1 8 6 8 7 5 3 3 2 1 1 3 3 1 8 0 7 8 8 8 1 3 2 7 3 1 2 1 1 2 3 2 1 8 0 9 1 2 1 4 7 7 6 2 1 1 1 2 1 2 1 1 2 2 5 4 5 1 2 1 3 4 1 6 0 6 2 3 4 1 7 7 1 2 1 3 1 3 1 7 0 6 5 1 1 4 1 4 1 2 2 3 3 2 3 1 6 0 8 3 4 1 9 6 3 5 2 2 1 3 2 2 1 3 3 4 1 3 7 1 8 0 7 8 7 3 1 6 4 6 3 1 3 2 1 2 1 2 1 8 0 10 7 1 2 7 9 8 2 8 9 8 1 1 1 2 2 3 1 1 1 6 0 8 4 1 8 3 5 1 8 2 1 1 1 3 1 2 2 4 5 4 3 5 2 3 6 1 5 0 6 6 8 5 1 9 5 3 1 2 2 3 1 6 0 11 7 4 6 5 9 2 9 9 9 6 1 2 3 1 1 2 3 1 8 0 8 8 6 9 5 4 6 1 3 2 1 1 1 3 3 3 2 4 3 1 3 4 2 3 4 1 8 0 8 9 6 6 9 1 2 3 9 2 1 2 2 2 2 2 1 1 9 0 11 5 4 3 1 1 6 6 4 8 5 3 1 2 1 1 2 1 2 2 1 1 5 0 11 8 8 4 6 7 8 7 5 2 9 1 1 1 2 1 2 4 2 3 1 2 5 3 5 3 3 7 1 7 0 11 6 4 3 6 1 9 2 1 3 4 2 1 1 1 3 1 3 3 1 7 0 8 2 2 8 5 1 1 6 3 1 3 1 2 1 3 2 1 7 0 6 1 4 3 8 3 6 3 1 3 1 3 3 2 3 1 1 3 5 4 5 3 4 1 7 0 11 9 1 7 9 7 9 6 1 9 1 8 2 2 3 1 3 3 2 1 5 0 9 1 2 2 1 3 2 5 9 7 1 1 3 1 1 1 5 0 9 3 8 4 6 9 7 5 1 1 1 1 3 1 1 3 2 3 2 3 4 1 9 0 9 1 9 1 8 2 2 4 1 7 2 1 3 1 2 2 2 1 2 1 7 0 7 1 1 5 6 1 8 2 1 1 3 3 3 1 2 1 8 0 10 1 7 1 2 5 4 3 9 6 2 1 3 1 3 3 2 1 3 5 2 5 3 3 5 1 8 0 9 4 1 7 3 2 1 5 5 4 2 1 1 3 3 1 3 3 1 7 0 11 7 9 5 1 1 9 3 8 6 9 4 2 1 1 1 1 1 3 1 6 0 7 1 1 4 5 6 3 3 2 1 3 2 1 1 5 3 3 1 2 3 5 1 8 0 10 8 7 3 6 1 5 9 2 3 4 2 3 1 2 1 3 1 1 1 5 0 9 6 1 5 1 7 1 7 9 5 1 2 1 3 2 1 8 0 6 2 9 4 1 4 5 3 3 3 2 2 3 1 1 3 3 4 1 1 4 3 7 5 5 3 4 1 7 0 7 5 5 6 2 8 1 8 1 2 3 1 1 1 1 1 6 0 11 7 5 4 1 1 3 3 5 3 3 4 1 1 1 3 2 2 1 6 0 6 8 1 8 1 6 5 1 2 2 2 1 1 2 3 5 2 3 6 1 9 0 6 4 1 1 1 9 2 3 2 2 3 1 1 2 2 2 1 6 0 7 4 1 7 1 4 2 5 2 1 2 2 1 3 1 5 0 8 3 5 1 2 1 3 1 7 2 1 1 1 1 2 2 1 2 1 1 3 4 1 5 0 7 5 1 2 7 4 6 6 3 3 1 3 2 1 5 0 7 1 1 2 8 8 6 6 1 2 1 3 1 1 5 0 11 7 2 1 3 8 5 4 9 7 7 8 2 3 2 3 1 3 1 2 1 3 5 1 6 0 10 8 3 1 4 7 8 8 8 9 8 3 1 1 3 3 3 1 6 0 8 3 2 9 5 1 6 1 8 3 3 2 1 2 1 1 5 0 11 6 6 7 7 1 4 1 1 7 1 1 1 2 1 2 3 5 1 1 2 1 3 6 1 8 0 11 2 1 6 6 1 6 2 8 4 9 4 3 1 2 2 2 2 3 1 1 6 0 11 9 7 5 4 6 1 4 6 5 4 6 3 2 3 1 2 1 1 8 0 9 3 7 7 3 1 8 8 8 8 2 3 1 2 3 2 3 3 3 5 1 2 5 2 1 3 5 7 1 5 4 3 5 1 7 0 10 1 6 8 9 7 7 1 9 6 6 3 1 3 2 1 3 3 1 6 0 8 6 9 2 3 4 6 1 2 1 1 3 1 2 3 1 9 0 11 8 6 5 2 6 5 4 7 3 1 3 1 1 1 2 3 2 1 1 1 1 3 3 4 3 3 4 1 7 0 11 8 1 5 7 1 1 3 7 6 7 2 1 3 3 1 2 1 2 1 7 0 8 1 1 1 8 4 5 8 7 2 3 2 1 3 1 3 1 6 0 6 1 6 5 7 6 1 2 1 3 3 2 3 1 1 5 3 3 4 1 5 0 8 2 1 5 1 8 5 8 7 1 1 1 1 3 1 8 0 7 8 4 4 4 1 7 3 2 3 1 2 3 3 2 2 1 5 0 6 5 1 4 6 3 9 1 2 3 3 3 5 4 1 5 3 5 1 7 0 10 7 5 9 2 4 4 9 1 5 1 3 3 1 2 3 2 2 1 6 0 11 1 2 1 5 5 6 1 1 6 3 8 2 1 1 2 2 1 1 9 0 10 5 1 1 7 1 7 4 1 9 8 1 3 1 3 3 1 3 1 2 4 2 4 2 3 3 6 1 9 0 7 1 5 1 6 1 8 7 1 1 3 3 2 1 2 2 1 1 6 0 11 9 1 9 1 6 3 8 7 6 7 1 1 2 2 1 1 1 1 8 0 9 1 7 8 2 8 7 4 1 6 1 3 1 1 3 1 3 3 4 1 2 4 2 2 5 2 3 5 5 4 3 5 1 9 0 8 5 7 9 2 1 7 7 7 2 3 1 1 3 1 3 1 3 1 8 0 11 6 5 1 1 8 8 8 3 9 6 6 1 3 2 1 1 1 1 1 1 5 0 11 5 1 9 5 1 6 9 2 1 9 1 1 2 1 1 2 2 4 1 4 1 3 4 1 6 0 7 8 5 5 4 8 1 1 1 1 2 1 3 1 1 8 0 9 1 7 9 1 2 4 1 5 3 2 1 3 3 3 2 3 1 1 5 0 11 6 9 8 3 2 6 3 8 3 3 1 1 2 3 3 3 5 3 4 4 3 4 1 6 0 9 1 6 5 9 9 8 5 1 5 1 2 1 3 2 1 1 8 0 6 7 2 1 6 5 1 2 2 1 3 1 2 1 2 1 6 0 6 1 8 9 7 8 3 2 1 2 1 1 1 2 1 2 1 3 5 1 7 0 7 6 1 1 8 7 9 2 1 1 1 2 2 3 2 1 8 0 10 8 9 5 2 3 7 3 7 1 9 1 2 2 1 3 1 2 3 1 5 0 6 4 1 9 8 1 9 1 3 3 3 1 3 2 1 2 3 3 4 1 6 0 10 8 7 9 5 1 4 8 1 1 7 2 3 2 2 1 2 1 9 0 6 8 5 1 8 2 1 3 2 2 1 3 2 3 1 1 1 5 0 10 4 3 7 2 4 7 1 5 1 6 3 2 2 1 3 1 1 3 5 1 4 2 1 7 8 2 7 2 5 3 3 5 1 7 0 7 8 3 1 8 1 3 6 2 1 2 3 1 1 3 1 6 0 9 8 1 7 4 1 1 1 3 2 1 3 3 3 3 1 1 9 0 9 2 1 5 3 4 6 1 8 3 3 1 3 1 1 3 2 1 3 2 3 1 1 1 3 7 1 8 0 10 2 4 8 4 1 7 6 8 6 5 3 2 3 3 1 2 3 3 1 5 0 7 6 1 8 8 5 3 3 3 3 3 1 1 1 5 0 10 4 5 3 6 1 2 7 4 6 4 3 1 1 3 2 3 2 3 3 3 3 3 3 5 1 9 0 10 1 8 3 2 7 3 1 1 3 5 3 1 1 2 1 1 1 2 2 1 5 0 11 8 4 1 4 3 5 9 8 2 5 1 1 3 2 1 1 1 5 0 7 4 9 5 4 4 1 9 1 2 2 3 2 2 4 1 2 3 3 4 1 8 0 10 3 4 9 7 1 1 4 4 3 1 1 1 2 2 2 2 1 3 1 6 0 11 7 8 3 1 2 9 4 3 1 7 7 3 3 1 3 2 2 1 9 0 8 1 4 2 3 7 5 8 4 3 2 3 1 1 3 1 3 3 1 4 5 3 3 4 1 6 0 10 1 8 4 5 6 3 9 7 5 4 1 3 3 1 2 1 1 7 0 9 3 7 8 8 6 7 7 1 4 3 2 2 1 2 3 3 1 5 0 11 7 8 1 8 1 1 5 9 6 1 2 1 3 1 3 3 4 5 3 5 4 3 1 5 5 3 7 1 6 0 9 1 4 2 1 8 1 4 6 1 1 3 3 1 1 2 1 8 0 9 5 6 2 9 4 1 6 1 3 3 1 3 1 2 1 3 3 1 6 0 9 5 1 6 9 3 2 9 4 3 1 3 3 2 1 3 3 1 3 3 4 2 1 3 7 1 9 0 7 3 1 3 9 4 6 2 1 3 2 2 3 1 1 1 1 1 9 0 7 1 6 2 3 7 3 2 3 3 3 1 1 3 3 1 1 1 7 0 11 9 8 8 6 7 8 8 1 3 7 8 2 2 2 3 1 1 3 2 5 2 1 5 1 3 3 4 1 8 0 9 8 1 8 3 1 8 7 2 1 3 2 2 3 3 1 1 1 1 8 0 6 3 3 7 7 3 1 3 1 3 1 3 1 2 3 1 5 0 11 2 5 6 1 2 5 7 4 1 8 2 2 3 1 1 3 3 2 1 5 3 5 1 8 0 10 1 8 3 2 2 6 4 6 8 4 3 2 1 3 3 2 2 2 1 5 0 11 3 6 4 8 3 3 7 9 7 1 4 2 2 1 2 2 1 9 0 8 6 9 3 3 3 1 2 5 2 1 2 3 2 1 1 3 1 3 1 3 4 1 3 7 1 9 0 9 3 4 3 5 2 1 8 6 5 2 2 1 1 3 2 1 2 2 1 5 0 8 1 9 2 4 4 3 7 2 1 1 1 1 2 1 5 0 11 5 5 2 9 7 5 6 3 8 1 8 1 3 3 2 3 1 4 3 3 1 1 3 5 2 5 6 2 5 3 3 7 1 8 0 7 2 3 9 3 2 1 5 1 2 1 2 1 2 2 3 1 6 0 6 1 1 4 7 5 6 2 1 2 1 3 1 1 5 0 6 2 2 7 2 2 1 3 2 1 1 3 1 4 1 2 2 1 2 3 5 1 6 0 11 5 1 2 8 5 2 8 4 3 9 1 3 1 1 1 1 1 1 6 0 6 5 1 6 4 8 1 2 3 3 1 3 1 1 6 0 8 7 4 8 4 1 9 7 5 3 3 3 2 1 1 5 5 2 1 3 3 5 1 7 0 8 9 1 7 8 7 3 8 3 2 1 2 3 3 2 1 1 5 0 9 1 1 7 9 2 6 1 7 6 1 1 2 2 2 1 9 0 11 3 9 6 8 8 1 1 1 6 4 1 2 3 2 2 3 2 1 3 3 3 5 1 2 5 3 4 1 9 0 8 7 1 8 8 6 6 9 3 3 2 2 1 3 2 3 3 1 1 6 0 6 2 4 7 9 3 1 1 3 1 3 2 2 1 7 0 6 2 5 7 9 1 7 1 2 1 3 1 1 1 3 3 1 1 3 4 1 7 0 10 7 8 5 6 1 7 9 3 7 1 2 2 3 1 2 3 1 1 9 0 9 4 6 6 1 5 5 7 1 1 1 3 1 2 2 2 2 3 3 1 6 0 8 8 3 1 5 2 1 4 2 1 1 3 3 1 1 1 3 3 1 2 3 5 5 5 3 6 1 6 0 11 7 5 5 6 1 7 1 4 3 5 4 2 3 1 3 3 2 1 6 0 8 3 5 2 9 4 8 1 9 1 2 3 1 1 1 1 8 0 6 7 7 9 1 5 2 1 2 2 2 3 3 1 1 4 1 2 1 3 2 3 6 1 7 0 11 6 4 7 6 8 6 8 6 4 1 4 2 3 3 3 3 1 1 1 7 0 6 1 2 2 1 6 3 2 1 2 3 1 1 1 1 5 0 8 2 1 3 1 1 7 4 5 1 1 1 3 1 3 2 2 3 3 4 3 7 1 8 0 9 9 2 1 1 8 8 9 4 8 2 2 1 2 1 3 3 1 1 6 0 8 9 3 1 9 7 4 1 9 3 3 1 3 2 3 1 8 0 9 5 5 1 7 7 3 7 1 7 2 1 1 1 2 3 3 3 1 3 4 3 3 5 4 3 5 1 8 0 7 5 1 8 3 6 7 5 1 2 1 2 2 2 3 3 1 9 0 8 6 7 9 1 5 4 1 1 3 3 2 1 3 1 1 1 3 1 9 0 6 7 9 1 1 2 2 2 1 3 1 3 2 1 1 1 3 4 2 2 3 3 4 1 5 0 9 2 3 6 7 1 4 8 1 8 2 1 2 1 2 1 9 0 9 1 6 5 5 9 2 1 2 7 1 1 3 1 2 2 3 1 1 1 5 0 9 2 1 1 9 4 1 5 3 5 1 3 1 1 2 3 1 4 2 1 7 6 4 2 5 3 3 5 1 6 0 7 4 9 4 3 1 8 3 2 1 3 3 2 1 1 7 0 9 7 4 9 1 7 1 4 5 2 1 2 1 2 3 1 2 1 5 0 7 1 8 9 3 9 2 1 3 2 3 2 1 2 3 5 3 5 3 6 1 8 0 9 3 2 9 2 1 9 4 5 8 2 3 2 1 2 3 3 3 1 8 0 9 9 9 7 6 1 2 3 9 8 1 1 2 3 3 2 1 1 1 9 0 8 6 3 5 5 7 9 1 9 3 1 3 3 2 3 2 1 1 4 4 3 5 3 3 3 6 1 8 0 6 5 1 3 9 7 1 1 2 3 3 1 3 3 3 1 9 0 9 5 3 2 1 1 7 6 2 9 2 1 1 3 2 1 3 1 3 1 8 0 9 1 9 4 3 4 7 2 2 5 2 1 2 3 2 3 2 2 2 2 5 4 1 5 3 7 1 6 0 8 2 1 3 7 9 2 1 7 2 1 1 1 2 2 1 8 0 10 4 1 1 6 7 7 8 1 9 8 3 3 3 1 2 1 3 1 1 5 0 8 6 1 9 9 3 8 1 3 3 1 1 1 1 5 1 3 3 5 4 1 3 6 1 8 0 9 2 6 9 1 4 6 1 7 7 3 1 1 1 3 1 2 1 1 6 0 9 6 2 9 3 1 7 3 8 4 2 3 1 3 3 1 1 5 0 7 1 7 7 7 1 5 6 1 2 2 1 1 1 3 3 3 3 2 1 2 4 4 5 3 6 1 9 0 9 3 2 8 7 1 8 4 6 3 3 1 1 2 3 1 3 2 1 1 5 0 11 1 5 8 1 1 1 8 2 3 9 3 2 3 2 2 1 1 8 0 10 1 1 2 8 7 1 9 9 9 7 1 1 1 3 1 2 2 2 3 3 3 2 4 2 3 4 1 5 0 10 1 6 5 2 2 6 9 6 9 2 1 2 2 3 2 1 7 0 11 1 4 9 7 5 2 3 4 4 5 1 3 1 1 2 1 1 3 1 9 0 6 4 5 5 9 1 4 1 1 3 1 3 2 2 2 2 5 4 1 2 3 4 1 8 0 8 7 3 6 1 5 5 1 6 2 1 2 1 2 1 1 3 1 5 0 9 9 9 3 9 7 7 9 7 1 1 1 1 1 3 1 8 0 9 5 1 1 8 2 8 1 9 9 3 2 3 1 3 1 1 3 4 1 4 2 3 6 1 8 0 9 3 2 4 2 2 1 1 6 8 2 3 1 1 1 1 3 3 1 8 0 11 3 5 3 1 6 8 9 6 7 3 5 3 1 3 2 1 2 1 2 1 5 0 6 6 3 1 6 6 5 2 2 1 3 2 3 1 5 4 4 1 3 3 5 6 4 5 3 3 4 1 5 0 10 2 6 5 9 7 9 2 1 3 3 3 1 1 1 1 1 6 0 11 8 1 9 8 7 9 6 8 4 7 5 2 2 1 1 3 1 1 9 0 6 1 1 9 2 2 1 3 3 2 1 1 1 2 3 3 4 1 2 4 3 7 1 7 0 7 9 1 1 1 1 3 1 1 2 2 2 3 3 1 1 8 0 10 3 1 1 7 9 8 1 1 2 8 1 1 2 1 1 2 2 3 1 7 0 8 2 6 6 4 1 7 7 1 1 3 3 2 2 1 1 4 1 1 3 1 2 3 3 5 1 6 0 10 1 8 5 9 3 6 1 3 5 6 1 3 3 2 1 2 1 7 0 11 6 8 2 9 4 7 2 3 8 5 1 2 1 3 3 3 3 3 1 5 0 7 5 6 7 1 8 9 1 3 2 2 1 3 5 5 2 2 2 3 5 1 5 0 8 3 5 8 5 1 3 1 8 1 3 2 2 3 1 5 0 10 4 7 1 1 2 3 7 9 8 8 1 1 1 1 2 1 8 0 9 2 7 3 2 7 2 1 9 6 3 1 1 1 1 3 2 2 5 4 4 5 3 3 7 1 5 0 9 4 9 9 4 7 1 6 8 1 3 2 1 2 3 1 9 0 8 3 7 9 3 4 1 8 3 1 3 1 1 2 3 2 2 3 1 8 0 11 4 2 1 8 6 4 5 6 5 7 2 1 2 2 1 1 1 3 2 1 2 3 1 2 3 2 4 5 1 4 7 6 3 5 4 3 7 1 9 0 10 2 5 5 1 2 5 1 1 5 6 2 3 1 1 1 1 3 3 3 1 9 0 10 1 2 3 1 6 1 2 4 4 6 3 1 2 3 1 3 1 2 1 1 8 0 10 2 9 5 1 9 9 4 7 1 7 2 3 1 1 3 1 3 1 2 1 1 4 2 2 3 3 6 1 5 0 10 6 6 4 5 1 6 2 8 7 1 1 2 3 2 1 1 9 0 11 2 4 1 8 9 4 3 4 1 6 8 2 3 3 2 3 1 2 2 2 1 5 0 6 4 1 1 5 8 6 3 2 1 2 2 3 2 1 2 4 3 3 5 1 7 0 10 6 2 3 8 7 1 1 3 8 8 3 1 1 2 1 1 3 1 5 0 11 6 9 7 5 4 8 7 7 1 1 6 2 1 1 3 2 1 9 0 10 5 9 4 8 4 7 7 9 1 3 3 1 2 2 1 1 1 1 3 2 5 3 1 2 3 4 1 5 0 8 4 2 6 6 1 9 7 3 3 1 2 1 1 1 5 0 11 4 4 9 7 1 1 1 3 7 7 9 1 1 3 3 2 1 5 0 10 3 3 1 3 1 1 2 7 6 9 1 1 1 2 2 3 3 3 2 3 6 1 9 0 8 5 9 9 2 3 1 5 3 1 2 3 2 3 3 2 3 2 1 5 0 8 6 2 1 2 1 8 5 4 1 1 1 1 2 1 9 0 7 2 2 1 9 8 6 8 2 1 2 1 2 3 2 1 2 2 1 2 1 4 2 2 3 4 6 4 3 3 6 1 7 0 9 5 4 4 1 3 5 1 1 1 3 1 2 3 1 3 1 1 9 0 6 4 9 1 4 4 1 2 1 2 1 1 3 3 3 2 1 5 0 6 6 9 1 9 1 8 3 3 1 3 2 4 5 3 2 3 2 3 7 1 5 0 7 6 8 6 4 6 1 5 1 3 1 1 2 1 9 0 9 5 1 4 3 1 8 3 6 1 3 1 1 3 1 2 3 2 3 1 6 0 7 1 6 1 4 8 2 3 3 3 2 1 1 3 5 2 1 2 3 4 2 3 5 1 5 0 11 3 3 2 3 5 6 4 3 9 9 1 1 1 2 1 3 1 5 0 8 3 1 1 4 6 9 1 1 1 3 2 1 1 1 6 0 11 8 9 9 4 7 6 4 2 1 7 8 3 1 2 2 3 2 1 1 5 3 5 3 7 1 9 0 7 9 8 1 9 5 1 5 1 3 2 2 1 1 3 1 3 1 6 0 9 3 7 3 6 6 7 1 7 8 1 1 1 1 2 1 1 9 0 6 2 1 7 6 3 9 1 2 3 1 3 3 2 3 3 4 2 5 2 2 2 1 2 2 4 5 3 3 5 1 8 0 9 6 1 1 6 1 3 6 4 3 1 1 3 1 3 2 3 1 1 9 0 10 8 7 6 7 1 9 5 2 1 4 1 2 1 3 3 2 3 2 1 1 9 0 6 4 6 1 8 2 6 2 2 1 1 3 2 2 1 3 1 3 4 3 2 3 4 1 7 0 6 1 2 9 5 2 1 2 3 2 1 1 3 1 1 9 0 10 4 8 7 2 7 1 1 6 6 3 1 1 2 3 1 2 1 1 1 1 8 0 10 6 6 6 9 3 8 3 2 1 9 1 1 2 3 3 2 1 1 3 1 4 3 3 6 1 9 0 6 8 2 2 8 1 2 1 3 2 1 3 2 2 1 1 1 5 0 7 9 1 9 8 9 3 9 3 1 1 3 1 1 9 0 6 9 8 3 1 3 4 1 2 2 1 2 1 2 2 3 5 4 2 1 1 4 3 5 1 8 0 7 6 1 3 4 8 1 1 2 1 2 3 2 1 3 1 1 5 0 9 6 5 5 3 4 1 4 2 2 2 3 1 3 1 1 5 0 10 1 3 8 9 2 1 6 3 2 5 2 1 3 2 3 3 5 1 2 2 3 5 1 6 0 6 3 1 3 2 5 3 2 1 2 2 3 1 1 7 0 10 7 7 3 1 4 1 2 2 4 6 1 3 1 3 1 3 2 1 8 0 6 3 3 7 7 1 4 2 1 1 3 1 1 3 2 4 2 4 3 5 3 6 1 4 4 3 5 1 9 0 9 9 4 9 7 1 5 4 2 9 1 2 1 1 3 2 1 1 1 1 8 0 9 1 8 4 9 8 3 8 5 1 3 1 1 2 3 2 1 3 1 8 0 10 2 6 1 7 8 9 9 7 4 4 2 2 1 1 3 2 2 1 1 5 3 5 1 3 5 1 8 0 7 1 5 8 9 9 8 4 1 2 1 1 2 2 2 3 1 5 0 6 5 5 8 6 5 1 2 1 1 2 2 1 6 0 8 7 9 1 4 3 1 1 9 2 1 3 2 2 3 5 3 5 4 3 3 6 1 9 0 6 7 1 6 3 9 3 3 3 3 1 2 1 2 1 1 1 9 0 7 1 1 8 6 3 2 8 1 1 3 1 3 3 3 3 3 1 7 0 7 1 1 9 9 1 5 1 2 1 3 1 3 1 3 1 4 2 3 5 5 3 4 1 5 0 7 5 1 9 1 1 4 7 1 1 2 3 1 1 5 0 7 9 3 1 7 5 4 7 2 1 1 3 3 1 7 0 8 6 3 7 4 2 7 1 6 1 1 1 1 1 1 1 2 3 1 2 1 4 2 5 4 5 3 5 1 8 0 6 2 7 1 1 7 4 1 1 3 2 1 1 1 1 1 5 0 6 4 3 1 1 4 3 1 2 3 1 1 1 5 0 9 5 9 1 5 5 1 6 4 1 3 2 3 3 1 1 4 5 3 5 3 5 1 6 0 7 4 3 4 8 1 6 1 1 1 3 2 2 3 1 5 0 8 1 3 7 8 5 9 1 5 2 1 1 2 3 1 6 0 6 9 7 1 4 4 7 3 3 1 1 1 2 1 4 2 1 1 3 4 1 8 0 7 6 1 7 1 7 9 5 2 1 3 2 2 1 3 3 1 6 0 8 3 7 2 9 1 2 5 2 1 2 1 1 1 2 1 5 0 7 1 1 4 2 5 2 4 1 2 3 3 3 2 4 3 1 3 5 1 6 0 11 8 8 1 7 2 8 1 9 6 6 9 1 1 1 2 2 2 1 8 0 9 1 3 8 7 8 3 7 6 7 2 1 3 2 1 3 2 3 1 6 0 10 1 1 6 1 8 9 1 3 8 5 3 3 3 3 1 2 5 2 1 2 1 2 1 3 2 6 5 4 3 6 1 8 0 11 8 7 1 4 4 5 6 9 5 7 8 3 3 2 2 3 3 1 1 1 7 0 7 1 9 8 1 8 7 7 2 1 2 1 3 3 2 1 6 0 8 6 5 3 1 8 5 6 2 1 3 3 2 1 2 2 3 2 3 2 5 3 5 1 7 0 9 3 4 9 5 6 1 2 3 7 3 2 1 2 2 1 1 1 7 0 6 3 2 8 6 1 9 3 1 2 3 1 3 3 1 7 0 8 8 9 1 3 1 3 3 3 2 1 2 3 1 2 2 2 5 3 4 5 3 7 1 9 0 7 5 4 9 1 1 3 9 1 3 1 2 2 2 3 3 1 1 8 0 11 3 1 4 6 1 4 2 6 6 3 1 3 3 2 1 1 2 3 3 1 7 0 6 6 6 6 5 8 1 3 3 1 3 2 1 3 5 3 4 1 3 1 1 3 5 1 8 0 9 3 7 2 9 2 6 3 1 2 1 2 2 1 1 3 1 2 1 9 0 8 2 7 6 1 4 5 1 3 1 1 2 2 2 1 2 1 3 1 7 0 10 2 3 7 3 3 8 3 1 1 1 3 1 2 2 3 1 1 4 2 1 1 2 3 4 1 5 0 6 2 4 5 1 5 1 2 2 1 2 2 1 7 0 10 1 3 1 9 1 7 8 4 7 8 2 1 1 3 3 1 1 1 9 0 6 5 1 1 8 4 1 1 3 1 1 2 3 1 1 2 4 3 5 2 1 6 6 2 3 2 6 6 2 5 5 3 5 1 5 0 11 1 2 9 5 6 8 2 2 7 6 2 2 1 3 2 3 1 6 0 9 4 3 8 6 4 1 9 3 3 1 1 1 2 2 3 1 6 0 11 4 8 6 2 9 9 4 1 4 7 8 3 1 3 3 2 2 3 3 3 1 2 3 5 1 8 0 8 8 5 6 1 4 8 2 5 1 2 2 1 3 3 2 1 1 7 0 6 1 2 1 4 3 6 2 3 2 3 1 3 3 1 6 0 11 4 7 1 6 5 1 7 9 9 5 5 1 3 2 3 1 1 3 2 3 3 4 3 5 1 7 0 11 2 5 7 2 2 8 3 7 5 1 7 3 1 3 2 1 1 1 1 5 0 8 8 1 4 9 9 8 2 9 3 1 3 1 1 1 6 0 8 7 4 1 8 7 6 7 7 3 3 3 2 2 1 2 3 3 3 4 3 6 1 5 0 8 5 6 1 5 9 7 8 5 1 3 2 3 1 1 9 0 10 1 8 2 6 7 1 2 3 8 1 3 1 1 2 3 3 1 1 1 1 7 0 8 8 2 2 7 1 3 5 1 2 3 1 2 1 3 2 3 4 5 5 3 1 3 5 1 5 0 9 1 5 8 1 3 7 5 1 9 1 2 2 3 2 1 7 0 7 4 6 1 9 1 3 7 3 3 1 3 3 1 1 1 5 0 6 8 1 1 7 1 7 3 1 1 1 1 2 1 2 2 5 4 5 4 7 6 4 5 3 6 1 5 0 7 1 1 6 8 3 1 4 2 2 1 1 2 1 8 0 9 4 5 2 7 1 1 1 1 6 2 3 3 3 2 1 3 1 1 9 0 10 4 8 1 3 2 5 4 4 1 8 3 2 1 3 2 2 1 2 3 5 1 5 1 5 1 3 5 1 7 0 8 4 9 8 8 1 4 8 6 2 3 2 3 1 3 1 1 9 0 8 5 6 9 5 9 3 3 1 1 1 2 1 2 2 1 1 1 1 7 0 6 8 4 3 1 9 7 3 2 3 2 1 3 3 5 4 4 2 3 3 6 1 8 0 6 6 7 1 2 3 6 1 1 2 2 1 2 1 2 1 5 0 8 4 7 2 5 4 1 9 1 1 3 3 1 2 1 6 0 11 3 4 4 1 8 9 3 4 9 4 4 2 1 3 1 1 3 5 3 2 2 2 3 3 5 1 6 0 9 9 9 7 6 7 8 8 1 1 1 1 1 2 3 2 1 5 0 9 1 5 6 6 6 9 7 9 1 2 2 3 1 1 1 7 0 9 3 3 1 5 2 9 7 3 4 3 3 2 1 1 2 1 2 1 3 5 1 6 1 5 4 3 5 3 3 4 1 7 0 9 1 1 4 5 2 3 9 2 3 3 1 3 2 1 1 1 1 8 0 7 1 1 1 3 2 4 9 2 1 2 1 2 3 2 3 1 9 0 7 5 1 2 5 8 9 9 3 3 1 3 1 2 1 2 1 3 4 5 1 3 4 1 7 0 11 3 2 2 3 5 7 1 4 2 6 9 1 3 1 1 3 1 1 1 5 0 7 6 4 8 2 9 3 1 2 1 3 3 1 1 7 0 11 3 9 6 9 9 5 9 7 1 3 4 2 1 1 1 1 2 1 2 2 5 2 3 6 1 5 0 11 4 9 6 8 8 1 9 1 8 8 3 1 3 2 1 3 1 6 0 8 9 9 5 8 9 1 3 1 3 1 1 1 1 3 1 9 0 6 8 4 2 6 1 3 2 2 2 1 2 1 1 1 1 2 5 4 4 1 3 3 6 1 8 0 6 9 1 5 2 4 9 2 1 2 3 1 1 3 3 1 6 0 10 1 2 5 6 8 9 2 1 3 4 2 1 1 1 2 2 1 7 0 11 4 6 4 6 9 1 8 6 9 5 9 2 3 1 2 1 1 3 3 1 5 1 1 4 3 6 1 8 0 8 3 6 1 7 5 9 5 2 2 3 3 1 2 2 2 1 1 9 0 10 8 5 9 4 1 9 1 8 9 8 1 2 2 2 3 1 1 3 3 1 8 0 6 1 4 8 7 1 1 3 1 1 3 2 3 1 1 1 3 2 1 2 2 2 4 4 5 3 3 6 1 6 0 9 1 2 9 4 6 6 8 5 5 1 2 1 3 1 3 1 8 0 8 8 9 4 1 6 7 3 6 3 2 1 3 1 2 1 1 1 5 0 8 1 6 9 6 1 1 1 1 3 3 3 1 3 1 2 1 3 3 4 3 6 1 5 0 10 7 5 5 6 8 1 4 1 8 9 2 1 1 3 1 1 5 0 6 7 1 3 8 4 8 1 1 1 1 3 1 5 0 10 5 8 4 1 4 2 7 1 6 3 3 1 1 2 3 1 4 3 3 3 1 3 4 1 8 0 10 3 3 8 8 4 1 4 5 5 1 1 2 1 1 2 3 2 1 1 8 0 10 9 6 6 7 6 1 9 8 2 4 1 2 2 2 2 2 3 1 1 8 0 6 1 5 9 2 1 4 3 2 1 2 1 1 2 3 2 2 5 5 3 5 1 5 0 9 2 6 5 7 6 1 7 7 3 1 2 1 1 1 1 7 0 7 6 1 1 3 1 1 4 3 3 1 1 1 2 3 1 7 0 10 7 2 6 9 1 7 1 4 5 4 1 1 1 1 2 3 1 3 3 4 5 4 3 7 1 7 0 9 5 9 2 6 9 2 5 1 5 1 1 1 1 2 2 2 1 9 0 6 8 7 3 9 1 9 1 1 2 3 2 3 3 1 3 1 8 0 11 1 1 9 3 8 9 7 7 7 5 6 2 3 1 2 1 1 1 3 1 3 5 5 2 5 2 2 1 5 4 3 3 4 1 6 0 6 5 1 7 8 9 6 1 2 2 2 3 2 1 5 0 7 2 3 1 6 3 1 1 2 2 1 1 2 1 8 0 11 8 9 8 5 6 5 1 1 8 8 5 2 1 1 2 2 3 3 1 3 4 2 2 3 7 1 5 0 11 6 8 3 3 4 6 8 2 7 1 9 1 3 1 2 1 1 9 0 11 6 5 7 1 1 7 1 4 5 6 7 3 1 1 3 2 2 1 1 1 1 5 0 6 6 2 1 9 6 9 3 2 1 1 2 2 2 3 3 1 2 1 3 6 1 6 0 6 7 2 2 1 5 9 1 2 1 3 3 3 1 7 0 9 6 2 4 3 6 9 4 1 5 3 1 1 1 2 2 3 1 5 0 7 4 4 7 4 1 1 9 2 3 1 3 1 5 1 5 3 2 3 3 7 1 6 0 6 1 2 9 4 4 3 1 2 1 1 1 3 1 5 0 7 1 7 6 1 9 6 6 3 3 2 1 1 1 5 0 10 9 1 5 8 6 4 8 1 1 1 1 2 1 1 3 5 2 2 4 3 1 5 5 6 1 5 4 3 6 1 8 0 6 2 8 2 3 4 1 1 1 1 1 1 2 3 2 1 7 0 11 1 4 5 1 1 7 5 3 6 5 4 1 2 1 2 3 3 3 1 8 0 10 5 6 1 1 6 8 1 9 7 3 1 1 3 1 3 1 2 2 5 2 2 2 3 1 3 4 1 6 0 9 2 8 3 5 4 2 6 5 1 1 1 2 1 3 2 1 9 0 11 7 9 9 8 8 6 6 6 2 1 5 2 3 1 3 2 3 1 2 3 1 7 0 10 7 1 5 1 5 1 7 6 1 9 1 2 2 2 3 2 1 1 4 3 3 3 5 1 5 0 6 2 6 1 8 6 8 2 2 1 3 2 1 7 0 7 1 9 8 5 8 2 7 3 3 2 1 3 2 1 1 5 0 10 5 5 4 1 1 3 8 4 4 8 2 2 1 1 1 4 2 1 1 2 3 6 1 5 0 9 3 9 1 3 7 2 2 8 3 2 1 3 2 1 1 5 0 11 1 5 9 1 4 1 5 1 4 1 8 2 2 3 1 1 1 6 0 7 9 5 8 1 1 5 3 2 2 1 1 3 3 5 3 1 3 5 2 3 7 1 5 0 9 1 9 7 9 8 9 8 6 3 2 2 2 1 1 1 5 0 10 1 6 6 3 4 7 2 3 9 3 2 2 2 2 1 1 8 0 11 4 6 5 5 1 6 2 1 3 8 9 1 1 3 1 3 1 2 2 2 5 3 2 5 2 3 2 6 3 1 4 7 7 2 5 3 3 4 1 7 0 9 9 8 6 1 9 1 1 5 2 2 3 1 2 3 2 1 1 7 0 7 2 5 9 1 3 1 1 1 2 1 1 2 3 2 1 9 0 7 9 5 2 1 7 4 4 2 2 1 3 2 1 1 3 1 2 3 5 4 3 7 1 8 0 10 3 4 1 9 9 1 5 7 9 7 3 2 3 3 1 3 3 2 1 5 0 11 2 7 3 1 3 3 6 9 9 1 8 1 1 1 1 2 1 5 0 8 5 7 1 5 9 2 3 5 3 1 1 2 1 5 3 1 1 1 3 3 3 5 1 7 0 9 7 1 2 4 1 9 4 1 6 3 1 1 2 3 1 1 1 5 0 7 1 4 9 7 2 2 9 1 2 3 1 1 1 6 0 6 3 8 3 1 5 2 1 2 3 2 2 1 2 3 2 5 1 3 5 1 6 0 7 1 2 7 7 5 6 7 3 1 3 1 2 3 1 7 0 11 1 4 1 2 8 5 4 1 5 6 3 1 2 1 1 2 3 1 1 6 0 7 1 3 6 4 7 2 6 1 3 2 1 1 3 1 3 4 1 3 3 5 1 6 0 8 5 1 9 1 1 8 2 3 1 1 3 1 2 1 1 5 0 6 1 9 1 1 5 7 1 3 1 2 2 1 7 0 7 2 6 1 5 1 9 5 2 1 1 2 1 1 2 2 5 2 2 5 1 4 1 4 4 3 4 1 7 0 9 5 1 5 5 2 2 4 7 9 3 1 1 2 3 3 3 1 6 0 7 9 5 1 3 9 9 7 1 2 1 1 3 3 1 9 0 8 1 6 1 1 4 4 1 5 1 1 3 3 3 3 1 2 3 2 5 3 2 3 5 1 6 0 11 8 9 4 1 1 8 6 2 9 7 3 2 2 3 2 1 3 1 7 0 9 1 5 8 5 9 1 4 1 6 1 2 2 3 1 1 2 1 6 0 6 6 9 3 8 1 2 3 2 1 1 2 1 4 5 3 5 5 3 7 1 8 0 6 1 4 2 3 7 4 2 1 2 1 1 2 2 2 1 9 0 7 1 1 1 6 8 1 2 1 1 3 1 1 1 1 1 2 1 5 0 8 5 1 3 5 8 1 7 8 3 1 2 3 2 4 3 1 3 5 5 1 3 5 1 5 0 7 4 8 7 1 5 1 1 3 1 3 2 2 1 7 0 7 8 1 1 4 7 1 8 3 1 3 3 1 3 2 1 6 0 11 7 8 4 2 8 8 6 7 6 1 1 2 1 1 1 1 2 5 3 3 2 1 3 3 3 4 4 5 3 5 1 5 0 10 4 7 3 6 4 1 5 6 4 5 3 1 1 1 1 1 6 0 7 2 7 7 4 4 9 1 2 2 1 1 2 2 1 9 0 8 2 7 1 3 9 9 1 2 3 2 3 1 1 2 1 3 3 4 3 3 3 2 3 4 1 5 0 10 5 1 1 6 3 9 5 5 7 3 1 3 3 2 2 1 6 0 7 2 4 9 2 1 4 7 1 3 1 1 2 2 1 6 0 11 8 2 9 6 7 6 1 1 3 6 5 3 2 1 1 1 3 1 5 2 3 3 6 1 7 0 9 3 7 4 1 8 6 5 3 4 2 2 2 1 1 1 1 1 8 0 8 9 2 4 1 3 8 4 9 1 2 2 1 3 2 1 3 1 6 0 11 4 1 1 6 5 5 7 1 8 3 6 1 1 1 1 3 3 5 2 4 4 5 2 3 5 1 6 0 11 4 7 6 1 2 6 6 2 7 8 3 2 2 1 1 1 1 1 8 0 7 1 4 5 8 2 3 4 2 3 3 2 2 1 2 2 1 6 0 11 4 1 9 6 3 3 1 9 3 6 4 3 1 2 1 1 1 2 3 4 4 3 3 5 2 1 2 4 4 3 7 1 6 0 11 5 5 3 1 6 6 7 3 8 1 8 2 2 3 3 3 1 1 5 0 6 9 1 1 5 4 1 2 3 1 3 2 1 7 0 10 5 1 5 3 2 7 6 7 7 7 2 3 2 2 1 1 2 1 4 1 5 1 3 1 3 7 1 5 0 11 2 5 7 8 4 7 9 1 5 3 9 1 1 2 1 2 1 7 0 11 8 1 1 9 5 1 2 7 5 1 2 3 2 1 1 1 1 1 1 8 0 7 5 9 4 3 7 8 1 1 3 2 3 3 1 3 1 2 3 1 3 4 3 4 3 6 1 6 0 6 6 2 4 6 1 3 2 1 1 3 3 1 1 5 0 9 6 8 7 7 1 7 1 2 5 1 1 2 3 1 1 8 0 7 4 5 6 1 3 6 8 2 2 2 2 1 2 2 1 1 4 3 5 3 5 3 7 1 8 0 9 9 2 1 4 1 9 9 7 5 3 2 2 3 2 1 3 1 1 7 0 10 8 1 1 3 7 5 1 7 9 4 2 1 3 2 2 3 2 1 7 0 11 9 1 4 7 3 2 3 8 8 8 1 2 2 1 1 3 2 1 1 3 2 4 5 4 1 2 5 4 5 4 4 3 6 1 9 0 11 5 3 7 6 3 1 3 8 5 5 4 1 2 3 3 2 1 1 1 3 1 8 0 10 4 5 7 7 8 9 6 1 7 3 1 1 1 3 3 2 1 3 1 6 0 6 1 6 6 6 7 3 3 3 2 1 3 3 3 5 3 5 5 4 3 6 1 5 0 7 3 8 5 7 2 1 1 3 2 1 3 2 1 7 0 10 3 9 5 1 3 9 5 8 6 6 1 1 2 1 2 1 1 1 9 0 7 2 1 3 2 4 8 7 2 2 3 1 3 3 3 2 1 4 3 3 1 2 5 3 7 1 7 0 8 6 7 2 1 4 7 8 4 3 3 2 2 1 1 2 1 9 0 6 9 4 7 1 6 1 3 2 3 1 3 3 2 2 1 1 7 0 6 6 2 1 9 2 9 3 3 1 1 3 2 3 3 1 5 1 3 1 3 3 6 1 7 0 7 7 5 8 3 5 1 2 1 2 1 1 3 1 1 1 9 0 6 5 1 1 8 4 8 1 1 1 1 2 2 3 2 3 1 9 0 11 9 9 5 5 1 4 1 1 6 7 2 3 3 1 2 2 2 1 3 1 2 4 1 1 2 2 3 4 3 1 5 3 3 6 1 9 0 11 6 4 6 9 4 1 5 6 2 6 4 1 1 2 3 1 3 3 2 3 1 7 0 9 6 7 1 6 8 2 5 9 2 2 2 1 3 1 1 3 1 8 0 7 1 3 3 4 5 7 1 2 3 1 1 1 1 1 3 5 3 4 5 3 1 3 7 1 9 0 9 6 5 7 1 3 1 7 1 6 1 2 1 1 1 2 3 1 1 1 5 0 9 4 7 4 3 2 1 6 4 5 1 3 2 1 2 1 5 0 7 2 8 2 8 1 5 2 1 3 1 1 1 3 3 4 3 1 3 4 3 6 1 7 0 7 1 9 8 8 7 5 4 1 2 2 3 1 2 1 1 7 0 6 8 1 3 4 6 1 1 3 3 1 1 2 1 1 5 0 9 4 1 1 7 3 4 1 6 5 1 2 3 2 1 2 1 5 3 4 2 3 4 1 7 0 10 8 2 1 7 8 9 2 1 6 9 2 2 1 1 2 1 2 1 7 0 6 1 6 3 6 8 1 2 2 1 1 2 1 1 1 6 0 10 9 1 1 1 7 4 9 6 2 5 2 3 1 2 1 3 3 2 1 1 3 6 1 7 0 7 1 5 5 3 6 3 9 2 1 2 2 3 1 1 1 7 0 10 4 6 8 3 1 8 9 3 1 4 2 3 2 2 1 1 3 1 8 0 10 9 6 8 5 4 1 2 3 1 4 3 1 1 1 1 3 3 3 1 2 5 2 2 2 7 1 2 4 5 3 7 1 6 0 6 9 9 9 1 3 9 3 3 2 2 2 1 1 6 0 11 9 7 9 9 7 9 1 1 1 1 1 3 1 3 1 2 1 1 7 0 6 3 7 9 5 4 1 2 3 1 3 3 1 1 1 3 3 5 3 5 5 3 5 1 8 0 11 1 2 5 7 1 3 6 6 2 3 8 3 2 1 1 3 2 3 1 1 5 0 11 1 5 3 3 8 2 5 1 6 7 3 3 3 2 1 1 1 8 0 10 1 8 2 9 7 9 1 1 2 7 1 3 3 1 1 1 3 3 2 2 4 1 3 3 4 1 9 0 9 1 9 3 9 1 5 3 8 6 1 1 2 3 2 3 1 3 3 1 9 0 7 7 2 2 2 6 1 6 1 2 1 1 1 2 1 2 1 1 9 0 6 6 1 8 3 4 2 3 1 2 3 2 1 3 2 2 3 1 3 3 3 7 1 5 0 10 3 3 3 3 3 1 6 7 9 4 3 1 3 3 1 1 8 0 6 5 6 1 1 3 1 2 3 2 2 1 1 3 3 1 6 0 8 1 2 7 2 1 9 3 1 1 2 2 3 1 1 3 4 2 3 4 4 4 3 3 3 3 2 9 6 6 3 5 5 3 6 1 9 0 10 8 4 3 1 2 4 3 3 8 3 2 2 2 3 1 2 1 3 3 1 5 0 6 1 7 9 2 9 1 3 1 2 2 1 1 9 0 10 4 1 2 8 2 5 5 2 7 9 1 3 2 2 2 3 1 2 2 4 3 1 3 3 4 3 7 1 9 0 8 2 3 7 7 1 3 9 5 1 2 1 1 2 3 3 1 2 1 5 0 9 7 1 6 1 5 2 2 1 3 3 1 3 2 1 1 9 0 8 1 4 5 9 1 1 3 1 1 1 1 2 3 1 3 2 1 2 4 1 2 4 4 2 3 5 1 9 0 11 8 1 5 5 4 8 1 2 6 1 9 1 3 3 3 3 1 2 3 1 1 9 0 7 9 7 2 4 5 1 4 3 1 2 1 3 2 3 1 1 1 5 0 9 1 2 4 2 5 1 9 7 5 1 2 1 1 2 4 4 5 2 3 3 5 1 6 0 8 2 4 1 1 8 2 6 8 1 2 1 2 1 2 1 7 0 9 8 1 5 8 1 4 5 4 5 1 2 3 3 2 1 2 1 8 0 10 5 9 1 3 1 1 6 9 8 4 3 1 1 3 3 2 1 3 1 2 5 2 2 3 4 1 9 0 11 4 4 2 1 8 1 7 5 8 2 7 1 1 1 2 1 1 3 2 1 1 5 0 11 8 2 9 1 5 2 9 2 8 1 7 3 1 1 1 2 1 9 0 11 9 3 3 3 1 6 2 7 4 8 3 3 1 2 2 1 1 2 2 2 2 2 1 3 2 1 5 2 5 4 3 3 7 1 5 0 6 5 2 1 2 1 7 1 2 2 1 1 1 5 0 8 8 3 5 9 1 1 9 1 3 3 1 1 1 1 9 0 6 1 4 1 9 3 3 2 3 3 1 3 3 3 1 2 3 2 5 2 1 1 4 3 6 1 7 0 9 2 1 4 7 7 5 1 2 1 2 1 1 3 2 3 3 1 8 0 7 1 4 8 8 1 2 3 1 1 3 1 1 1 3 1 1 8 0 9 1 4 6 3 9 9 3 3 7 1 1 3 1 1 3 3 2 1 3 2 4 2 5 3 6 1 8 0 11 6 9 1 3 3 2 1 7 1 8 2 3 3 1 3 2 2 2 1 1 6 0 10 5 4 6 4 6 9 2 2 1 2 3 1 1 2 2 2 1 6 0 9 1 5 2 2 8 2 6 4 1 1 1 1 1 3 1 1 2 5 2 5 1 3 6 1 9 0 8 3 9 9 2 1 6 2 7 2 1 1 1 2 3 1 3 2 1 6 0 10 2 9 9 6 9 5 8 1 6 8 1 1 3 3 1 2 1 7 0 11 4 2 2 8 1 1 3 7 1 8 7 1 1 3 3 3 2 2 1 1 4 4 1 3 6 2 6 4 5 3 6 1 7 0 9 5 6 7 1 5 6 3 2 6 3 1 3 2 1 3 2 1 8 0 10 4 3 4 3 8 2 2 4 1 1 2 2 3 1 2 3 1 1 1 6 0 6 7 4 1 9 3 6 3 3 2 3 1 2 2 4 4 5 2 4 3 6 1 8 0 11 8 8 7 2 3 5 1 7 3 1 3 2 2 2 1 2 3 3 3 1 8 0 7 4 6 9 3 6 1 2 2 1 2 3 2 2 3 1 1 9 0 9 6 8 1 3 1 1 5 5 3 1 1 1 3 3 1 3 3 1 5 3 5 4 4 3 3 5 1 8 0 10 2 6 6 5 1 3 4 6 6 6 1 3 1 2 2 3 3 2 1 5 0 8 2 6 6 5 1 9 4 7 1 1 1 3 3 1 8 0 9 1 5 2 4 3 3 1 5 2 2 3 2 2 1 2 3 1 2 4 5 2 3 3 7 1 9 0 8 8 1 5 4 1 3 5 8 1 3 1 2 2 2 1 3 1 1 9 0 8 6 4 4 3 1 9 1 7 2 1 2 3 1 1 2 2 3 1 5 0 6 4 3 1 7 1 3 2 3 1 2 3 2 5 1 3 4 1 3 5 3 3 4 2 5 5 3 7 1 8 0 9 3 8 3 3 8 7 2 3 1 1 3 1 3 1 1 3 2 1 6 0 7 3 1 3 5 9 4 2 3 3 2 1 2 1 1 6 0 6 3 2 8 1 3 5 2 1 1 3 2 1 3 2 4 5 3 1 5 3 4 1 7 0 6 2 1 3 9 6 8 2 1 3 2 1 3 3 1 9 0 6 9 9 8 6 1 6 1 1 2 1 2 3 1 1 3 1 6 0 9 5 4 1 2 7 2 1 2 1 1 3 1 1 1 3 4 5 1 4 3 5 1 9 0 7 3 4 3 8 1 1 5 2 1 1 1 1 3 2 3 1 1 9 0 7 4 4 1 8 3 1 2 3 3 1 2 1 3 1 1 1 1 7 0 11 5 4 5 4 7 2 8 1 1 2 4 3 3 1 2 3 2 2 3 5 3 5 2 3 4 1 6 0 6 3 1 2 6 9 1 1 2 2 1 2 3 1 5 0 9 8 2 6 7 8 3 1 7 1 2 2 1 3 2 1 5 0 10 3 1 1 8 4 5 1 4 5 2 1 1 1 3 2 3 1 2 5 3 5 1 5 0 11 4 6 1 8 8 1 6 5 3 8 2 1 1 3 1 1 1 5 0 10 1 5 1 1 5 1 1 7 7 9 3 3 1 1 1 1 6 0 7 9 4 6 1 9 8 9 2 3 2 3 1 3 2 1 1 1 4 1 7 6 5 6 5 5 3 7 1 8 0 7 1 9 6 1 4 6 7 1 3 2 3 2 2 3 2 1 7 0 6 9 6 5 6 1 1 1 1 2 3 3 2 1 1 6 0 11 1 7 1 9 8 4 2 4 3 9 9 3 3 3 1 2 3 3 3 2 3 5 1 4 3 4 1 7 0 8 9 1 7 2 5 8 9 5 1 2 2 2 1 2 3 1 9 0 9 6 1 9 4 7 2 5 4 2 3 2 3 1 3 1 2 1 3 1 5 0 10 4 7 7 4 2 1 4 1 9 9 1 3 2 1 2 3 1 3 4 3 5 1 8 0 8 4 1 7 6 2 8 9 3 1 1 1 1 1 1 2 3 1 6 0 8 8 2 9 9 4 1 1 1 1 2 1 1 1 1 1 8 0 6 4 7 1 8 1 8 1 3 2 3 1 2 1 1 3 2 3 4 2 3 4 1 6 0 10 7 1 4 2 3 1 1 8 4 4 1 1 3 2 1 1 1 8 0 10 7 9 4 7 7 1 8 8 1 2 3 1 1 3 3 2 3 1 1 5 0 9 4 1 9 1 6 9 9 2 6 2 3 3 1 1 1 3 1 4 3 5 1 7 0 9 9 3 8 3 8 1 1 1 6 1 1 1 3 1 1 1 1 7 0 11 3 6 5 3 1 4 6 9 9 6 1 2 1 3 2 3 1 1 1 9 0 6 1 3 3 9 6 1 2 2 1 3 1 3 2 2 3 5 2 1 2 3 3 1 1 5 3 5 5 3 4 1 5 0 11 7 1 8 3 8 4 1 4 3 1 1 3 2 1 3 3 1 8 0 10 4 5 4 9 1 6 4 5 1 1 1 2 2 1 1 1 2 3 1 5 0 10 3 1 4 9 3 7 6 7 1 3 3 1 1 1 1 2 2 3 4 3 5 1 6 0 10 1 4 4 4 7 4 8 5 1 9 1 2 1 2 1 1 1 9 0 11 4 3 4 1 5 6 1 1 5 1 7 1 3 2 1 3 2 1 3 3 1 6 0 8 1 3 3 5 6 1 4 3 1 2 1 1 1 3 3 4 4 4 4 3 6 1 9 0 10 1 4 2 5 2 6 8 3 3 8 3 1 2 1 2 1 2 2 2 1 9 0 7 1 1 9 3 3 1 2 2 3 1 2 3 2 3 1 3 1 9 0 8 3 3 5 1 5 7 3 8 1 2 1 1 3 2 2 2 1 4 1 5 4 5 3 3 5 1 5 0 6 9 1 6 5 1 7 1 1 3 2 1 1 9 0 11 1 9 8 5 3 7 2 3 4 6 4 1 2 1 1 2 2 3 3 2 1 7 0 7 1 9 7 6 1 3 6 1 1 1 1 1 3 3 4 3 4 2 2 3 4 1 9 0 10 3 5 2 3 6 7 8 9 1 7 2 1 2 3 3 2 3 1 2 1 8 0 8 4 1 2 4 5 1 2 5 1 1 3 2 1 1 3 2 1 8 0 6 1 3 3 5 1 1 3 1 1 3 3 1 2 2 5 4 2 1 5 5 2 5 6 6 4 2 7 2 4 5 3 7 1 6 0 8 1 1 4 1 1 9 2 8 1 1 2 2 1 3 1 6 0 7 1 7 7 6 8 5 9 2 3 1 2 1 1 1 6 0 8 2 6 5 4 1 4 2 1 1 1 2 1 3 1 4 1 2 2 1 1 1 3 6 1 8 0 9 1 9 5 7 6 4 3 2 1 3 2 1 1 2 2 1 1 1 9 0 6 6 5 3 9 1 1 1 3 1 3 3 1 2 1 3 1 6 0 10 6 8 1 9 5 8 4 4 2 1 2 1 1 1 3 2 3 1 1 3 4 2 3 5 1 8 0 11 5 2 8 1 5 4 8 1 3 1 3 3 2 1 2 2 1 3 3 1 6 0 6 1 2 7 6 1 6 2 2 1 1 1 3 1 9 0 9 4 8 5 3 1 8 6 1 7 1 3 3 2 3 2 1 3 1 3 2 1 4 1 3 5 1 7 0 10 7 5 6 5 4 2 1 9 9 5 1 1 3 1 3 3 1 1 9 0 7 3 5 6 9 1 4 1 1 1 2 1 2 3 2 1 3 1 8 0 6 7 5 1 1 9 9 1 2 2 1 2 2 2 1 2 4 5 1 4 2 5 4 1 3 4 3 3 5 1 7 0 6 1 4 7 8 2 2 1 1 3 2 2 3 3 1 6 0 8 1 6 5 3 6 4 1 8 1 1 3 2 3 1 1 7 0 10 3 1 7 5 6 1 1 2 2 6 3 1 3 1 1 2 2 3 3 5 5 5 3 7 1 7 0 11 2 1 7 5 6 1 1 3 2 3 5 1 2 2 1 2 3 2 1 5 0 10 5 8 5 9 3 6 1 3 5 1 3 1 1 3 2 1 8 0 8 1 9 5 2 4 7 1 5 1 2 1 2 3 1 2 2 4 5 2 5 4 2 2 3 4 1 9 0 11 2 1 1 9 8 1 1 1 9 1 1 2 1 1 3 1 3 1 1 2 1 9 0 8 9 8 2 1 2 6 5 2 3 3 3 1 1 3 2 3 1 1 5 0 10 9 4 9 2 6 1 7 6 9 8 3 1 1 3 1 1 5 2 3 3 4 1 8 0 8 8 7 3 7 1 3 1 7 1 3 3 1 3 1 3 1 1 7 0 11 3 5 9 8 1 3 1 1 8 3 6 2 2 3 1 2 1 1 1 5 0 10 9 2 3 8 3 3 1 4 3 1 2 1 1 2 3 3 5 1 1 3 4 4 4 3 3 4 1 8 0 9 6 1 9 2 2 7 2 5 9 3 3 1 3 1 3 2 2 1 6 0 11 7 1 6 2 5 4 6 3 5 3 3 3 3 3 2 2 1 1 7 0 9 7 3 8 2 1 7 2 7 6 1 2 2 3 2 3 2 3 2 4 3 3 6 1 8 0 11 9 1 8 4 7 9 5 4 6 2 4 1 2 1 2 2 2 2 1 1 5 0 9 6 7 6 9 2 2 1 6 9 3 1 3 2 2 1 9 0 8 3 1 5 5 1 6 4 9 3 1 2 1 1 2 1 2 1 2 2 2 5 2 1 3 5 1 5 0 9 1 2 2 6 6 8 5 1 2 1 2 3 3 1 1 8 0 6 4 8 1 7 1 8 2 1 1 3 2 2 1 2 1 8 0 9 9 8 3 4 2 6 8 1 8 1 3 3 1 2 2 3 1 1 2 1 4 5 3 4 1 6 0 11 1 3 4 1 5 8 5 8 8 1 8 3 1 3 1 2 2 1 7 0 8 3 8 1 8 7 7 6 7 1 1 2 1 1 2 3 1 7 0 10 3 5 6 1 5 9 3 9 8 1 1 1 3 3 2 3 1 1 5 5 2 3 1 1 5 5 3 5 1 5 0 9 7 5 1 4 1 1 7 1 1 1 2 1 3 3 1 9 0 7 1 3 2 5 4 3 7 1 2 2 3 2 1 3 1 3 1 5 0 9 1 1 3 9 8 8 1 5 1 1 1 3 1 2 1 2 4 3 5 3 4 1 5 0 7 3 1 1 5 3 9 6 1 1 1 1 1 1 5 0 7 1 7 4 4 1 8 5 3 1 3 2 2 1 8 0 11 8 1 8 6 7 6 2 1 9 1 1 2 1 3 1 1 1 3 1 4 2 1 2 3 6 1 6 0 8 7 3 8 3 7 7 1 9 2 1 2 1 3 1 1 8 0 8 4 5 4 8 2 1 6 8 3 1 1 2 3 2 1 1 1 6 0 8 7 5 9 1 6 9 3 7 2 3 3 2 1 1 3 3 3 1 2 2 3 7 1 7 0 10 2 3 5 3 4 1 1 5 3 1 1 2 3 3 3 2 1 1 8 0 7 8 1 4 7 3 1 4 3 2 3 1 1 2 1 3 1 7 0 9 6 3 1 9 8 1 2 2 7 3 1 3 2 1 1 2 3 3 4 5 2 2 1 3 6 1 5 0 7 6 9 1 3 3 3 1 2 1 1 3 3 1 5 0 7 4 1 4 3 8 4 3 3 2 1 3 1 1 8 0 9 9 9 1 7 6 7 4 3 7 1 2 2 2 1 1 3 1 3 5 4 4 1 3 5 3 7 6 7 5 5 3 5 1 7 0 8 5 3 1 3 2 6 9 6 1 2 3 3 3 3 1 1 5 0 9 6 7 2 9 1 6 7 6 9 2 2 1 1 3 1 5 0 6 9 4 9 1 4 6 3 2 3 1 1 3 4 4 1 3 3 5 1 5 0 11 1 5 4 1 9 9 4 2 6 8 1 3 1 2 3 1 1 5 0 10 1 2 4 7 2 3 7 8 2 1 1 3 3 1 1 1 5 0 10 3 5 4 1 8 1 3 1 4 7 1 3 1 1 1 2 2 5 5 2 3 7 1 8 0 11 3 7 9 1 5 1 1 4 6 7 6 3 2 2 3 1 1 3 2 1 8 0 9 7 5 3 9 2 7 6 1 2 2 3 2 3 3 3 1 1 1 9 0 10 7 1 1 1 9 1 5 4 8 1 1 1 1 3 2 1 1 1 3 2 2 2 3 2 1 1 3 5 1 6 0 7 8 1 8 1 2 6 2 2 3 1 3 1 1 1 6 0 6 9 8 2 1 3 5 1 3 3 2 3 2 1 5 0 10 4 4 6 1 7 5 8 1 4 5 2 1 1 3 1 5 1 2 3 3 3 4 1 9 0 11 9 8 6 3 1 9 9 2 4 2 1 2 1 2 3 3 3 2 2 1 1 9 0 6 8 4 7 1 2 9 3 3 2 2 1 2 3 3 3 1 7 0 10 5 4 6 7 7 4 2 1 8 1 3 1 3 2 1 3 1 4 2 3 3 2 3 5 5 7 4 4 3 4 1 5 0 8 5 2 6 8 7 2 6 1 3 1 2 1 3 1 8 0 8 6 5 2 4 1 6 9 3 3 2 3 2 3 3 2 1 1 8 0 10 6 5 6 1 3 6 7 8 2 6 3 1 2 1 3 3 2 1 3 3 1 2 3 5 1 5 0 11 7 5 2 7 1 9 1 1 7 2 6 1 2 2 1 2 1 6 0 8 9 7 6 1 7 8 8 8 1 2 1 3 1 3 1 7 0 7 3 6 1 7 5 6 5 1 1 2 1 3 3 3 3 4 1 2 1 3 5 1 9 0 6 1 6 4 1 3 9 1 1 1 2 3 1 2 1 1 1 7 0 6 2 6 1 1 5 5 3 3 1 3 3 2 2 1 8 0 11 2 7 4 8 4 6 4 5 5 5 1 3 3 3 3 1 2 3 3 1 3 5 1 4 3 5 1 5 0 8 9 6 1 5 5 7 9 9 3 1 3 2 1 1 9 0 9 1 1 2 6 1 5 6 2 5 2 1 3 1 2 1 3 2 1 1 8 0 10 7 1 9 3 8 4 3 4 1 5 1 1 1 1 1 1 3 3 4 2 3 1 1 3 3 5 4 4 3 3 7 1 6 0 10 3 1 4 4 3 5 1 1 1 6 3 2 2 1 1 1 1 8 0 6 1 6 8 3 1 7 1 2 3 3 1 1 1 1 1 5 0 9 9 4 7 1 3 6 8 5 8 3 1 2 3 3 3 4 4 1 2 1 3 3 7 1 5 0 8 8 5 6 8 5 1 4 4 1 3 2 1 3 1 9 0 10 9 6 6 2 1 1 1 3 6 3 3 1 3 1 2 1 1 1 1 1 5 0 8 9 5 1 3 2 4 7 9 1 3 1 2 1 5 5 2 4 2 3 1 3 5 1 5 0 6 7 9 5 1 2 4 1 3 1 2 2 1 6 0 11 3 5 8 7 1 1 7 2 8 7 8 1 1 2 2 2 1 1 7 0 7 1 9 9 5 9 4 4 3 2 2 1 2 1 1 2 5 4 1 3 3 4 1 5 0 10 3 2 2 3 1 5 2 5 3 5 3 2 1 2 1 1 7 0 11 1 9 2 2 8 3 3 1 5 6 7 3 1 1 1 2 1 3 1 8 0 6 1 1 3 1 1 4 2 3 3 1 3 2 3 3 3 2 2 4 4 2 3 6 4 4 6 4 5 9 9 6 8 3 1 3"
-- Source : https://github.com/elm/elm-lang.org/blob/master/src/Cycle.elm
--Copyright (c) 2012-present Evan Czaplicki
--
--All rights reserved.
--
--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:
--
--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--
--    * Redistributions in binary form must reproduce the above
--      copyright notice, this list of conditions and the following
--      disclaimer in the documentation and/or other materials provided
--      with the distribution.
--
--    * Neither the name of Evan Czaplicki nor the names of other
--      contributors may be used to endorse or promote products derived
--      from this software without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
-- "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
-- LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
-- A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
-- OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
-- SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
-- LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
-- DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
-- THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
-- OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
module Cycle exposing
  ( Cycle
  , init
  , next
  , step
  )


type Cycle a =
  Cycle (List a) a (List a)


init : a -> List a -> Cycle a
init x xs =
  Cycle [] x xs


next : Cycle a -> a
next (Cycle _ x _) =
  x


step : Cycle a -> Cycle a
step (Cycle visited a unvisited) =
  case unvisited of
    [] ->
      restart visited a []

    x :: xs ->
      Cycle (a :: visited) x xs


restart : List a -> a -> List a -> Cycle a
restart visited a unvisited =
  case visited of
    [] ->
      Cycle [] a unvisited

    x :: xs ->
      restart xs x (a :: unvisited)

module Main exposing (..)

import Browser
import Http
import Html
import Element as E
import Element.Events as Events
import Element.Border as Border
import Element.Input as Input
import Json.Decode as D

import Post exposing ( Post )
import Views exposing ( Post_Element (..), Upload_Type (..))
import RemovingCache exposing (RemovingCache)
import User exposing ( User )
-- MAIN
main : Program () Model Msg
main = Browser.element
  { init = init
  , view = view
  , update = update
  , subscriptions = subscriptions
  }

-- MODEL
type Main_Page
  = Reading Post
  | Writing Post
  | Feed (List Post)
  | Login User



type alias Model = { user : Maybe User
                   , main_page : Main_Page
                   , stored_writings : List Post -- Written posts, that are in waiting (not actually shown)
                   , stored_feed : List Post -- Fetched posts, that are not shown.
                   , stored_readings : RemovingCache Post -- Post that have been read recently. This queue deletes one for each post added.
                   }

type Cache_Type = Feed_Cache | Writing_Cache | Reading_Cache

{-| RemovingCache some posts in the model.
-}
cache : Cache_Type -> Model -> List Post -> Model
cache ct model posts = case ct of
  Feed_Cache -> { model | stored_feed = List.foldl (\x acc -> if List.member x acc then acc else x::acc) [] <| posts ++ model.stored_feed }
  Writing_Cache -> { model | stored_writings = posts ++ model.stored_writings }
  Reading_Cache -> { model | stored_readings = RemovingCache.moves posts model.stored_readings }

{-| RemovingCache Feed in the stored_feed cache
-}
cache_feed : Model -> List Post -> Model
cache_feed = cache Feed_Cache

{-| RemovingCache Posts into the stored_writings cache
-}
cache_writings : Model -> List Post -> Model
cache_writings = cache Writing_Cache

{-| RemovingCache Posts in the stored_readings cache
-}
cache_readings : Model -> List Post -> Model
cache_readings = cache Reading_Cache

{-| Update the main_page only
-}
change_main_page : Main_Page -> Model -> Model
change_main_page mp model = { model | main_page = mp }

init : flags ->  ( Model, Cmd Msg )
init _ = (        { user =  { username = ""
                            , first_name = ""
                            , last_name = ""
                            }
                  , main_page = Feed [Post.welcome]
                  , stored_writings = []
                  , stored_feed = []
                  , stored_readings = RemovingCache.empty 50 (Post.empty "") -- The limit may be changed as storage space increases.
                  }
                  , Post.fetch Recv_Posts )


-- UPDATE
type Login_Field = Username | Password

type Msg
  = Read Post -- Switch to Reading with this Post
  | Write Post -- Writing with the Writing with this post
  | Changed  Post_Element String -- Change data structure accordingly
  | Upload Upload_Type Post
  | Saved ( Result Http.Error String )
  | Switch_To_Feed -- Go to Feed
  | Recv_Posts ( Result Http.Error (List Post) )
  | Login_Change Login_Field String

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Read post ->
      let new_main_page = change_main_page <| Reading post
      in case model.main_page of
        Writing p ->  ( new_main_page <| cache_writings model [p],  Cmd.none )
        Reading p ->  ( new_main_page <| cache_readings model [p], Cmd.none )
        Feed ps ->    ( new_main_page <| cache_feed model ps, Cmd.none )
    Write post ->
      let new_main_page = change_main_page <| Writing post
      in case model.main_page of
        Writing p -> ( new_main_page <| cache_writings model [p], Cmd.none )
        Reading p -> ( new_main_page <| cache_readings model [p], Cmd.none )
        Feed ps -> ( new_main_page <| cache_feed model ps, Cmd.none )

    Changed element post_element ->
      let (new_main_page, cmd) = case model.main_page of
            Writing p ->
              let post = case element of
                    Title -> { p | title = post_element, saved = False }
                    Content -> { p | content = post_element, saved = False }
              in ( Writing post, Cmd.none )
            Reading p -> ( Reading p, Cmd.none )
            Feed ps -> ( Feed ps, Cmd.none )
      in (change_main_page new_main_page model, cmd)

    Upload kind post ->
      let cmd = case kind of
            Publish -> Post.publish Saved post
            Save -> Post.save Saved post
          new_feed = if kind == Publish then post::model.stored_feed else model.stored_feed
      in ({ model | stored_feed = new_feed }, cmd)

    Saved result ->
      let (new_main_page, cmd) = case model.main_page of
            Writing p -> case result of
              Ok response -> ( Writing { p | saved = ( response == "Posted" ) }, Cmd.none )
              Err err -> ( Writing { p | saved = False }, Cmd.none )
            Reading p -> ( Reading p, Cmd.none )
            Feed ps -> ( Feed ps, Cmd.none )
      in (change_main_page new_main_page model, cmd)

    Switch_To_Feed ->
      let (new_main_page, cmd) = case model.main_page of
            Writing p -> case p.saved of
              True -> ( Feed model.stored_feed, Post.fetch Recv_Posts )
              False -> ( Writing p, Post.save Saved p )
            Reading p -> ( Feed model.stored_feed, Post.fetch Recv_Posts )
            Feed ps   ->  ( Feed ps, Post.fetch Recv_Posts )
      in (change_main_page new_main_page model, cmd)

    Recv_Posts posts ->
      let (new_main_page, cmd) = case model.main_page of
            Writing p -> ( Writing p, Cmd.none )
            Reading p -> ( Reading p, Cmd.none )
            Feed ps   ->
              ( case posts of
                  Ok new_posts -> Feed (new_posts ++ ps)
                  Err error -> Feed ps
              , Cmd.none
              )
      in (change_main_page new_main_page model, cmd)

    Login_Change field input ->
      case model.main_page of
        Writing p -> (change_main_page Login User.empty <| cache_writings model [p], Cmd.none)

-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model = Sub.none

-- VIEW
view : Model -> Html.Html Msg
view model =
  let element = case model.main_page of
        Writing p -> Views.writing Changed (Upload ) p
        Reading p -> Views.reading p
        Feed ps -> Views.feed Read ps
      content = case model.user of
            Just user ->
              [ E.wrappedRow [E.spacing 5]
                [ (E.el [Events.onClick Switch_To_Feed ] << E.text) "Feed"
                , (E.el [Events.onClick <| Write <| Post.empty model.user.username] << E.text) "Write"
                ]
              , element
              ]
            Nothing ->
              [ Input.username [] { onChange = Login_Change Username, text = "Username", placeholder = Nothing, label = Input.labelLeft [] Element.text "Username:" }
              , Input.currentPassword [] { onChange = Login_Change Password, text ="Password", placeholder = Nothing, label Input.labelLeft [] Element.text "Password:" }
              , Input.button [] { onPress = Just Login }
              ]
  in E.layout [E.centerX]
      <| E.column []

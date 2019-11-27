module Views exposing ( reading, writing, feed,vote, elections, Post_Element (..), Upload_Type (..) )


import Element exposing ( Element )
import Element.Background as Background
import Element.Input as Input
import Requests exposing ( Post )

-- Attribute Lists, that are used often:
post_attr = []

title_attr = []

edit_content_attr = []

edit_title_attr = [ Input.focusedOnLoad ]

edit_content_attr = []

-- Datatypes for distinction:
type Post_Element = Title | Content

type Upload_Type = Publish | Save

view_post : Element msg -> Element msg -> (String -> Element msg) -> (String -> Element msg) -> Post -> Element msg
view_post header footer fromTitle fromContent post =
  Element.textColumn post_attr
    [ header
    , fromTitle post.title
    , fromContent post.content
    , footer
    ]

reading : Post -> Element msg
reading
  = view_post
      Element.none
      Element.none
      (Element.text title_attr)
      (Element.paragraph post_body_attr << List.singleton << Element.text)

writing : msg -> Post -> Element msg
writing change_msg
  = view_post
      Element.none
      Element.none
      (\t -> Input.text edit_title_attr { onChange = change_msg
                                        , text = t
                                        , placeholder = Nothing
                                        , label = Input.labelLeft [] (Element.text "Title")
                                        })
      (\c -> Input.multiline edit_content_attr { onChange = })

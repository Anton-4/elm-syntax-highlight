module SyntaxHighlight
    exposing
        ( HCode
        , toBlockHtml
        , toInlineHtml
        , toStaticBlockHtml
        , toStaticInlineHtml
        , ConsoleOptions
        , toConsole
        , elm
        , xml
        , javascript
        , css
        , Theme
        , useTheme
        , monokai
        , gitHub
        , oneDark
        , Highlight(..)
        , highlightLines
        )

{-| Syntax highlighting in Elm.

@docs HCode


## Html view

@docs toBlockHtml, toInlineHtml, toStaticBlockHtml, toStaticInlineHtml


## Helpers

@docs Highlight, highlightLines


## Languages

Error while parsing should not happen. If it happens, please [open an issue](https://github.com/pablohirafuji/elm-syntax-highlight/issues) with the code that gives the error and the language.

@docs elm, xml, javascript, css


## Themes

@docs Theme, useTheme, monokai, gitHub, oneDark


## Console view

@docs ConsoleOptions, toConsole

-}

import Html exposing (Html, text)
import Parser
import SyntaxHighlight.Line as Line exposing (Line, Highlight)
import SyntaxHighlight.View as View
import SyntaxHighlight.Language.Elm as Elm
import SyntaxHighlight.Language.Xml as Xml
import SyntaxHighlight.Language.Javascript as Javascript
import SyntaxHighlight.Language.Css as Css
import SyntaxHighlight.Theme as Theme


{-| A highlighted code.
-}
type HCode
    = HCode (List Line)


{-| Transform a highlighted code into a Html block.
The `Maybe Int` argument is for showing or not line count and, if so, starting from what number.
-}
toBlockHtml : Maybe Int -> HCode -> Html msg
toBlockHtml maybeStart (HCode lines) =
    View.toBlockHtml maybeStart lines


{-| Transform a highlighted code into inline Html.

    import SyntaxHighlight exposing (elm, toInlineHtml)

    info : Html msg
    info =
        p []
            [ text "This function signature "
            , elm "isEmpty : String -> Bool"
                |> Result.map toInlineHtml
                |> Result.withDefault
                    (code [] [ text "isEmpty : String -> Bool" ])
            , text " means that a String argument is taken, then a Bool is returned."
            ]

-}
toInlineHtml : HCode -> Html msg
toInlineHtml (HCode lines) =
    View.toInlineHtml lines


{-| Transform a highlighted code into a static (pure text) Html block. The `Maybe Int` argument is for showing or not line count and, if so, starting from what number.
-}
toStaticBlockHtml : Maybe Int -> HCode -> String
toStaticBlockHtml maybeStart (HCode lines) =
    View.toStaticBlockHtml maybeStart lines


{-| Transform a highlighted code into static (pure text) inline Html.
-}
toStaticInlineHtml : HCode -> String
toStaticInlineHtml (HCode lines) =
    View.toStaticInlineHtml lines


{-| Transform a highlighted code into a list of console highlighted strings given the styling options defined by `ConsoleOptions`.
Each string in the list is a line.
-}
toConsole : ConsoleOptions -> HCode -> List String
toConsole options (HCode lines) =
    View.toConsole options lines


{-| Console styling options.
You can use the [rtfeldman/console-print](http://package.elm-lang.org/packages/rtfeldman/console-print/latest) package to fill in the styles.

The common uses of the styles are the following:

  - **default**: Default style
  - **highlight**: Highlight style
  - **addition**: Addition style
  - **deletion**: Deletion style
  - **comment**: Comment
  - **style1**: Number
  - **style2**: Literal string, attribute value
  - **style3**: Keyword, tag, operator symbols (=+-*/...)
  - **style4**: Keyword 2, group symbols ({}(),), type signature
  - **style5**: Function, attribute name
  - **style6**: Literal keyword, capitalized types
  - **style7**: Argument, parameter

-}
type alias ConsoleOptions =
    { default : String -> String
    , highlight : String -> String
    , addition : String -> String
    , deletion : String -> String
    , comment : String -> String
    , style1 : String -> String
    , style2 : String -> String
    , style3 : String -> String
    , style4 : String -> String
    , style5 : String -> String
    , style6 : String -> String
    , style7 : String -> String
    }


{-| Parse Elm syntax.
-}
elm : String -> Result Parser.Error HCode
elm =
    Elm.toLines
        >> Result.map HCode


{-| Parse XML syntax.
-}
xml : String -> Result Parser.Error HCode
xml =
    Xml.toLines
        >> Result.map HCode


{-| Parse Javascript syntax.
-}
javascript : String -> Result Parser.Error HCode
javascript =
    Javascript.toLines
        >> Result.map HCode


{-| Parse CSS syntax.
-}
css : String -> Result Parser.Error HCode
css =
    Css.toLines
        >> Result.map HCode


{-| A theme defines the background and syntax colors.
-}
type Theme
    = Theme String


{-| Transform a theme into Html. Any highlighted code transformed into Html in the same page will be themed according to the chosen `Theme`.

To preview the themes, check out the [demo](https://pablohirafuji.github.io/elm-syntax-highlight/).

    import SyntaxHighlight exposing (useTheme, monokai, elm, toBlockHtml)

    view : Model -> Html msg
    view model =
        div []
            [ useTheme monokai
            , elm model.elmCode
                |> Result.map (toBlockHtml (Just 1))
                |> Result.withDefault
                    (pre [] [ code [] [ text model.elmCode ] ])
            ]

If you prefer to use CSS external stylesheet, you do **not** need this,
just copy the theme CSS into your stylesheet.
All themes can be found [here](https://github.com/pablohirafuji/elm-syntax-highlight/blob/master/themes.md).

-}
useTheme : Theme -> Html msg
useTheme (Theme theme) =
    Html.node "style" [] [ text theme ]


{-| Monokai inspired theme.
-}
monokai : Theme
monokai =
    Theme Theme.monokai


{-| GitHub inspired theme.
-}
gitHub : Theme
gitHub =
    Theme Theme.gitHub


{-| Atom One Dark inspired theme.
-}
oneDark : Theme
oneDark =
    Theme Theme.oneDark


{-| Highlight type.

  - `Highlight` will highlight the line in a way to differentiate it from the rest, like github's yellow background.
  - `Add` will highlight in a manner that gives the ideia of new content added.
  - `Del` will highlight in a manner that gives the ideia of removed content.

The specific styles will depend on the chosen `Theme`.

-}
type Highlight
    = Highlight
    | Add
    | Del


{-| Highlight lines given a highlight type, start and end index.
If no highlight type is given (`Nothing`), it will remove any
highlight from the line range.
Negative indexes are taken starting from the *end* of the list.
-}
highlightLines : Maybe Highlight -> Int -> Int -> HCode -> HCode
highlightLines maybeHighlight start end (HCode lines) =
    let
        maybeHighlight_ =
            case maybeHighlight of
                Nothing ->
                    Nothing

                Just Highlight ->
                    Just Line.Normal

                Just Add ->
                    Just Line.Add

                Just Del ->
                    Just Line.Del
    in
        Line.highlightLines maybeHighlight_ start end lines
            |> HCode

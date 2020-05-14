{-# LANGUAGE OverloadedStrings #-}

module Context
    ( postCtx
    , dropIndexHtml
    , teasCtx
    , gitInfoCtx
    , mathCtx
    , livejsCtx
    ) where

    
--------------------------------------------------------------------------------
import           Hakyll.Web.Template.Context
import           Hakyll.Core.Compiler            (unsafeCompiler, Compiler)
import           Hakyll.Core.Identifier          (toFilePath, Identifier)
import           Hakyll.Core.Item                (itemIdentifier, Item)
import           Hakyll.Core.Configuration       (providerDirectory)
import           Hakyll.Core.Metadata            (getMetadataField)
import           Hakyll.Web.Html                 (toUrl)

import           Configuration
import           Compiler

import           System.Process
import           System.FilePath                 ( (</>), (<.>)--, combine
                                                 , splitFileName
                                                 , takeDirectory )
-- import           Text.Blaze.Html                 (toHtml, toValue, (!))
-- import           Text.Blaze.Html.Renderer.String (renderHtml)
-- import qualified Text.Blaze.Html5                as H
-- import qualified Text.Blaze.Html5.Attributes     as A

--------------------------------------------------------------------------------

postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y"    <>
    dropIndexHtml "url"             <>
    gitInfoCtx                      <>
    mathCtx                         <>
    defaultContext

--------------------------------------------------------------------------------

teasCtx :: Context String
teasCtx =
    teaserField "teaser" "content" <>
    postCtx

--------------------------------------------------------------------------------

dropIndexHtml :: String -> Context a
dropIndexHtml key = mapContext transform (urlField key)
    where transform url = case splitFileName url of
                              (p, "index.html") -> takeDirectory p
                              _                 -> url

--------------------------------------------------------------------------------

gitRepo :: FilePath
gitRepoSrc :: FilePath
gitRepoCommits :: FilePath

gitRepo = "https://github.com/haoyun/haoyun.github.io"
gitRepoCommits = gitRepo ++ "/commits/source"
-- or gitRepoSrc = gitRepo ++ "/blob"
gitRepoSrc = "https://raw.githubusercontent.com/haoyun/haoyun.github.io/"

--------------------------------------------------------------------------------

-- | Reference:
--     1. https://github.com/blaenk/blaenk.github.io/blob/source/src/Site/Contexts.hs
-- 
-- It will slow down the compile process, for example
-- gitSrcField and gitSHAField both run gitLog to get the same infomation
-- The advantage is that there is no need to re-compile the haskell src,
-- when we want to change the layout of the website. all the fields can be
-- freely used in templates.
--
-- There should be a better way to deal with "/"
-- </> does not work.

gitCommitsField :: String -> Context String
gitCommitsField key =  field key $ \item -> do
    return $ (gitRepoCommits ++ (toUrl $ getSrcPath item))

gitSHAField :: String -> Context String
gitSHAField key = field key retrieveGitSHACompiler

gitSrcField :: String -> Context String
gitSrcField key = field key $ \item -> do
     sha <- retrieveGitSHACompiler item
     return $ gitRepoSrc ++ sha ++ (toUrl $ getSrcPath item)

gitMessageField :: String -> Context String
gitMessageField key = field key retrieveGitMessageCompiler

gitInfoCtx :: Context String
gitInfoCtx =
    gitCommitsField "git-commits"      <>
    gitSHAField     "git-SHA"          <>
    gitMessageField "git-message"      <>
    gitSrcField     "git-src"

-- gitTag :: String -> Context String
-- gitTag key = field key $ \item -> do
--     let fp = getSrcPath item
--
--     unsafeCompiler $ do
--         sha     <- gitLog "%h" fp
--         message <- gitLog "%s" fp
--
--         let history = gitRepoSrc ++ fp
--             commit  = gitRepoCommits ++ sha
--
--         return $ if null sha
--                      then "Not Committed"
--                      else renderHtml $ do
--                           H.a ! A.href (toValue history) $ "History"
--                           H.span ! A.class_ "hash" $ do
--                               toHtml (", " :: String)
--                               H.a ! A.href (toValue commit) ! A.title (toValue message) $ toHtml sha


--------------------------------------------------------------------------------

-- | If the metafield `MathJax` is missing, or set to `false` or `off`,
-- set $MathJax$ to be empty string, otherwise, to be the CND for mathjax.
--
-- Note that the metadata filed is case-sensitive.
--
-- References:
--     1. https://axiomatic.neophilus.net/using-katex-with-hakyll/
mathCtx :: Context a
mathCtx = field "MathJax" $ \item -> do
    mathjax <- getMetadataField (itemIdentifier item) "MathJax"
    return $ case mathjax of
        Nothing -> ""
        Just "false" -> ""
        Just "off" -> ""
        _ -> "<script async id=\"MathJax-script\"\
            \ src=\"//cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js\">\
            \ </script>"

--------------------------------------------------------------------------------

-- | Depending on the boolean value, set `livejsCtx` to be an empty monoid or
-- a `constField "livejs"`.
livejsCtx :: Bool -> Context String
livejsCtx ifwatchmode = if ifwatchmode
    then constField "livejs" "TRUE"
    else mempty

--------------------------------------------------------------------------------


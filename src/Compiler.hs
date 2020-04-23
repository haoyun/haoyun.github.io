{-# LANGUAGE OverloadedStrings #-}

module Compiler
    ( retrieveGitSHACompiler
    , retrieveGitMessageCompiler
    , getSrcPath
    , pandocMathCompiler
    , renderPandocMath
    , pandocCustomCompiler
    , customWriterOptions
    , customReaderOptions
--    , writerOptionsWithToc
    ) where

--------------------------------------------------------------------------------
import           Hakyll.Core.Compiler            (unsafeCompiler, Compiler)
import           Hakyll.Core.Identifier          (toFilePath, Identifier)
import           Hakyll.Core.Item                (itemIdentifier, Item)
import           Hakyll.Core.Configuration       (providerDirectory)
import           Hakyll.Web.Html                 (toUrl)
import           Hakyll.Web.Pandoc

import           Text.Pandoc
import           Text.Pandoc.Shared              (eastAsianLineBreakFilter)

import           Configuration

import           System.Process
import           System.FilePath                 ( (</>), (<.>), combine
                                                 , splitFileName
                                                 , takeDirectory )
--------------------------------------------------------------------------------

-- Reference
--     readProcess
--         :: FilePath   -- ^ Filename of the executable
--         -> [String]   -- ^ any arguments
--         -> String     -- ^ standard input
--         -> IO String  -- ^ stdout

retrieveGitSHACompiler :: Item a -> Compiler String
retrieveGitSHACompiler item = unsafeCompiler $ do
    gitLog "%h" (getSrcPath item)
    

retrieveGitMessageCompiler :: Item a -> Compiler String
retrieveGitMessageCompiler item = unsafeCompiler $ do
    gitLog "%s" (getSrcPath item)
    
getSrcPath :: Item a -> FilePath
getSrcPath = (\x -> combine (providerDirectory configuration) x ) . toFilePath . itemIdentifier

--------------------------------------------------------------------------------
gitLog :: String    -- ^ git log format
       -> FilePath  -- ^ path of the post
       -> IO String -- ^ output of git log
gitLog format path =
    readProcess "git" ["log", "-1", "HEAD", "--pretty=format:" ++ format, path] ""
--------------------------------------------------------------------------------

-- | Adopted from https://github.com/bgamari/writing/blob/master/hakyll.hs
-- compatible with Pandoc >= 2.0
-- see also https://stackoverflow.com/a/51500296/2929058
pandocMathCompiler :: Compiler (Item String)
pandocMathCompiler = pandocCompilerWith customReaderOptions customWriterOptions

renderPandocMath :: Item String -> Compiler (Item String)
renderPandocMath = renderPandocWith customReaderOptions customWriterOptions

pandocCustomCompiler :: Compiler (Item String)
pandocCustomCompiler = pandocCompilerWithTransform customReaderOptions customWriterOptions eastAsianLineBreakFilter

customWriterOptions :: WriterOptions
customWriterOptions = defaultHakyllWriterOptions { writerHTMLMathMethod = MathJax ""}
                     
customReaderOptions :: ReaderOptions
customReaderOptions = defaultHakyllReaderOptions
                      { readerExtensions = pandocExtensions <> 
                                           extensionsFromList
                                           [ Ext_tex_math_single_backslash
-- The following extension does not work.
-- See https://github.com/jgm/pandoc/pull/4674/commits/4012dd75f30f888c7915f4874072b26c61d810a0 
--                                           , Ext_east_asian_line_breaks
                                           ]
                      }

--------------------------------------------------------------------------------

-- | Recnernces:
-- 1. https://argumatronic.com/posts/2018-01-16-pandoc-toc.html
-- 2. https://peter.colberg.org/site#table-of-contents
-- 3. https://jip.dev/posts/the-switch-to-hakyll/#table-of-contents

-- writerOptionsWithToc :: WriterOptions
-- writerOptionsWithToc = customWriterOptions
--                        { writerTableOfContents = True
--                        , writerTOCDepth = 2
--                        , writerTemplate = Just "Contents\n$toc$\n$body$"
--                        }

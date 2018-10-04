{-# LANGUAGE OverloadedStrings #-}

module Compiler
    ( retrieveGitSHACompiler
    , retrieveGitMessageCompiler
    , getSrcPath
    , pandocMathCompiler
    , renderPandocMath
    , customWriterOptions
    , customReaderOptions
    ) where

--------------------------------------------------------------------------------
import           Hakyll.Core.Compiler            (unsafeCompiler, Compiler)
import           Hakyll.Core.Identifier          (toFilePath, Identifier)
import           Hakyll.Core.Item                (itemIdentifier, Item)
import           Hakyll.Core.Configuration       (providerDirectory)
import           Hakyll.Web.Html                 (toUrl)
import           Hakyll.Web.Pandoc

import           Text.Pandoc

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

customWriterOptions :: WriterOptions
customWriterOptions = defaultHakyllWriterOptions { writerHTMLMathMethod = MathJax ""}
                     
customReaderOptions :: ReaderOptions
customReaderOptions = defaultHakyllReaderOptions
                      { readerExtensions = pandocExtensions <> 
                                           extensionsFromList [ Ext_tex_math_single_backslash]
                      }
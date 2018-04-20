{-# LANGUAGE OverloadedStrings #-}

module Compiler
    ( retrieveGitSHACompiler
    , retrieveGitMessageCompiler
    , getSrcPath
    ) where

--------------------------------------------------------------------------------
import           Hakyll.Core.Compiler            (unsafeCompiler, Compiler)
import           Hakyll.Core.Identifier          (toFilePath, Identifier)
import           Hakyll.Core.Item                (itemIdentifier, Item)
import           Hakyll.Core.Configuration       (providerDirectory)
import           Hakyll.Web.Html                 (toUrl)

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

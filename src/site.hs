--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
--------------------------------------------------------------------------------
import           Hakyll

import           Configuration
import           Rules

import           System.Environment
--------------------------------------------------------------------------------

main :: IO ()
main = do
  -- renderFormulae <- myInitFormulaCompilerDataURI 1000 myDefaultEnv

  -- | get the first argument of the command. From System.Environment.
  -- Refereces:
  --     1. <https://github.com/jdreaver/jdreaver.com/blob/master/hakyll.hs#L11>
  --     2. <https://www.jdreaver.com/posts/2014-06-22-math-programming-blog-hakyll.html#drafts>
  (action:_) <- getArgs

  -- | if the program is run in `watch` mode, then set `livejs` to be TRUE.
  -- This test can also be used to decide which files to be compiled, for
  -- example, drafts are only compiled in `watch` mode, as in the above
  -- referece.
  let ifWatchMode = action == "watch"

  -- | Run Hakyll with `configuration` and `siteRules`.
  hakyllWith configuration (siteRules ifWatchMode)

--------------------------------------------------------------------------------



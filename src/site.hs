--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
--------------------------------------------------------------------------------
import           Data.Monoid (mappend)
import           Hakyll

import           Routes
import           Context
import           Configuration
import           Compiler
-- import           LaTeXtoImage

import           System.Environment
--------------------------------------------------------------------------------

main :: IO ()
main = do
    -- renderFormulae <- myInitFormulaCompilerDataURI 1000 myDefaultEnv

    -- | get the first argument of the command.
    --
    -- Refereces:
    --     1. <https://github.com/jdreaver/jdreaver.com/blob/master/hakyll.hs#L11>
    --     2. <https://www.jdreaver.com/posts/2014-06-22-math-programming-blog-hakyll.html#drafts>
    (action:_) <- getArgs

    -- | if the program is run in `watch` mode, then set `livejs` to be TRUE.
    -- This test can also be used to decide which files to be compiled, for
    -- example, drafts are only compiled in `watch` mode, as in the above
    -- referece.
    let ifWatchMode = action == "watch"
    --    postCtx' = if ifWatchMode
    --                   then constField "livejs" "TRUE" `mappend` postCtx
    --                   else postCtx
    print ifWatchMode

    -- | Run Hakyll with `configuration` and `siteRules`.
    -- References:
    --     1. http://nbloomf.blog/site.html
    hakyllWith configuration (siteRulesWithCtx ifWatchMode)

--------------------------------------------------------------------------------

siteRulesWithCtx :: Bool -> Rules()
siteRulesWithCtx ifwatchmode = do
    createREADME
    createNoJekyll
    createCNAME
    createRobots
    matchBinary
    matchTemplete
    matchIndex ifwatchmode
    matchNIndex ifwatchmode
    matchNMDs ifwatchmode
    matchSIndex ifwatchmode
    matchSMDs ifwatchmode

--------------------------------------------------------------------------------
-- | Create a simple README.md file for the github repository.
createREADME :: Rules()
createREADME = create ["README.md"] $ do
    route idRoute
    compile (makeItem ("Static website proudly generted by \
    \[Hakyll](https://jaspervdj.be/hakyll/), \
    \from source files in the `source` branch.\n"::String))

-- | Create a `.nojekyll` file for github pages, to avoid the Jekyll
-- accidiently modifying the Hakyll generated files.
createNoJekyll:: Rules()
createNoJekyll = create [".nojekyll"] $ do
    route idRoute
    compile (makeItem ("No jekyll\n"::String))

-- | Create the `CNAME` file, for customized domain.
createCNAME :: Rules()
createCNAME = create ["CNAME"] $ do
    route idRoute
    compile (makeItem ("naturalstupidity.tk\n"::String))

-- | Create the `robots.txt` to avoid google robots..
createRobots :: Rules()
createRobots = create ["robots.txt"] $ do
    route idRoute
    compile (makeItem ("User-agent: *\nDisallow: /\n"::String))

-- | Copy binary files
matchBinary :: Rules()
matchBinary = do
    match ("images/**" .||. "files/**" .||. "js/*" .||. "vendor/**") $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

matchTemplete :: Rules()
matchTemplete = match "templates/*" $ compile templateBodyCompiler

matchIndex :: Bool -> Rules()
matchIndex ifwatchmode = match "index.html" $ do
    route idRoute
    compile $ getResourceBody
         >>= applyAsTemplate (postCtx `mappend` livejsCtx ifwatchmode)

matchNIndex :: Bool -> Rules()
matchNIndex ifwatchmode = match "n/index.html" $ do
    route idRoute
    compile $ do
        -- posts <- recentFirst =<< loadAll "posts/*"
        posts <- recentFirst =<< loadAllSnapshots "n/posts/*" "content"
        let indexCtx =
                -- listField "posts" postCtx (return posts) `mappend`
                listField "posts" teasCtx   (return posts) `mappend`
                (livejsCtx ifwatchmode)                    `mappend`
                -- constField "title" "Home"                `mappend`
                defaultContext

        getResourceBody
            >>= applyAsTemplate indexCtx
            >>= loadAndApplyTemplate "templates/post-with-hero.html" indexCtx
            >>= loadAndApplyTemplate "templates/default.html" (gitInfoCtx `mappend` indexCtx)
            >>= relativizeUrls

matchSMDs :: Bool -> Rules()
matchSMDs ifwatchmode = do
    let postCtx' = (livejsCtx ifwatchmode) `mappend` postCtx

    match ( "comment.markdown" .||.
            "s/seminars/**.markdown" .||.
            "s/*.markdown" .&&. complement "s/index.markdown"
          ) $ do
        route $ setExtension "html" `composeRoutes` appendIndex
        compile $ getResourceBody
            >>= applyAsTemplate postCtx
            >>= renderPandocMath
            >>= loadAndApplyTemplate "templates/textfile.html" postCtx'
            >>= relativizeUrls

matchNMDs :: Bool -> Rules()
matchNMDs ifwatchmode = do
    let postCtx' = (livejsCtx ifwatchmode) `mappend` postCtx

    match (fromList ["n/about.markdown", "n/contact.markdown"]) $ do
        route $ setExtension "html" `composeRoutes`
                appendIndex
        compile $ pandocCustomCompiler
            >>= loadAndApplyTemplate "templates/post-title-body.html"   postCtx
            >>= loadAndApplyTemplate "templates/default.html"           postCtx'
            >>= relativizeUrls

    match "n/posts/*.markdown" $ do
        route $ setExtension "html" `composeRoutes`
                appendIndex         `composeRoutes`
                dateFolders
        compile $ pandocCustomCompiler
            >>= saveSnapshot "content"
            >>= loadAndApplyTemplate "templates/post-title_info-body.html" postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx'
            >>= relativizeUrls

    create ["n/archive.html"] $ do
        route $ idRoute  `composeRoutes` appendIndex
        compile $ do
            posts <- recentFirst =<< loadAll "n/posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Archives"            `mappend`
                    dropIndexHtml "url"                      `mappend`
                    (livejsCtx ifwatchmode) `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/post-title-body.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

matchSIndex :: Bool -> Rules()
matchSIndex ifwatchmode = do
    let postCtx' = (livejsCtx ifwatchmode) `mappend` postCtx
    match "s/index.markdown" $ do
        route $ setExtension "html"
        compile $ pandocCustomCompiler
            >>= loadAndApplyTemplate "templates/textfile.html" postCtx'
            >>= relativizeUrls

-- match "s/seminars/**.markdown" $ do
--     route $ setExtension "html"
--     compile $ do
--             pandocCompilerWithTransformM customReaderOptions customWriterOptions
--                $ myCompileFormulaeDataURI myDefaultEnv defaultPandocFormulaOptions
--             >>= loadAndApplyTemplate "templates/textfile.html" postCtx'
--             >>= relativizeUrls

--------------------------------------------------------------------------------

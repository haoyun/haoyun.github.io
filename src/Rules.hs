--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
--------------------------------------------------------------------------------
module Rules
    ( siteRules
    ) where

--------------------------------------------------------------------------------
import           Hakyll
import           Context
import           Routes
import           Compiler
--------------------------------------------------------------------------------

-- References:
--     1. http://nbloomf.blog/site.html
siteRules :: Bool -> Rules()
siteRules ifwatchmode = do
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
         >>= applyAsTemplate (postCtx <> livejsCtx ifwatchmode)

matchNIndex :: Bool -> Rules()
matchNIndex ifwatchmode = match "n/index.html" $ do
    route idRoute
    compile $ do
        -- posts <- recentFirst =<< loadAll "posts/*"
        posts <- recentFirst =<< loadAllSnapshots "n/posts/*" "content"
        let indexCtx =
             -- listField "posts" postCtx (return posts) <>
             listField "posts" teasCtx   (return posts) <>
             (livejsCtx ifwatchmode)                    <>
             -- constField "title" "Home"                <>
             defaultContext

        getResourceBody
            >>= applyAsTemplate indexCtx
            >>= loadAndApplyTemplate "templates/post-with-hero.html" indexCtx
            >>= loadAndApplyTemplate "templates/default.html" (gitInfoCtx <> indexCtx)
            >>= relativizeUrls

matchSMDs :: Bool -> Rules()
matchSMDs ifwatchmode = do
    let postCtx' = (livejsCtx ifwatchmode) <> postCtx

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
    let postCtx' = (livejsCtx ifwatchmode) <> postCtx

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
                    listField "posts" postCtx (return posts) <>
                    constField "title" "Archives"            <>
                    dropIndexHtml "url"                      <>
                    (livejsCtx ifwatchmode)                  <>
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/post-title-body.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

matchSIndex :: Bool -> Rules()
matchSIndex ifwatchmode = do
    let postCtx' = (livejsCtx ifwatchmode) <> postCtx
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

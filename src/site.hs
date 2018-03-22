--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll
import           ExtensionlessUrl
--------------------------------------------------------------------------------
main :: IO ()
main = hakyllWith hfConfiguration $ do
    -- | Create .nojekyll
    create [".nojekyll"] $ do
        route idRoute
        compile (makeItem ("No jekyll\n"::String))
    
    -- | Create CNAME
    create ["CNAME"] $ do
        route idRoute
        compile (makeItem ("naturalstupidity.tk\n"::String))

    -- | Create robots.txt
    create ["robots.txt"] $ do
        route idRoute
        compile (makeItem ("User-agent: *\nDisallow: /\n"::String))   
        
    -- | Copy binary files
    match ("images/**" .||. "files/**" .||. "js/*" .||. "vendor/**") $ do
        route   idRoute
        compile copyFileCompiler
        
    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler
        
    -- | Compile pages

    match (fromList ["n/about.rst", "n/contact.markdown"]) $ do
        route $ setExtension "html" `composeRoutes`
                appendIndex
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post-title-body.html"   postCtx
            >>= loadAndApplyTemplate "templates/post.html"              postCtx
            >>= loadAndApplyTemplate "templates/default.html" (dropIndexHtml "url"  `mappend` defaultContext)
            >>= relativizeUrls

    match "n/posts/*" $ do
        route $ setExtension "html" `composeRoutes`
                appendIndex         `composeRoutes`
                dateFolders
        compile $ pandocCompiler
            >>= saveSnapshot "content"
            >>= loadAndApplyTemplate "templates/post-title_info-body.html"    postCtx
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    create ["n/archive.html"] $ do
        route $ idRoute  `composeRoutes`
                appendIndex
        compile $ do
            posts <- recentFirst =<< loadAll "n/posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Archives"            `mappend`
                    dropIndexHtml "url"                      `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/post-title-body.html" archiveCtx
                >>= loadAndApplyTemplate "templates/post.html"    archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls


    match "n/index.html" $ do
        route idRoute
        compile $ do
            -- posts <- recentFirst =<< loadAll "posts/*"
            posts <- recentFirst =<< loadAllSnapshots "n/posts/*" "content"
            let indexCtx =
                    -- listField "posts" postCtx (return posts) `mappend`
                    listField "posts" teasCtx (return posts) `mappend`
                    -- constField "title" "Home"                `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/post-with-hero.html" indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls
    
    match "index.html" $ do
        route idRoute
        compile $ getResourceBody
            >>= applyAsTemplate postCtx

    match "s/index.markdown" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/textfile.html" postCtx
            >>= relativizeUrls

    match ( "comment.markdown" .||. 
            "s/*.markdown" .&&. complement "s/index.markdown"
          ) $ do
                route $ setExtension "html" `composeRoutes` appendIndex
                compile $ getResourceBody
                    >>= applyAsTemplate postCtx
                    >>= renderPandoc
                    >>= loadAndApplyTemplate "templates/textfile.html" postCtx

    match "templates/*" $ compile templateBodyCompiler


--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    dropIndexHtml "url"          `mappend`
    defaultContext
    
teasCtx :: Context String
teasCtx =
    teaserField "teaser" "content" `mappend`
    postCtx

--------------------------------------------------------------------------------
hfConfiguration :: Configuration
hfConfiguration = defaultConfiguration
    {
--      destinationDirectory = "_site"
--    , storeDirectory       = "_cache"
--    , tmpDirectory         = "_cache/tmp"
        providerDirectory    = "./src_site"
--    , ignoreFile           = ignoreFile'
      , deployCommand        = "zsh ./src/deploy.sh" -- "echo 'No deploy command specified' && exit 1"
--    , deploySite           = system . deployCommand
--    , inMemoryCache        = True
      , previewHost          = "0.0.0.0"
      , previewPort          = 80
    }

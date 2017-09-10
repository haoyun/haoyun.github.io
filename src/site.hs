--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll

import           Data.List        (isPrefixOf, isSuffixOf)
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
    match "images/**" $ do
        route   idRoute
        compile copyFileCompiler
    
    match "files/**" $ do
        route   idRoute
        compile copyFileCompiler
        
    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler
    
    match "js/*" $ do
        route   idRoute
        compile copyFileCompiler
        
    -- | Compile pages

    match (fromList ["n/about.rst", "n/contact.markdown"]) $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    match "n/posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    create ["n/archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "n/posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Archives"            `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls


    match "n/index.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "n/posts/*"
            let indexCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Home"                `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls
    
    match "index.html" $ do
        route idRoute
        compile copyFileCompiler
    
    match "s/index.markdown" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/textfile.html" postCtx
            >>= relativizeUrls
            

    match "templates/*" $ compile templateBodyCompiler


--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext

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

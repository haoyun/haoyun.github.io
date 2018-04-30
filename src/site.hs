--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll


import           Routes
import           Context
import           Configuration
--------------------------------------------------------------------------------

import           System.Environment


ifLiveJS :: String
ifLiveJS = "0"

main :: IO ()
main = do

    (action:_) <- getArgs
    
    -- | the field $livejs$ is used only when applying the default.html template
    let ifWatchMode = action == "watch"
        postCtx' = if ifWatchMode
                       then constField "livejs" "TRUE" `mappend` postCtx
                       else postCtx
    
    --print ifWatchMode

    hakyllWith configuration $ do
    
        -- | Crete README.md
        create ["README.md"] $ do
            route idRoute
            compile (makeItem ("\
    \Static website proudly generted by [Hakyll](https://jaspervdj.be/hakyll/),\n\
    \from the source files in the `source` branch.\n"::String))
    
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
    
        match (fromList ["n/about.markdown", "n/contact.markdown"]) $ do
            route $ setExtension "html" `composeRoutes`
                    appendIndex
            compile $ pandocCompiler
                >>= loadAndApplyTemplate "templates/post-title-body.html"   postCtx
                >>= loadAndApplyTemplate "templates/default.html"           postCtx'
                >>= relativizeUrls
    
        match "n/posts/*.markdown" $ do
            route $ setExtension "html" `composeRoutes`
                    appendIndex         `composeRoutes`
                    dateFolders
            compile $ pandocCompiler
                >>= saveSnapshot "content"
                >>= loadAndApplyTemplate "templates/post-title_info-body.html"    postCtx
                >>= loadAndApplyTemplate "templates/default.html" postCtx'
                >>= relativizeUrls
    
        create ["n/archive.html"] $ do
            route $ idRoute  `composeRoutes`
                    appendIndex
            compile $ do
                posts <- recentFirst =<< loadAll "n/posts/*"
                let archiveCtx =
                        listField "posts" postCtx (return posts) `mappend`
                        constField "title" "Archives"             `mappend`
                        dropIndexHtml "url"                       `mappend`
                        (if ifWatchMode then constField "livejs" "TRUE" else mempty) `mappend`
                        defaultContext
    
                makeItem ""
                    >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                    >>= loadAndApplyTemplate "templates/post-title-body.html" archiveCtx
                    >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                    >>= relativizeUrls
    
    
        match "n/index.html" $ do
            route idRoute
            compile $ do
                -- posts <- recentFirst =<< loadAll "posts/*"
                posts <- recentFirst =<< loadAllSnapshots "n/posts/*" "content"
                let indexCtx =
                        -- listField "posts" postCtx (return posts) `mappend`
                        listField "posts" teasCtx   (return posts) `mappend`
                        (if ifWatchMode then constField "livejs" "TRUE" else mempty) `mappend`
                        -- constField "title" "Home"                `mappend`
                        defaultContext
    
                getResourceBody
                    >>= applyAsTemplate indexCtx
                    >>= loadAndApplyTemplate "templates/post-with-hero.html" indexCtx
                    >>= loadAndApplyTemplate "templates/default.html" (gitInfoCtx `mappend` indexCtx)
                    >>= relativizeUrls
        
        match "index.html" $ do
            route idRoute
            compile $ getResourceBody
                >>= applyAsTemplate postCtx'
    
        match "s/index.markdown" $ do
            route $ setExtension "html"
            compile $ pandocCompiler
                >>= loadAndApplyTemplate "templates/textfile.html" postCtx'
                >>= relativizeUrls
    
        match ( "comment.markdown" .||. 
                "s/*.markdown" .&&. complement "s/index.markdown"
              ) $ do
                    route $ setExtension "html" `composeRoutes` appendIndex
                    compile $ getResourceBody
                        >>= applyAsTemplate postCtx
                        >>= renderPandoc
                        >>= loadAndApplyTemplate "templates/textfile.html" postCtx'
    
        match "templates/*" $ compile templateBodyCompiler
--------------------------------------------------------------------------------

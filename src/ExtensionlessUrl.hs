module ExtensionlessUrl
    (  appendIndex
     , dropIndexHtml
     , dateFolders
    ) where

--------------------------------------------------------------------------------
import           System.FilePath             ( (</>), (<.>), combine
                                             , splitExtension, splitFileName
                                             , takeDirectory )
                                 
import           Hakyll.Core.Routes
import           Hakyll.Web.Template.Context
import           Hakyll.Core.Identifier
import           Hakyll.Core.Util.String
--------------------------------------------------------------------------------
appendIndex :: Routes
appendIndex = customRoute $
    (\(p, e) -> p ++ "/index" ++ e ) . splitExtension . toFilePath
--------------------------------------------------------------------------------
dateFolders :: Routes
dateFolders =
    gsubRoute "/[0-9]{4}-[0-9]{2}-[0-9]{2}-" $ replaceAll "-" (const "/")
-- This is not enough. If the file name does not contain date info, we
-- need to get it from metadata or metadata file.
--------------------------------------------------------------------------------
dropIndexHtml :: String -> Context a
dropIndexHtml key = mapContext transform (urlField key)
    where transform url = case splitFileName url of
                              (p, "index.html") -> takeDirectory p
                              _                 -> url
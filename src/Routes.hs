module Routes
    (  appendIndex
     , dateFolders
    ) where

--------------------------------------------------------------------------------
import           Hakyll.Core.Routes          (Routes, gsubRoute, customRoute)
import           Hakyll.Core.Identifier      (toFilePath)
import           Hakyll.Core.Util.String     (replaceAll)

import           System.FilePath             ( (</>), (<.>), combine
                                             , splitExtension
                                             , takeDirectory )
--------------------------------------------------------------------------------
appendIndex :: Routes
appendIndex = customRoute $
    (\(p, e) -> p ++ "/index" ++ e ) . splitExtension . toFilePath
--------------------------------------------------------------------------------
-- This is not enough. If the file name does not contain date info, we
-- need to get it from metadata or metadata file.
dateFolders :: Routes
dateFolders =
    gsubRoute "/[0-9]{4}-[0-9]{2}-[0-9]{2}-" $ replaceAll "-" (const "/")
--------------------------------------------------------------------------------

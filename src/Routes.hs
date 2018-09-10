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
                                             , takeDirectory 
                                             , takeBaseName)
--------------------------------------------------------------------------------

-- | Get the file path and split its file name and extension.
-- If the file name is index, do nothing;
-- otherwise, insert index.
appendIndex :: Routes
appendIndex = customRoute $
    appendIndex' . splitExtension . toFilePath
    where appendIndex' (p, e) = if takeBaseName(p) == "index"
                                    then p ++ e 
                                    else p ++ "/index" ++ e
            
--------------------------------------------------------------------------------

-- | This works only when the file name contains date info
-- An improved version should be implement so it can get the date info
-- from metadata block in the file or a separated metadata file.
dateFolders :: Routes
dateFolders =
    gsubRoute "/[0-9]{4}-[0-9]{2}-[0-9]{2}-" $ replaceAll "-" (const "/")

--------------------------------------------------------------------------------

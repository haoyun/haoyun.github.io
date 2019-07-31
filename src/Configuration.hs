module Configuration
    ( configuration
    ) where


--------------------------------------------------------------------------------
import           Hakyll.Core.Configuration
--------------------------------------------------------------------------------

configuration :: Configuration
configuration = defaultConfiguration
    {
--      destinationDirectory = "_site"
--    , storeDirectory       = "_cache"
--    , tmpDirectory         = "_cache/tmp"
        providerDirectory    = "src_site/"
--    , ignoreFile           = ignoreFile'
      , deployCommand        = "zsh ./src/deploy.sh" -- "echo 'No deploy command specified' && exit 1"
--    , deploySite           = system . deployCommand
--    , inMemoryCache        = True
      , previewHost          = "0.0.0.0"
      -- previewPort has to be >= 1024, otherwise, sudo is required
      -- Network.Socket.bind: permission denied (Permission denied)
      , previewPort          = 8000
    }

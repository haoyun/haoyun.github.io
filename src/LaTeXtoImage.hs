-- {-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ViewPatterns #-}


module LaTeXtoImage
    (  myImageForFormula
     , myDefaultEnv
     , myCompileFormulaeDataURI
     , myInitFormulaCompilerDataURI
     , defaultPandocFormulaOptions
    ) where

import Image.LaTeX.Render
import Codec.Picture
import Data.Maybe                 (listToMaybe)
import Control.Error.Util         (note, tryIO, hoistEither)
import Data.List                  (foldl')
import System.IO.Temp             (withTempDirectory, withSystemTempDirectory)
import System.FilePath            ((</>), (<.>))
import System.Process             (readProcessWithExitCode)
import System.Directory           (removeFile, setCurrentDirectory, getCurrentDirectory)
import Control.Monad.Trans.Except (withExceptT, throwE, runExceptT)
import Control.Monad              (when)
import Control.Exception          (bracket)
import System.Exit                (ExitCode(..))
import Control.Arrow              (second)

-- import Codec.Picture              (writeDynamicPng) -- JuicyPixels
-- import Control.Applicative
-- import Data.Monoid
-- import Prelude

import Image.LaTeX.Render.Pandoc


import Hakyll.Contrib.LaTeX
import Hakyll.Core.Compiler
import Text.Pandoc
import qualified Data.Cache.LRU.IO as LRU
import Data.Char                  (isSpace)



-- main = do x <- myImageForFormula myEnv math "y = \\sin x mx + b"
--           case x of
--            Left e -> return ()
--            Right (baseline, img) -> do
--              _ <- writeDynamicPng "image.png" img
--              return ()

myDefaultEnv :: EnvironmentOptions
myDefaultEnv = EnvironmentOptions "pdflatex" "" "magick" ["--shell-escape"] [] [] (UseSystemTempDir "latex-eqn-temp") "working"

myImageForFormula :: EnvironmentOptions -> FormulaOptions -> Formula -> IO (Either RenderError (Baseline, DynamicImage))
myImageForFormula (EnvironmentOptions {..}) (FormulaOptions {..}) eqn =
    bracket getCurrentDirectory setCurrentDirectory $ const $ withTemp $ \temp -> runExceptT $ do
      let doc = mconcat ["\\nonstopmode\n",
                 "\\documentclass[\n",
                 "  convert={\n",
                 "    convertexe=", imageMagickCommand, ",\n",
                 "    density=200,\n",
                 "    outext=.png,\n",
                 "    command=\\unexpanded{%\n",
                 "      \\convertexe\\space\n",
                 "      -density \\density\\space\n",
                 "      \\infile\\space\n",
                 "      -strip\\space\n",
                 "      \\outfile\n",
                 "    },\n",
                 "  },\n",
                 "]{standalone}\n", preamble,
                 "\\begin{document}\n",
                 "\\begin{", environment, "}\n",
                 ".",eqn,
                 "\\end{", environment, "}\n",
                 "\\end{document}\n"]
      io $ writeFile (temp </> tempFileBaseName <.> "tex") doc
      io $ setCurrentDirectory temp
      (c,o,e) <- io $ flip (readProcessWithExitCode latexCommand) "" $ latexArgs ++ [tempFileBaseName <.> "tex"]
      io $ removeFile (tempFileBaseName <.> "tex")
      io $ removeFile (tempFileBaseName <.> "aux")
      when (c /= ExitSuccess) $ do
        io $ removeFile (tempFileBaseName <.> "pdf")
        throwE $ LaTeXFailure (o ++ "\n" ++ e)
      -- (c',o',e') <- io $ flip (readProcessWithExitCode dvipsCommand) "" $ dvipsArgs ++ ["-q", "-E", "-o", tempFileBaseName <.> "ps", tempFileBaseName <.> "dvi"]
      io $ removeFile (tempFileBaseName <.> "pdf")
      -- when (c' /= ExitSuccess) $ throwE $ DVIPSFailure (o' ++ "\n" ++ e')
      -- (c'', o'', e'') <- io $ flip (readProcessWithExitCode imageMagickCommand) "" $
      --                           [ "-density", show dpi
      --                           , "-bordercolor", "none"
      --                           , "-border", "1x1"
      --                           , "-trim"
      --                           , "-background", "none"
      --                           , "-splice","1x0"
      --                           ] ++ imageMagickArgs ++
      --                           [ tempFileBaseName <.> "ps", tempFileBaseName <.> "png" ]
      -- io $ removeFile (tempFileBaseName <.> "ps")
      -- when (c'' /= ExitSuccess) $ throwE $ IMConvertFailure (o'' ++ "\n" ++ e'')
      imgM <- io $ readImage (tempFileBaseName <.> "png")
      img <- withExceptT ImageReadError $ hoistEither imgM
      io $ removeFile $ tempFileBaseName <.> "png"
      hoistEither $ postprocess img
  where
    io = withExceptT IOException . tryIO
    withTemp a = case tempDir of
      UseSystemTempDir f -> withSystemTempDirectory f a
      UseCurrentDir f -> withTempDirectory "." f a

postprocess :: DynamicImage -> Either RenderError (Int, DynamicImage)
postprocess (ImageY8 i)     = second ImageY8     <$> postprocess' i (pixelAt i 0 0)
postprocess (ImageY16 i)    = second ImageY16    <$> postprocess' i (pixelAt i 0 0)
postprocess (ImageYF i)     = second ImageYF     <$> postprocess' i (pixelAt i 0 0)
postprocess (ImageYA8 i)    = second ImageYA8    <$> postprocess' i (pixelAt i 0 0)
postprocess (ImageYA16 i)   = second ImageYA16   <$> postprocess' i (pixelAt i 0 0)
postprocess (ImageRGB8 i)   = second ImageRGB8   <$> postprocess' i (pixelAt i 0 0)
postprocess (ImageRGB16 i)  = second ImageRGB16  <$> postprocess' i (pixelAt i 0 0)
postprocess (ImageRGBF i)   = second ImageRGBF   <$> postprocess' i (pixelAt i 0 0)
postprocess (ImageRGBA8 i)  = second ImageRGBA8  <$> postprocess' i (pixelAt i 0 0)
postprocess (ImageRGBA16 i) = second ImageRGBA16 <$> postprocess' i (pixelAt i 0 0)
postprocess (ImageYCbCr8 i) = second ImageYCbCr8 <$> postprocess' i (pixelAt i 0 0)
postprocess (ImageCMYK8 i)  = second ImageCMYK8  <$> postprocess' i (pixelAt i 0 0)
postprocess (ImageCMYK16 i) = second ImageCMYK16 <$> postprocess' i (pixelAt i 0 0)


postprocess' :: (Eq a, Pixel a) => Image a -> a -> Either RenderError (Int, Image a)
postprocess' img bg
  = do startX <- note ImageIsEmpty $ listToMaybe $ dropWhile isEmptyCol [0.. imageWidth img - 1]
       let (dotXs, postXs) = break isEmptyCol [startX .. imageWidth img]
       postX <- note CannotDetectBaseline $ listToMaybe postXs
       let postY = (+ 2) $ average $ dotXs >>= (\x -> takeWhile (not . isEmpty x) (dropWhile (isEmpty x) [0..imageHeight img - 1]))
           average = uncurry div . foldl' (\(s,c) e -> (e+s,c+1)) (0,0)
           newHeight = imageHeight img
           newWidth  = imageWidth img - postX + 3
           baseline  = imageHeight img - postY
       let image = generateImage (pixelAt' . (+ postX)) newWidth newHeight
       return (baseline, image)
  where
    isEmptyCol x = all (isEmpty x) [0.. imageHeight img - 1]
    isEmpty x = (== bg) . pixelAt img x
    pixelAt' x y | x < imageWidth img && y < imageHeight img = pixelAt img x y
                 | otherwise = bg

--------------------------------------------------------------------------------
myInitFormulaCompilerDataURI :: CacheSize -> EnvironmentOptions
                           -> IO (PandocFormulaOptions -> Pandoc -> Compiler Pandoc)
myInitFormulaCompilerDataURI cs eo = do
    mImageForFormula <- curry <$> memoizeLru (Just cs) (uncurry drawFormula)
    let eachFormula x y = do
          putStrLn $ "    formula (" ++ environment x ++ ") \"" ++ equationPreview y ++ "\""
          mImageForFormula x y
    return $ \fo -> unsafeCompiler . convertAllFormulaeDataURIWith eachFormula fo
  where
    drawFormula x y = do
      putStrLn "      drawing..."
      myImageForFormula eo x y

-- | A formula compiler that does not use caching, which works in a more drop-in fashion, as in:
--
-- > compile $ pandocCompilerWithTransformM (compileFormulaeDataURI defaultEnv defaultPandocFormulaOptions)
--
myCompileFormulaeDataURI :: EnvironmentOptions
                       -> PandocFormulaOptions
                       -> Pandoc -> Compiler Pandoc
myCompileFormulaeDataURI eo po =
    let eachFormula x y = do
          putStrLn $ "    formula (" ++ environment x ++ ") \"" ++ equationPreview y ++ "\""
          putStrLn   "      drawing..."
          myImageForFormula eo x y
    in unsafeCompiler . convertAllFormulaeDataURIWith eachFormula po

equationPreview :: String -> String
equationPreview (dropWhile isSpace -> x)
      | length x <= 16 = x
      | otherwise      = take 16 $ filter (/= '\n') x ++ "..."
      
memoizeLru :: Ord a => Maybe Integer -> (a -> IO b) -> IO (a -> IO b)
memoizeLru msize action = do
    lru <- LRU.newAtomicLRU msize
    return $ \arg -> do
        mret <- LRU.lookup arg lru
        case mret of
            Just ret -> return ret
            Nothing -> do
                ret <- action arg
                LRU.insert arg ret lru
                return ret
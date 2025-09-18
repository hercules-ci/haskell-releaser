module Main (main) where

import Options.Applicative
import Releaser.Primitives
import System.IO (BufferMode (..), hSetBuffering, stderr, stdout)

data Options = Options
  { optNoSign :: Bool
  }

options :: Parser Options
options = Options
  <$> switch
      ( long "no-sign"
     <> help "Disable git tag signing" )

main :: IO ()
main = do
  opts <- execParser $ info (options <**> helper)
    ( fullDesc
   <> progDesc "Automate Haskell package release process"
   <> header "releaser - Haskell package releaser" )
  hSetBuffering stdout LineBuffering
  hSetBuffering stderr LineBuffering

  assertBasicCommands

  -- prepare release
  -- TODO: pass a list directories
  gitAssertEmptyStaging
  version <- cabalBumpVersion "."
  let release = "v" <> version
  changelogPrepare

  -- make release
  tarball <- cabalSdist "."
  gitCommit $ "Bump to " <> release
  gitTag (not $ optNoSign opts) release

  -- syncing github/hackage
  gitPush "origin"
  gitPushTags "origin"
  cabalUpload tarball

  -- make haddocks and upload them
  docsTarball <- cabalMakeHaddocks "."
  cabalUploadDocs docsTarball

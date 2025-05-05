{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE OverloadedRecordDot #-}

module Main (main) where

import Control.Monad (when)
import Options.Applicative
import Releaser.Primitives
import System.IO (BufferMode (..), hSetBuffering, stderr, stdout)

data Options = Options
  { pushDocs :: Bool
  }

main :: IO ()
main =
  execParser (info (helper <*> options) (fullDesc <> progDesc "Release a Haskell package"))
    >>= run

options :: Parser Options
options =
  Options
    <$> ( not
            <$> switch
              ( long "no-push-docs"
                  <> help "Do not push documentation to hackage"
                  <> showDefault
              )
        )

run :: Options -> IO ()
run opts = do
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
  gitTag release

  -- syncing github/hackage
  gitPush "origin"
  gitPushTags "origin"
  cabalUpload tarball

  -- make haddocks and upload them
  when opts.pushDocs do
    docsTarball <- cabalMakeHaddocks "."
    cabalUploadDocs docsTarball

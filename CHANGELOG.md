# Revision history for releaser

## 0.3.0.2 -- 2023-11-01

* New primitive `assertCommandExists`

* Make sure `git` and `cabal` are available before `releaser` does anything

* Primitive: `assertBasicCommands`, to perform the above check in custom scripts.

## 0.3.0.1 -- 2023-10-31

* Repo is now [github.com/hercules-ci/haskell-releaser](https://github.com/hercules-ci/haskell-releaser)

* Cabal 3.8 support

## 0.3.0.0 -- 2020-05-04

* Upload to haddock support

* LTS-15 support

## 0.2.1.0 -- 2019-12-02

* Use cabal v2 commands to avoid compatibility issues

## 0.2.0.0 -- 2019-09-16

* Write cabal versions using a regex
  
  Unfortunately, cabal api can't operate on Cabal AST,
  so we just resort to good old perl methods.

* If any of the primitives fail, wait to retry.

* Avoid checking out git branch since it's confusing.

## 0.1.0.0 -- 2019-09-09

* First version. Released on an unsuspecting world.

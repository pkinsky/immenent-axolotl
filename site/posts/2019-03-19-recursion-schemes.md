---
title: "Recusion Schemes and Functor Composition: from Peano Numbers to Lazy IO"
tags: haskell, recursion-schemes
---

In this post I'll show you how to use recursion schemes and functor composition to build a variety of useful data structures.

<!--more-->

Recursion schemes allow for the representation of recursive structures using the fix point of functors. There are plenty of popular libraries that implement them in Haskell, including `ekmett/recursion-schemes`, `sellout/yaya` and `pa-ba/compdata` (this last one has some interesting tools in `Multi`) but the core code is pretty concise and most libraries introduce a few extra layers of complexity so we’ll just define it inline here. This post will assume you’re familiar with at least the basics of recursion schemes. If you're not, reading the [sum type of way recursion schemes series](https://blog.sumtypeofway.com/an-introduction-to-recursion-schemes/) series up to catamorphisms and anamorphisms should be sufficient.

So, recursion schemes: first we need a way to take the fix point of some functor, here specialized to some `f` of kind `Type -> Type`. (`Multi` in `compdata` expands this somewhat)

```haskell
newtype Fix f = Fix { unFix :: f (Fix f) }
```

The type we use for `f` is called a pattern functor.

We’ll need a way to collapse these structures into a single value (`cata`) and a way to unfold them from a single seed value (`ana`).

```haskell
cata :: Functor f => (f a -> a) -> Fix f -> a
cata f = f . fmap (cata f) . unFix

ana :: Functor f => (a -> f a) -> a -> Fix f
ana f = Fix . fmap (ana f) . f
```

Cool. Usually this is where recursion schemes posts introduce some recursive `Expr` type to work with, but let’s see how far we can get with just `Functors` provided by the core libraries. `Maybe` has a `Functor` instance, let’s see what that gets us.

```haskell
type Nat = Fix Maybe

zero :: Nat
zero = Fix Nothing

succ :: Nat -> Nat
succ = Fix . Just
```

This is the Peano numbers. An interesting exercise, but fairly basic, and not something we'd ever use in place of `Int`. Let's move on (exercise for the reader: implement a function `Nat -> Int` using `cata` and a function `Int -> Nat` using `ana`). `(,) a` has a functor instance (in a perfect world we'd be able to write that as `(a,)`, but haskell doesn't support type-level `TupleSections` yet), let’s see what that gets us

```haskell
type NonTerminatingList a = Fix ((,) a)

ints :: Int -> NonTerminatingList Int
ints n = Fix (n, ints $ n + 1)
```

So this gets us a stream of values (fix point of `(,) a`), but we have no way to terminate our recursion, no base case. Haskell’s a lazy language so that’s kinda ok but we’d like to do something more interesting.

We can use a functor that just provides termination and get the Peano numbers, or a functor that just provides pairing with some element and get an infinite stream of values. These are both cool tricks, but not exactly what I'd call useful. This is where it gets interesting: functors compose freely, such that for any `f` and `g` where both `f` and `g` are functors `Compose f g` is also a functor. Compose is defined in `Data.Functor.Compose` as `newtype Compose f g a = Compose { getCompose :: f (g a) }`, so we can use it without needing to leave `base`. Let’s compose the two functors used above and see what happens!

```haskell
type List a = Fix (Compose Maybe ((,) a))

nil :: List a
nil = Fix (Compose Nothing)

cons :: a -> List a -> List a
cons x xs = Fix (Compose (Just (x, xs)))

mconcat' :: Monoid a => List a -> a
mconcat' = cata (maybe mempty (uncurry (<>)). getCompose)
```

So here we combine pairing via `(,) a` and potential termination via `Maybe` to get something isomorphic to Haskell's list type, `[]`. We can prove this by writing a trivial catamorphism that just uses some `Monoid` instance to concatenate everything.

```haskell
λ: mconcat' $ cons "abc" $ cons "def" nil
"abcdef"
```

It works as expected. Just for fun, let's see what happens if we switch the order in which we compose `Maybe` and `(,) a`.


```haskell
type NonEmpty a = Fix (Compose ((,) a) Maybe)
```

Check that out! Depending on the composition order you either end up with a list (in the case where `Maybe` precedes `(,) a` in the composition stack) or a nonempty list if the order is reversed. It’s kinda cool that these two data structures are, in some perhaps not-entirely-formal sense, duals - just swap the order of the functor stack and get two related structures.

What’s more, this isn’t only true of lists! 

```haskell
type Tree a = Fix (Compose (Either a) [])

leaf :: a -> Tree a
leaf x = Fix (Compose $ Left x)

node :: [Tree a] -> Tree a
node xs = Fix (Compose $ Right xs)
```

Trees can be defined as the composition of `Either a` (where `a` is some leaf type) and `[]`.

```haskell
mconcat'' :: Monoid a => Tree a -> a
mconcat'' = cata (either id mconcat . getCompose)
```

We can use this to collapse a simple tree down into a value, as expected

```haskell
λ: mconcat'' $ node [leaf "foo", node [leaf "bar", leaf "baz"]]
"foobarbaz"
```

We can also repeat the trick in which we swap the order of the functors used to get the (sort of) dual of `Tree a`.

```haskell
type Forest a = Fix (Compose [] (Either a))
```

In this case a `Tree` is sort of like the nonempty dual of `Forest` - unlike a forest, a tree will always contain at least one node.

We can also use this functor composition trick to interleave effectful actions with data structures (every monad is also a functor!), for example:

```haskell
type Stream m a = Fix (Compose m ((,) a))
```

Provides an infinite stream of values where accessing each successive value requires evaluating an effect in `m`. This can also be used to create lazy trees that, for example, represent a lazy directory traversal where the contents of any file or dir are only read into memory as required. Let’s create such a type now. We'll use `Compose` as an infix operator to aid in readability.

```haskell
import Data.Functor.Compose (Compose(..))
import qualified Data.ByteString as B

type Blob = B.ByteString
type LazyDirTree m = m
           `Compose` []
           `Compose` (,) FilePath
           `Compose` Either Blob
```

That’s a bit better. This is a bit more complex than the others, so let’s examine what we’re doing here in a bit more detail.

- `m`: some monadic effect
- `[]`: followed by some number of entities
- `(,) FilePath`: each of which is annotated with a name
- `Either Blob`: each of which is either a file blob base case or (via `Fix`) a recursive case

To show how this might be used, let's write some functions. The first will lazily read a directory tree to build up a `LazyDirTree`, the second will consume that tree, scanning each file's contents for some search string and printing any matching lines along with the file path in which they were found.

```haskell
import Data.Maybe (catMaybes)
import qualified System.Directory as Dir

readLazyDirTree
  :: FilePath
  -> Fix (LazyDirTree IO)
readLazyDirTree = ana alg
  where
    alg :: FilePath -> LazyDirTree IO FilePath
    alg path = Compose $ do
      putStrLn $ "reading dir at: " ++ path
      entries <-
        fmap ( fmap (\x -> path ++ "/" ++ x)
             . filter (/= ".")
             . filter (/= "..")
             )
             $ Dir.getDirectoryContents path
      entries' <- traverse categorize entries
      pure $ Compose $ catMaybes entries'
  
    categorize path = do
      isFile <- Dir.doesFileExist path
      if isFile
        then do
          putStrLn $ "reading file contents at: " ++ path
          fc <- B.readFile path -- strict file read
          pure $ Just $ Compose (path, Left fc)
        else do
          isDir <- Dir.doesDirectoryExist path
          if isDir
            then pure $ Just $ Compose (path, Right path)
            else pure Nothing
```

this reads a file lazily into memory, and prints log messages while doing so so you can see when different expressions are evaluated.

```haskell
import Control.Monad (join)
import qualified Data.ByteString.Char8 as B

type SearchResult = (FilePath, B.ByteString)

search :: B.ByteString -> Fix (LazyDirTree IO) -> IO [SearchResult]
search query = cata alg
  where
    alg :: LazyDirTree IO (IO [SearchResult]) -> IO [SearchResult]
    alg (Compose effect) = do
      (Compose entities) <- effect
      fmap join $ flip traverse entities $ \entry -> case entry of
        (Compose (path, Right next)) -> next -- todo: optional filter based on path
        (Compose (path, Left blob))  -> do
          let results = fmap (path,) . filter (B.isInfixOf query) $ B.lines blob
          unless (null results) $ putStrLn $ "found results at: " ++ path
          pure results

grep :: B.ByteString -> FilePath -> IO [SearchResult]
grep query = search query . readLazyDirTree
```

`search` prints a message when a match is found so we can see how file reads and searches are interleaved. Let's try it out, on another project of mine that has some haskell code in nested directory trees:

```haskell
λ: results <- grep "import qualified" "../merkle-dag-compare/src"
reading dir at: ../merkle-dag-compare/src
reading file contents at: ../merkle-dag-compare/src/Compare.hs
reading file contents at: ../merkle-dag-compare/src/Main.hs
reading file contents at: ../merkle-dag-compare/src/FileIO.hs
reading dir at: ../merkle-dag-compare/src/Util
reading file contents at: ../merkle-dag-compare/src/Util/These.hs
reading file contents at: ../merkle-dag-compare/src/Util/RecursionSchemes.hs
reading file contents at: ../merkle-dag-compare/src/Util/MyCompose.hs
reading file contents at: ../merkle-dag-compare/src/Util/Util.hs
found results at: ../merkle-dag-compare/src/Util/These.hs
found results at: ../merkle-dag-compare/src/Util/MyCompose.hs
found results at: ../merkle-dag-compare/src/Compare.hs
reading dir at: ../merkle-dag-compare/src/Diff
reading file contents at: ../merkle-dag-compare/src/Diff/Types.hs
reading dir at: ../merkle-dag-compare/src/Merkle
reading file contents at: ../merkle-dag-compare/src/Merkle/Store.hs
reading file contents at: ../merkle-dag-compare/src/Merkle/Types.hs
reading dir at: ../merkle-dag-compare/src/Merkle/Tree
reading file contents at: ../merkle-dag-compare/src/Merkle/Tree/Types.hs
reading file contents at: ../merkle-dag-compare/src/Merkle/Tree/Encoding.hs
reading dir at: ../merkle-dag-compare/src/Merkle/Store
reading file contents at: ../merkle-dag-compare/src/Merkle/Store/Deref.hs
reading file contents at: ../merkle-dag-compare/src/Merkle/Store/FileSystem.hs
reading file contents at: ../merkle-dag-compare/src/Merkle/Store/InMemory.hs
found results at: ../merkle-dag-compare/src/Merkle/Store/FileSystem.hs
found results at: ../merkle-dag-compare/src/Merkle/Store/InMemory.hs
found results at: ../merkle-dag-compare/src/FileIO.hs

λ: traverse print results
("../merkle-dag-compare/src/Util/These.hs","import qualified Data.Hashable as Hash")
("../merkle-dag-compare/src/Util/These.hs","import qualified Data.HashMap.Strict as Map")
("../merkle-dag-compare/src/Util/MyCompose.hs","import qualified Data.Functor.Compose as FC")
("../merkle-dag-compare/src/Compare.hs","import qualified Data.HashMap.Strict as Map")
("../merkle-dag-compare/src/Compare.hs","import qualified Data.Set as Set")
("../merkle-dag-compare/src/Merkle/Store/FileSystem.hs","import qualified Data.Aeson as AE")
("../merkle-dag-compare/src/Merkle/Store/FileSystem.hs","import qualified Data.ByteString.Lazy as B")
("../merkle-dag-compare/src/Merkle/Store/InMemory.hs","import qualified Data.Hashable as Hash")
("../merkle-dag-compare/src/Merkle/Store/InMemory.hs","import qualified Data.Map as Map")
("../merkle-dag-compare/src/FileIO.hs","import qualified Data.List as List")
("../merkle-dag-compare/src/FileIO.hs","import qualified System.Directory as Dir")
```

Cool, so we built `grep` with lazy directory tree traversal, all using only a single `newtype` and some functors found in `base` (plus some utility code from `directory` and `bytestring`). I think that qualifies as a speedrun! In the next post I'll show you how to use these techniques to do cool things with Merkle trees.

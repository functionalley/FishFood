# 2013-07-16 Dr. Alistair Ward <fishfood@functionalley.eu>

## 0.0.0.1
* First version of the package.

## 0.0.0.2
* Added file "**man/man1/fishfood.1**" & *.spec*-file to the distribution.

## 0.0.1.0
* Migrated all but the I/O, from module "**Main**" to a new module "**FishFood.Profiler**".
* Added module "**FishFood.Test**", containing **Test.QuickCheck**-implementation.
* Added Command-line options;
	+ "**--deriveProbabilityMassFunction**",
	+ "**--binSizeRatio**",
	+ "**--runQuickChecks**".

## 0.0.1.1
* Added files to build *.deb* to the *.cabal*-file.

## 0.0.1.2
* Added flag "**--runQuickChecks**" to file "**man/man1/fishfood.1**" & corrected typo.
* Improved the syntax of flag "**--verbosity**" in the usage-message.
* Tested with **haskell-platform-2013.2.0.0**.

## 0.0.1.3
* In module "**FishFood.Data.File**", replaced `Control.Exception.throw` with `Control.Exception.throwIO`.
* Either replaced instances of `(<$>)` with `fmap` to avoid ambiguity between modules "**Control.Applicative**" & "**Prelude**" which (from package "**base-4.8**") also exports this symbol, or hid the symbol when importing the module "**Prelude**".
* In module "**Main**", redirected version-message to stderr.

## 0.0.1.4
* Added the compiler to the output returned for the command-line option "**--version**".
* In module "**FishFood.Data.File.hs**", replaced the use of the package "**unix**" with the package "**directory**", for compatibility with **Windows**.

## 0.0.1.5
* Added "**Default-language**"-specification to the *.cabal*-file.
* Added file "**README.markdown**".
* Converted this file to markdown-format.
* Replaced `System.Exit.exitWith System.Exit.ExitSuccess` with `System.Exit.exitSuccess`.
* Moved the entry-point to the test-suite from module "**Main**" to "**Test**", both to integrate with **cabal** & to minimise the dependencies of the executable.
* Partitioned the source-files into directories "**src-lib**", "**src-exe**", & "**src-test**", & referenced them individually from the *.cabal*-file to avoid repeated compilation.
* Used **CPP** to control the import of symbols from **Control.Applicative**.

## 0.0.1.6
* Corrected the markdown-syntax in this file.
* Amended to call "**error**" rather than "**Control.Monad.fail**", since the **String**-argument for the latter is discarded in **Monad**-implementations other than **IO**.
* Uploaded to [GitHub](https://github.com/functionalley/FishFood.git).
* Simplified file **src-test/Main.hs**.

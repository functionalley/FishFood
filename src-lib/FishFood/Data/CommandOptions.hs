{-
	Copyright (C) 2013-2015 Dr. Alistair Ward

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
-}
{- |
 [@AUTHOR@]	Dr. Alistair Ward

 [@DESCRIPTION@]

	* Defines options for program-operation.

	* Defines an appropriate default value, which is expected to be over-ridden on the command-line.

	* Self-validates.
-}

module FishFood.Data.CommandOptions(
-- * Types
-- ** Type-synonyms
	BinSizeDelta,
-- ** Data-types
	CommandOptions(
--		MkCommandOptions,
		getBinSizeDelta,
		getDeriveProbabilityMassFunction,
		getNDecimalDigits,
		getVerbosity
	),
-- * Functions
-- ** Constructor
	mkCommandOptions,
-- ** Mutators
	setBinSizeIncrement,
	setBinSizeRatio
) where

import qualified	Data.Default
import qualified	Data.Maybe
import qualified	Distribution.Verbosity
import qualified	FishFood.Data.File	as Data.File
import qualified	ToolShed.SelfValidate

-- | Either an arithmetic size-increase for which there's a default, or a geometric size-ratio.
type BinSizeDelta ratio	= Either (Maybe Data.File.FileSize) ratio

-- | Declares a record to contain command-line options.
data CommandOptions ratio	= MkCommandOptions {
	getBinSizeDelta				:: BinSizeDelta ratio,			-- ^ Either the arithmetic size-increase (defaulting to one standard-deviation), or the geometric size-ratio, of the sequence of bins into which files are categorized.
	getDeriveProbabilityMassFunction	:: Bool,				-- ^ Whether to derive the "Probability mass function" rather than the "Frequency-distribution".
	getNDecimalDigits			:: Int,					-- ^ The precision to which fractional data is displayed.
	getVerbosity				:: Distribution.Verbosity.Verbosity	-- ^ The threshold for ancillary information-output.
} deriving Show

instance Data.Default.Default (CommandOptions ratio)	where
	def = MkCommandOptions {
		getBinSizeDelta				= Left Nothing,	-- Interpreted as one standard-deviation.
		getDeriveProbabilityMassFunction	= False,
		getNDecimalDigits			= 3,
		getVerbosity				= Distribution.Verbosity.normal
	}

instance (Num ratio, Ord ratio, Show ratio) => ToolShed.SelfValidate.SelfValidator (CommandOptions ratio)	where
	getErrors commandOptions@MkCommandOptions {
		getBinSizeDelta				= binSizeDelta,
		getDeriveProbabilityMassFunction	= deriveProbabilityMassFunction,
		getNDecimalDigits			= nDecimalDigits
	} = map snd $ filter fst [
		(
			either (Data.Maybe.maybe False (<= 0)) (<= 1) binSizeDelta,
			"either the bin-size's arithmetic increase must exceed zero, or it's geometric ratio must exceed one; " ++ show commandOptions ++ "."
		), (
			deriveProbabilityMassFunction && nDecimalDigits < 1,
			"the number of decimal digits must exceed zero to adequately represent probabilities; " ++ show commandOptions ++ "."
		),
		let
			maxNDecimalDigits	= floor $ fromIntegral (
				floatDigits (
					undefined :: Double	-- CAVEAT: the actual type could be merely 'Float', but that's currently unknown.
				)
			 ) * (logBase 10 2 :: Double)
		in (
			nDecimalDigits > maxNDecimalDigits,
			"the number of decimal digits shouldn't exceed " ++ show maxNDecimalDigits ++ "; " ++ show commandOptions ++ "."
		)
	 ]

-- | Smart constructor.
mkCommandOptions :: (Num ratio, Ord ratio, Show ratio) => BinSizeDelta ratio -> Bool -> Int -> Distribution.Verbosity.Verbosity -> CommandOptions ratio
mkCommandOptions binSizeDelta deriveProbabilityMassFunction nDecimalDigits verbosity
	| ToolShed.SelfValidate.isValid commandOptions	= commandOptions
	| otherwise					= error $ "FishFood.Data.CommandOptions.mkCommandOptions:\t" ++ ToolShed.SelfValidate.getFirstError commandOptions
	where
		commandOptions	= MkCommandOptions binSizeDelta deriveProbabilityMassFunction nDecimalDigits verbosity

-- | Mutator.
setBinSizeIncrement :: Data.File.FileSize -> CommandOptions ratio -> CommandOptions ratio
setBinSizeIncrement fileSize commandOptions	= commandOptions { getBinSizeDelta = Left $ Just fileSize }

-- | Mutator.
setBinSizeRatio :: ratio -> CommandOptions ratio -> CommandOptions ratio
setBinSizeRatio ratio commandOptions	= commandOptions { getBinSizeDelta = Right ratio }

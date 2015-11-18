{-
	Copyright (C) 2013 Dr. Alistair Ward

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

 [@DESCRIPTION@]	Profiles lists of file-sizes.
-}

module FishFood.Profiler(
-- * Types
-- ** Type-synonyms
--	Probability,
--	Result,
--	FileSizeDistribution,
-- * Functions
	calculateFileSizeDistribution,
	formatFileSizeDistribution,
-- ** Accessors
	getFileSize,
	getValue
) where

import			Control.Arrow((&&&),(***))
import qualified	Control.Monad.Writer
import qualified	Data.List
import qualified	Data.Map
import qualified	Data.Maybe
import qualified	FishFood.Data.CommandOptions	as Data.CommandOptions
import qualified	FishFood.Data.File		as Data.File
import			FishFood.Data.Verbosity()
import qualified	Text.Printf
import qualified	ToolShed.Defaultable

-- | Define a type to represent the fractional closed unit-interval.
type Probability	= Double

-- | Defines either the number of files or the probability that a files has a specific size.
type Result	= (Data.File.FileSize, Either Int {-file-count-} Probability)

-- | Accessor.
getFileSize :: Result -> Data.File.FileSize
getFileSize	= fst

-- | Accessor.
getValue :: Result -> Either Int {-file-count-} Probability
getValue	= snd

-- | Defines either a /Probability Mass Function/ or /Frequency-distribution/.
type FileSizeDistribution	= [Result]

-- | Calculates either the /Probability Mass Function/ or /Frequency-distribution/ for the specified files.
calculateFileSizeDistribution :: (Floating ratio, RealFrac ratio) => Data.CommandOptions.CommandOptions ratio -> [Data.File.FileSize] -> Control.Monad.Writer.Writer [String] FileSizeDistribution
calculateFileSizeDistribution commandOptions fileSizes	= let
	binSizeDelta			= Data.CommandOptions.getBinSizeDelta commandOptions
	deriveProbabilityMassFunction	= Data.CommandOptions.getDeriveProbabilityMassFunction commandOptions
	nDecimalDigits			= Data.CommandOptions.getNDecimalDigits commandOptions

	mean, standardDeviation :: Double
	(nFiles, mean, standardDeviation)	= Data.File.getFileSizeStatistics fileSizes
 in do
	Control.Monad.Writer.tell [Text.Printf.printf "Files=%d, mean=%.*f, standard-deviation=%.*f" nFiles nDecimalDigits mean nDecimalDigits standardDeviation]

	return {-to Writer-monad-} $ if standardDeviation == 0
		then return {-to List-monad-} . (,) (head fileSizes) $ if deriveProbabilityMassFunction
			then Right 1		-- i.e. certainty.
			else Left nFiles	-- i.e. all.
		else let
			getDefaultedBinSizeIncrement :: Maybe Data.File.FileSize -> Data.File.FileSize
			getDefaultedBinSizeIncrement	= Data.Maybe.fromMaybe $ round standardDeviation `max` 1 {-minimum increment-}	-- CAVEAT: guard against subsequent division by zero or infinite iteration.

			calculatedBinSizes :: [Data.File.FileSize]
			calculatedBinSizes	= map (
				\fileSize	-> either (
					div {-round down-} fileSize . getDefaultedBinSizeIncrement {-non-zero-}
				) (
					floor {-round down-} . (`logBase` fromIntegral fileSize)	-- CAVEAT: converts file-size 0, to bin-size -infinity.
				) binSizeDelta
			 ) fileSizes	-- Each bin spans the semi-closed integral interval [size, succ size), so round down fractional values to match the lower bin.

			initialFrequencyDistribution :: Data.Map.Map Data.File.FileSize Int
			initialFrequencyDistribution	= Data.Map.fromAscList . (
				`zip` repeat 0	-- The initial file-count.
			 ) . takeWhile (
				<= maximum calculatedBinSizes
			 ) . dropWhile (
				< minimum calculatedBinSizes
			 ) $ either (
				\maybeBinSizeIncrement	-> iterate (+ getDefaultedBinSizeIncrement {-non-zero-} maybeBinSizeIncrement) 0
			 ) (
				\binRatio		-> map round {-file-sizes are integral-} $ iterate (* binRatio) 1	-- The sequence could be started at fractional values in the open unit-interval, but the only value less than 1 which may be required is 0 (which isn't a sequence-member), which will be created later on demand.
			 ) binSizeDelta

			mapBinSizeToFileSize :: Data.Map.Map Data.File.FileSize value -> Data.Map.Map Data.File.FileSize value
			mapBinSizeToFileSize	= Data.Map.mapKeys $ \binSize -> either (
				(* binSize) . getDefaultedBinSizeIncrement
			 ) (
				ceiling {-round up-} . (^^ binSize)	-- Converts binSize -infinity, back to file-size 0.
			 ) binSizeDelta	-- Represent each bin by the minimum file-size it can accept.
		in Data.Map.toList . (
			if deriveProbabilityMassFunction
				then Data.Map.map Right . mapBinSizeToFileSize . Data.Map.map ((/ fromIntegral nFiles {-non-zero-}) . fromIntegral)
				else Data.Map.map Left . mapBinSizeToFileSize
		) $ foldr (
			Data.Map.insertWith (+) `flip` 1	-- Count the files allocated to each bin.
		) initialFrequencyDistribution calculatedBinSizes

-- | Formats a file-size distribution.
formatFileSizeDistribution :: Data.CommandOptions.CommandOptions ratio -> FileSizeDistribution -> String
formatFileSizeDistribution commandOptions	= Data.List.intercalate "\n" . map (
	\(fileSize, value)	-> fileSize ++ " " ++ value
 ) . (
	if Data.CommandOptions.getVerbosity commandOptions > ToolShed.Defaultable.defaultValue
		then (
			[
				(
					($ (fileSizeWidth, fileSizeHeader)) &&& ($ (valueWidth, valueHeader))
				) . uncurry $ Text.Printf.printf "%*s",	-- Column-headers.
				(`replicate` '=') *** (`replicate` '=') $ columnWidths	-- Separator-bar.
			] ++
		) -- Section.
		else id
 ) . map (
	Text.Printf.printf "%*d" fileSizeWidth *** either (
		Text.Printf.printf "%*d" valueWidth
	) (
		Text.Printf.printf "%.*f" $ Data.CommandOptions.getNDecimalDigits commandOptions
	)
 ) where
	fileSizeHeader, valueHeader :: String
	headers@(fileSizeHeader, valueHeader)	= (,) "Bin-size" $ if Data.CommandOptions.getDeriveProbabilityMassFunction commandOptions then "Probability" else "Frequency"

	fileSizeWidth, valueWidth :: Int
	columnWidths@(fileSizeWidth, valueWidth)	= (`max` 10) . length *** length $ headers	-- CAVEAT: the data-length may exceed the header-length, so define a minimum.


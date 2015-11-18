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

 [@DESCRIPTION@]	Defines /QuickCheck/-properties for 'Profiler'.
-}

module FishFood.Test.Profiler(
-- * Constants
	results
) where

import qualified	Control.Monad.Writer
import qualified	Data.Either
import qualified	Data.Set
import qualified	FishFood.Data.CommandOptions		as Data.CommandOptions
import qualified	FishFood.Data.File			as Data.File
import qualified	FishFood.Profiler			as Profiler
import qualified	FishFood.Test.Data.CommandOptions	as Test.Data.CommandOptions
import qualified	Test.QuickCheck
import			Test.QuickCheck((==>))
import qualified	ToolShed.SelfValidate

-- | The constant test-results for this data-type.
results :: IO [Test.QuickCheck.Result]
results	= mapM Test.QuickCheck.quickCheckResult [prop_calculateProbabilityMassFunction, prop_calculateFileSizeFrequencyDistribution, prop_attendance]	where
	prop_calculateProbabilityMassFunction, prop_calculateFileSizeFrequencyDistribution, prop_attendance :: Test.Data.CommandOptions.CommandOptions -> [Data.File.FileSize] -> Test.QuickCheck.Property
	prop_calculateProbabilityMassFunction commandOptions fileSizes	= not (null fileSizes) && ToolShed.SelfValidate.isValid commandOptions' ==> Test.QuickCheck.label "prop_calculateProbabilityMassFunction" . (<= recip 1000000) . (+ negate 1) . sum . Data.Either.rights {-probabilities-} . map Profiler.getValue . fst {-distribution-} . Control.Monad.Writer.runWriter . Profiler.calculateFileSizeDistribution commandOptions' $ map abs fileSizes	where
		commandOptions'	= commandOptions { Data.CommandOptions.getDeriveProbabilityMassFunction	= True }

	prop_calculateFileSizeFrequencyDistribution commandOptions fileSizes	= not (null fileSizes) && ToolShed.SelfValidate.isValid commandOptions' ==> Test.QuickCheck.label "prop_calculateFileSizeFrequencyDistribution" . (== length fileSizes) . sum . Data.Either.lefts {-frequency-} . map Profiler.getValue . fst {-distribution-} . Control.Monad.Writer.runWriter . Profiler.calculateFileSizeDistribution commandOptions' $ map abs fileSizes	where
		commandOptions'	= commandOptions { Data.CommandOptions.getDeriveProbabilityMassFunction	= False }

	prop_attendance commandOptions fileSizes	= not (null fileSizes') && ToolShed.SelfValidate.isValid commandOptions' ==> Test.QuickCheck.label "prop_attendance" . (
		== Data.Set.fromList fileSizes'
	 ) . Data.Set.fromList . map Profiler.getFileSize . filter (
		(/= 0) . either fromIntegral id . Profiler.getValue	-- Remove file-sizes which match zero actual files.
	 ) . fst {-distribution-} . Control.Monad.Writer.runWriter $ Profiler.calculateFileSizeDistribution commandOptions' fileSizes'	where
		fileSizes'	= map abs fileSizes

		commandOptions' :: Test.Data.CommandOptions.CommandOptions
		commandOptions'	= Data.CommandOptions.setBinSizeIncrement 1 commandOptions


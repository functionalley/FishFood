{-
	Copyright (C) 2013-2014 Dr. Alistair Ward

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

 [@DESCRIPTION@]	Allows one to find the size of a file, & to gather statistics on a population.
-}

module FishFood.Data.File(
-- * Types
-- ** Type-synonyms
	FileSize,
-- * Functions
	findSize,
	getFileSizeStatistics
) where

import qualified	Control.Exception
import qualified	Factory.Math.Statistics
import qualified	System.Directory
import qualified	System.IO
import qualified	System.IO.Error

-- | A type-synonym specifically to hold file-sizes (in bytes).
type FileSize	= Integer	-- Matches the return-type of 'IO.hFileSize'.

-- | Get the size of the specified file.
findSize :: System.IO.FilePath -> IO FileSize
findSize f	= do
	fileExists	<- System.Directory.doesFileExist f

	if fileExists
		then System.IO.withFile f System.IO.ReadMode System.IO.hFileSize
		else {-not a file-} Control.Exception.throwIO $ System.IO.Error.mkIOError System.IO.Error.illegalOperationErrorType ("file=" ++ show f ++ " either doesn't exist or has an unexpected type") Nothing (Just f)

-- | Acquire statistics related to a list of file-sizes.
getFileSizeStatistics
	:: (Fractional mean, Floating standardDeviation)
	=> [FileSize]
	-> (Int, mean, standardDeviation)	-- ^ (The population-size, Mean size, Standard-deviation).
getFileSizeStatistics fileSizes	= (
	length fileSizes,
	Factory.Math.Statistics.getMean fileSizes,
	Factory.Math.Statistics.getStandardDeviation fileSizes
 )


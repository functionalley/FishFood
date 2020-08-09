{-# OPTIONS_GHC -fno-warn-orphans #-}
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
	The levels of program-output.
	N.B.: the data-type is coincidentally similar to 'Distribution.Verbosity.Internal.VerbosityLevel'.
-}

module FishFood.Data.Verbosity(
-- * Types
-- ** Data-types
	Verbosity(),
-- * Constants
	range
) where

import qualified	Data.Default

-- | Define the levels of program-output.
data Verbosity
	= Silent
	| Normal
	| Verbose
	| Deafening
	deriving (Enum, Eq, Ord, Read, Show)

instance Data.Default.Default Verbosity	where
	def	= Normal

instance Bounded Verbosity where
	minBound	= Silent
	maxBound	= Deafening

-- | The constant complete range of values.
range :: [Verbosity]
range	= [minBound .. maxBound]

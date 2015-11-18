{-# OPTIONS_GHC -fno-warn-orphans #-}
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

 [@DESCRIPTION@]	Instance-definitions for 'Distribution.Verbosity.Verbosity'.
-}

module FishFood.Data.Verbosity(
-- * Constants
	range
) where

import qualified	Distribution.Verbosity
import qualified	ToolShed.Defaultable

instance ToolShed.Defaultable.Defaultable Distribution.Verbosity.Verbosity	where
	defaultValue	= Distribution.Verbosity.normal

-- | The constant complete range of values.
range :: [Distribution.Verbosity.Verbosity]
range	= [minBound .. maxBound]

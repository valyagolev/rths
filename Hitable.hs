{-# LANGUAGE ExistentialQuantification, FlexibleInstances, TypeFamilies #-}

module Hitable where

import Data.Vec3
import Data.Maybe
import Data.Function
import Data.List

import Vectors
import Material



data Hitable_ = forall a . Hitable a => MkHitable a

instance Hitable Hitable_ where
 hit (MkHitable a) r mn mx = hit a r mn mx

instance Hitable [Hitable_] where
  hit objects r mn mx = listToMaybe $ sortBy (compare `on` hitT) $ catMaybes $ map (\o -> hit o r mn mx) objects

rayPointAt :: Ray -> Double -> CVec3
rayPointAt (Ray o d) t = o <+> (mapv (*t) d)

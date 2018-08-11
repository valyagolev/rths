{-# LANGUAGE Rank2Types, ExistentialQuantification #-}

module Material where

import Data.Vec3
import Control.Monad.Random

import Random
import Vectors


type MaterialScatterF g = RandomGen g => Ray -> Hit -> Rand g Scatter

data Material = Material {scatterF :: forall g. RandomGen g => MaterialScatterF g}


-- mkLambertian :: RandomGen g => CVec3 -> MaterialScatterF g
-- mkLambertian albedo rayIn hit =
--   target >>= \t -> return $ Just (albedo, Ray (hitP hit) t)
--   -- p + normal + random - p ?
--   where target = (hitNormal hit <+>) <$> randomInUnitBall

mkLambertian :: CVec3 -> Material
mkLambertian albedo = Material m
  where m rayIn hit =
          target >>= \t -> return $ Just (albedo, Ray (hitP hit) t)
          where
              -- p + normal + random - p ?
            target = (hitNormal hit <+>) <$> randomInUnitBall

mkMetal :: Double -> CVec3 -> Material
mkMetal fuzz albedo = Material m
  where
    m rayIn hit =
      scattered >>=
        \sc ->
          return (if didScatter
                    then Just (attenuation, sc)
                    else Nothing)
        where reflected = reflect (normalize $ direction rayIn) (hitNormal hit)
              scattered = randomInUnitBall >>= \r -> return $ Ray (hitP hit) (reflected <+> (fuzz *. r))
              attenuation = albedo
              didScatter = reflected .* (hitNormal hit) > 0

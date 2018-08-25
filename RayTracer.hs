module RayTracer where

import Data.Vec3
import Control.Monad.Random
import Data.List
import Data.Maybe
import Data.Function

import Types
import Vectors
import World
import Random


maxFloat :: Double
maxFloat = fromIntegral $ snd $ floatRange (0.5::Double)



-- y :: Vec3 a -> Double
y v = y'
  where (_, y', _) = toXYZ v



sky :: Ray -> Color
sky r = ((1.0 - t) *. CVec3 1 1 1) <+> (t *. CVec3 0.5 0.7 1.0)
  where un = normalize $ direction r
        t = (y un + 1) * 0.5

traceColorK :: RandomGen g => Int -> Double -> [Hitable_] -> Ray -> Rand g Color
traceColorK i k objects r = case (hit objects r 0.00001 maxFloat) of
  -- Just (Hit t p n) -> 0.5 *. (CVec3 1 1 1 <+> n)
  Nothing -> return $ mapv (k*) $ sky r
  Just (Hit t p n sc) ->
    if i < 50
      then undefined >>= (\sc ->
        case sc of
          Nothing -> return $ CVec3 0 0 0
          Just (attenuation, scattered) ->
            (attenuation *<>*) <$> traceColorK (i+1) k objects scattered)
      else return $ CVec3 0 0 0



traceColor :: RandomGen g => [Hitable_] -> Ray -> Rand g Color
traceColor objects r = traceColorK 0 1 objects r
-- traceColor _ r = return $ sky r

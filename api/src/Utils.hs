{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DataKinds #-}
{-# OPTIONS_GHC -Wno-deferred-out-of-scope-variables #-}
{-# LANGUAGE FlexibleInstances #-}


module Utils where

import Data.Aeson.Types (Value (String), Object)
import qualified Servant.Auth as Servant.Auth.Server
import Servant.Auth (JWT)
import Db.User (User')
import qualified Servant.Auth.Server
import Core.User (User, UserId (UserId))
import Data.Text (Text, unpack)
import Data.HashMap.Strict (HashMap, lookup, empty)
import Data.Functor.Identity (Identity)
import Db.Pipeline (Pipeline (Pipeline), PipelineId (PipelineId), pipelineLastTrigger, pipelineTriggerCount, pipelineError, pipelineEnabled, pipelineUserId, pipelineParams, pipelineType, pipelineName, pipelineId)
import Core.Pipeline (PipelineParams (PipelineParams))
import Data.Time (UTCTime (UTCTime), fromGregorian, secondsToDiffTime)
import Data.Default (Default, def)
import Data.Aeson (Value(Number, Object), decode, ToJSON, FromJSON)
import Data.Int (Int64)
import Data.Scientific ( toBoundedInteger )
import GHC.Generics (Generic)

mapInd :: (a -> Int -> b) -> [a] -> [b]
mapInd f l = zipWith f l [0 ..]

lookupObjString :: Object -> Text -> Maybe Text
lookupObjString obj key = case Data.HashMap.Strict.lookup key obj of
    Just (String x) -> Just x
    _ -> Nothing

lookupObjObject :: Object -> Text -> Maybe Object
lookupObjObject obj key = case Data.HashMap.Strict.lookup key obj of
    Just (Object x) -> Just x
    _ -> Nothing


lookupObjInt :: Object -> Text -> Maybe Int64
lookupObjInt obj key = case Data.HashMap.Strict.lookup key obj of
    Just (Number x) -> toBoundedInteger x
    _ -> Nothing

uncurry3 :: (a -> b -> c -> d) -> (a, b, c) -> d
uncurry3 f (a, b, c) = f a b c

instance Default PipelineParams where
    def = PipelineParams empty

instance Default (Pipeline Identity) where
    def = Pipeline { pipelineId = PipelineId 1
    , pipelineName = ""
    , pipelineType = ""
    , pipelineParams = def
    , pipelineUserId = UserId 1
    , pipelineEnabled = True
    , pipelineError = Nothing
    , pipelineTriggerCount = 0
    , pipelineLastTrigger = Nothing
    }

type UserAuth = Servant.Auth.Server.Auth '[JWT] User
type AuthRes = Servant.Auth.Server.AuthResult User


{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleInstances #-}
module Db.Reaction where

import Data.Aeson
    ( eitherDecode, defaultOptions, FromJSON, ToJSON )
import Data.Aeson.TH ( deriveJSON )
import GHC.Generics (Generic)
import Rel8 (DBEq, DBType, Column, Rel8able, ReadShow (ReadShow), JSONBEncoded (JSONBEncoded), Result, TableSchema (TableSchema, name, schema, columns), Name, Query, Expr, where_, (==.), lit, each)
import Data.Text (Text)
import Data.Int (Int64)

import Db.Pipeline (PipelineId)
import Core.Reaction
import Data.Functor.Identity (Identity)

newtype ReactionId = ReactionId { toInt64 :: Int64 }
  deriving newtype (DBEq, DBType, Eq, Show, Num, FromJSON, ToJSON)
  deriving stock (Generic)

data Reaction f = Reaction
  { reactionId          :: Column f ReactionId
  , reactionType        :: Column f ReactionType
  , reactionParams      :: Column f ReactionParams
  , reactionPipelineId  :: Column f PipelineId
  , reactionOrder       :: Column f Int64
  } deriving stock (Generic)
    deriving anyclass (Rel8able)

deriving stock instance f ~ Result => Show (Reaction f)


instance ToJSON (Reaction Identity)
instance FromJSON (Reaction Identity)

reactionSchema :: TableSchema (Reaction Name)
reactionSchema = TableSchema
  { name = "reactions"
  , schema = Nothing
  , columns = Reaction
      { reactionId = "id"
      , reactionOrder = "order"
      , reactionType = "type"
      , reactionParams = "params"
      , reactionPipelineId = "pipelineId"
      }
  }
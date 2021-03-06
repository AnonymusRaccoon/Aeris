{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeOperators #-}

module Api.Pipeline where

import App (AppM, State (State, dbPool))
import Control.Monad.IO.Class (MonadIO (liftIO))
import Control.Monad.Trans.Reader (ask)
import Core.Pipeline (PipelineParams (PipelineParams), PipelineType)
import Core.Reaction (ReactionParams, ReactionType)
import Data.Aeson (FromJSON, ToJSON, defaultOptions, eitherDecode, Value (Bool))
import Data.Aeson.TH (deriveJSON)
import Data.Functor.Identity (Identity)
import Data.Int (Int64)
import Data.Text (Text, pack)
import Db.Pipeline (Pipeline (Pipeline, pipelineType, pipelineUserId, pipelineId, pipelineEnabled), PipelineId (PipelineId, toInt64), getPipelineById, insertPipeline, pipelineName, pipelineParams, pipelineSchema, pipelineId)
import Db.Reaction (Reaction (Reaction, reactionOrder, reactionParams, reactionType), ReactionId (ReactionId), getReactionsByPipelineId, insertReaction)
import GHC.Generics (Generic)
import Hasql.Statement (Statement)
import Hasql.Transaction (Transaction, statement)
import Rel8 (asc, each, insert, limit, orderBy, select, Expr, lit)
import Repository
    ( createPipeline,
      getPipelineById',
      getPipelineByUser,
      createReaction,
      getReactionsByPipelineId', getWorkflow', getWorkflowsByUser', getWorkflows', createReactions, putWorkflow, delWorkflow, getUserById' )
import Servant (Capture, Get, JSON, err401, throwError, type (:>), NoContent (NoContent), err400, err403, err500)
import Servant.API (Delete, Post, Put, ReqBody, QueryParam)
import Servant.API.Generic ((:-))
import Servant.Server.Generic (AsServerT)
import Utils (mapInd, UserAuth, AuthRes)
import Core.User (UserId(UserId), User (User), ExternalToken)
import Servant.Auth.Server (AuthResult(Authenticated))
import Network.HTTP.Simple (setRequestBodyJSON, httpJSONEither, setRequestMethod, addRequestHeader, parseRequest, httpBS, setRequestPath)
import Network.HTTP.Client.Conduit (Request(requestBody), httpNoBody)
import Data.ByteString (ByteString)
import Data.Text.Encoding (encodeUtf8)
import System.Environment.MrEnv (envAsString)
import Data.Default (def)
import Db.User (UserDB(..))
import Control.Applicative (Alternative((<|>)))
import GHC.TypeLits (ErrorMessage(Text))
import Data.Time (UTCTime)

data PipelineData = PipelineData
    { name :: Text
    , pType :: PipelineType
    , pParams :: PipelineParams
    , enabled :: Bool
    }

data ReactionData = ReactionData
    { rType :: ReactionType
    , rParams :: ReactionParams
    }

data PostPipelineData = PostPipelineData
    { action :: PipelineData
    , reactions :: [ReactionData]
    }

type PutPipelineData = PostPipelineData

data GetPipelineData = GetPipelineData
    { name :: Text 
    , pType :: PipelineType 
    , pParams :: PipelineParams
    , enabled :: Bool 
    , error :: Maybe Text
    , lastTrigger :: Maybe UTCTime 
    , triggerCount :: Int64
    , id :: PipelineId
    }

data GetPipelineResponse = GetPipelineResponse
    { action :: GetPipelineData
    , reactions :: [ReactionData]
    }

type PostPipelineResponse = GetPipelineResponse
type PutPipelineResponse = GetPipelineResponse

$(deriveJSON defaultOptions ''PipelineData)
$(deriveJSON defaultOptions ''GetPipelineData)
$(deriveJSON defaultOptions ''ReactionData)
$(deriveJSON defaultOptions ''GetPipelineResponse)
$(deriveJSON defaultOptions ''PostPipelineData)

data PipelineAPI mode = PipelineAPI
    { get   :: mode :- "workflow" :> UserAuth :>
        Capture "id" PipelineId :> Get '[JSON] GetPipelineResponse
    , post  :: mode :- "workflow" :> UserAuth :>
        ReqBody '[JSON] PostPipelineData :> Post '[JSON] PostPipelineResponse
    , put   :: mode :- "workflow" :> UserAuth :>
        Capture "id" PipelineId :> ReqBody '[JSON] PutPipelineData :> Put '[JSON] PutPipelineResponse
    , del   :: mode :- "workflow" :> UserAuth :>
        Capture "id" PipelineId :> Delete '[JSON] Int64
    , all   :: mode :- "workflows" :> UserAuth
        :> Get '[JSON] [GetPipelineResponse]
    }
    deriving stock (Generic)

formatGetPipelineResponse :: Pipeline Identity -> [Reaction Identity] -> GetPipelineResponse
formatGetPipelineResponse (Pipeline pId pName pType pParams _ pEnabled pError pTriggerCount pLastTrigger) reactions =
    GetPipelineResponse actionResult reactionsResult
    where
        actionResult = GetPipelineData
            { name = pName
            , pType = pType
            , pParams = pParams
            , enabled = pEnabled
            , error = pError
            , lastTrigger = pLastTrigger
            , triggerCount = pTriggerCount
            , id = pId
            } 
        reactionsResult = fmap (\x -> ReactionData (reactionType x) (reactionParams x)) reactions

formatPostPipelineData :: Pipeline Identity -> [Reaction Identity] -> PostPipelineData
formatPostPipelineData pipeline reactions =
    PostPipelineData actionResult reactionsResult
    where
        actionResult = PipelineData (pipelineName pipeline) (pipelineType pipeline) (pipelineParams pipeline) (pipelineEnabled pipeline)
        reactionsResult = fmap (\x -> ReactionData (reactionType x) (reactionParams x)) reactions


informWorker :: ByteString -> PipelineId -> IO ()
informWorker method id =
    do
        url <- envAsString "WORKER_URL" "worker/"
        request <- parseRequest url
        response <- httpBS
            $ setRequestMethod method
            $ setRequestPath (encodeUtf8 (pack $ "/workflow/" <> show id))
            request
        return ()


getPipelineHandler :: AuthRes -> PipelineId -> AppM GetPipelineResponse
getPipelineHandler (Authenticated (User uid _ _)) pipelineId = do
    (pipeline, reactions, _) <- getWorkflow' pipelineId
    if pipelineUserId pipeline == uid then
        return $ formatGetPipelineResponse pipeline reactions
    else
        throwError err403 
getPipelineHandler _ _ = throwError err401

reactionDatasToReactions :: [ReactionData] -> PipelineId -> [Reaction Identity]
reactionDatasToReactions datas pId = fmap (\(s, i) -> Reaction (ReactionId 1) (rType s) (rParams s) pId (fromIntegral i)) (zip datas [0 ..])

postPipelineHandler :: AuthRes -> PostPipelineData -> AppM PostPipelineResponse
postPipelineHandler (Authenticated (User uid _ _)) x = do
    let newPipeline = def {
          pipelineName = name (p :: PipelineData)
        , pipelineType = pType (p :: PipelineData)
        , pipelineParams = pParams (p :: PipelineData)
        , pipelineUserId = uid
        , pipelineEnabled = enabled (p :: PipelineData)}
    actionId <- createPipeline newPipeline
    liftIO $ informWorker "POST" actionId
    let newReactions = reactionDatasToReactions (reactions (x :: PostPipelineData)) actionId
    let newPipelineWithId = newPipeline { pipelineId = actionId }
    createReactions newReactions
    return $ formatGetPipelineResponse newPipelineWithId newReactions
  where
    p = action (x :: PostPipelineData)
postPipelineHandler _ _ = throwError err401

putPipelineHandler :: AuthRes -> PipelineId -> PutPipelineData -> AppM PutPipelineResponse
putPipelineHandler (Authenticated (User uid _ _)) pId x = do
    oldPipeline <- getPipelineById' pId
    if pipelineUserId oldPipeline == uid then do
        res <- putWorkflow pId (lit newPipeline) r
        if res > 0 then do
            liftIO $ informWorker "PUT" pId
            return $ formatGetPipelineResponse (newPipeline { pipelineId = pId }) r
        else
            throwError err500
    else
        throwError err403
    where
        p = action (x :: PutPipelineData)
        newPipeline = def {
          pipelineName = name (p :: PipelineData)
        , pipelineType = pType (p :: PipelineData)
        , pipelineParams = pParams (p :: PipelineData)
        , pipelineUserId = uid
        , pipelineEnabled = enabled (p :: PipelineData)} :: Pipeline Identity
        r = reactionDatasToReactions (reactions (x :: PutPipelineData)) pId
putPipelineHandler _ _ _ = throwError err401

delPipelineHandler :: AuthRes -> PipelineId -> AppM Int64 
delPipelineHandler (Authenticated (User uid _ _)) pipelineId = do
    oldPipeline <- getPipelineById' pipelineId
    if pipelineUserId oldPipeline == uid then do
        liftIO $ informWorker "DELETE" pipelineId
        delWorkflow pipelineId
    else throwError err403
delPipelineHandler _ _ = throwError err401

allPipelineHandler :: AuthRes -> AppM [GetPipelineResponse]
allPipelineHandler usr@(Authenticated (User uid _ _)) = do
    workflows <- getWorkflowsByUser' uid
    return $ fmap (uncurry formatGetPipelineResponse) workflows
allPipelineHandler _ = throwError err401

pipelineHandler :: PipelineAPI (AsServerT AppM)
pipelineHandler =
    PipelineAPI
        { get = getPipelineHandler
        , post = postPipelineHandler
        , put = putPipelineHandler
        , del = delPipelineHandler
        , Api.Pipeline.all = allPipelineHandler
        }

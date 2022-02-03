{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Password where

import Rel8 ( DBEq, DBType )
import Data.Aeson ( FromJSON, ToJSON )
import Data.Text ( Text )

import Crypto.KDF.BCrypt

newtype HashedPassword = HashedPassword { getHashedPasswd :: Text }
    deriving newtype (Eq, Show, Read, DBEq, DBType)

newtype Password = Password { getPassword :: Text }
    deriving newtype (Eq, Show, Read, FromJSON, ToJSON, DBEq, DBType)

-- TODO Check if the password meets minimum security requirements
toPassword :: Text -> Password
toPassword = Password


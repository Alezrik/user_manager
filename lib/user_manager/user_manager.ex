defmodule UserManager do
  @moduledoc ~S"""
  UserManager is an integration of components, with an intention of being a multi use manager for user based systems.

  * `UserManager.UserManagerApi` is the component that exposes various workflows to external systems.

    * `UserManager.UserManagerApi.create_user/3` is used to add a user into the system.

    * `UserManager.UserManagerApi.authenticate_user/3` is used to authenticate a user and receive a user token

    * `UserManager.UserManagerApi.identify_user/1` is used to get a system user from a user token

    * `UserManager.UserManagerApi.authorize_claims/3` is used to verify if a user/token has a certain permission

"""
  
end
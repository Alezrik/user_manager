# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.
config :user_manager, ecto_repos: [UserManager.Repo]

config :user_manager,
  new_user_default_permissions: %{default: [:read], authenticate: [:credential]},
  syncronous_api_timeout: 60_000,
  facebook_client_id: System.get_env("FACEBOOK_CLIENT_ID"),
  facebook_redirect_uri: "http://localhost:4000/",
  facebook_proxy: UserManager.Extern.FacebookProxy,
  facebook_profile_timeout: 30_000,
  notification_workflow_and_codes: [{:authenticate, [:user_not_found, :authenticate_failure, :token_storage_failure,
                                                      :token_error, :success, :authorization_failure]},
                                   {:authorize, [:token_not_found, :token_decode_error, :success, :unauthorized]},
                                   {:create_facebook_profile, [:access_token_error, :server_token_error,
                                                              :access_token_validation_error, :server_token_validation_error,
                                                              :validation_error, :success]},
                                   {:create_user, [:success, :validation_error, :update_error]},
                                   {:identify_user, [:token_not_found, :token_decode_error, :user_deserialize_error, :success]},
                                   {:user_crud, [:delete]}]

config :guardian, Guardian,
  allowed_algos: ["HS512"], # optional
  verify_module: Guardian.JWT,  # optional
  issuer: "Someone",
  ttl: { 30, :days },
  allowed_drift: 2000,
  verify_issuer: true, # optional
  secret_key: "#{System.get_env("GUARDIAN_SECRET_KEY")}",
  serializer: UserManager.GuardianSerializer,
  hooks: GuardianDb,
  permissions: %{
    default: [:read],
    authenticate: [:credential],
    admin: [:read, :create, :update, :delete]
  }

config :guardian_db, GuardianDb,
           repo: UserManager.Repo,
           sweep_interval: 120
config :cipher, keyphrase: System.get_env("CIPHER_KEY_PHRASE"),
                ivphrase: System.get_env("CIPHER_IV_PHRASE"),
                magic_token: System.get_env("CIPHER_MAGIC_TOKEN")

config :facebook,
   appsecret: System.get_env("FACEBOOK_APP_SECRET"),
   graph_url: "https://graph.facebook.com/v2.8/"
# You can configure for your application as:
#
#     config :user_manager, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:user_manager, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
import_config "#{Mix.env}.exs"

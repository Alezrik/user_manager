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
  user_profile_request_timeout: 10000,
  user_profile_workers: 2,
  user_profile_max_overflow: 1,
  authenticate_request_timeout: 10000,
  authenticate_workers: 2,
  authenticate_max_overflow: 1,
  authorization_request_timeout: 10000,
  authorization_workers: 2,
  authorization_max_overflow: 1
config :guardian, Guardian,
  allowed_algos: ["HS512"], # optional
  verify_module: Guardian.JWT,  # optional
  issuer: "Someone",
  ttl: { 30, :days },
  allowed_drift: 2000,
  verify_issuer: true, # optional
  secret_key: "SomeTemporarySuperSecretKeyOnlyIKnow!",
  serializer: UserManager.GuardianSerializer,
  hooks: GuardianDb,
  permissions: %{
    default: [:read],
    admin: [:read, :create, :update, :delete]
  }

config :guardian_db, GuardianDb,
           repo: UserManager.Repo,
           sweep_interval: 120

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

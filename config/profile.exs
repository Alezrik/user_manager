use Mix.Config

config :logger, level: :warn, compile_time_purge_level: :warn
config :comeonin, :bcrypt_log_rounds, 4
config :user_manager, UserManager.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "user_manager_db_test",
  username: "Mac",
  password: "mac",
  hostname: "localhost",
  port: "5432"

config :user_manager,
  new_user_default_permissions: %{default: [:read]},
  syncronous_api_timeout: 1000
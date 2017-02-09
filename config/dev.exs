use Mix.Config

config :logger, level: :debug

config :user_manager, UserManager.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "user_manager_db_dev",
  username: "Mac",
  password: "mac",
  hostname: "localhost",
  port: "5432"
use Mix.Config



config :user_manager, UserManager.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "user_manager_db_test",
  username: "Mac",
  password: "mac",
  hostname: "localhost",
  port: "5432"
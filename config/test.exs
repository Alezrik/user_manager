use Mix.Config

config :logger, level: :debug, compile_time_purge_level: :debug
config :comeonin, :bcrypt_log_rounds, 4
config :user_manager, UserManager.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "user_manager_db_test",
  username: "Mac",
  password: "mac",
  hostname: "localhost",
  port: "5432"

config :user_manager,
  syncronous_api_timeout: 5_000,
  facebook_proxy: FakeFacebookProxy,
  facebook_profile_timeout: 5_000

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
    authenticate: [:credential],
    admin: [:read, :create, :update, :delete]
  }

config :guardian_db, GuardianDb,
           repo: UserManager.Repo,
           sweep_interval: 120
config :cipher, keyphrase: "testiekeyphraseforcipher",
                ivphrase: "testieivphraseforcipher",
                magic_token: "magictoken"

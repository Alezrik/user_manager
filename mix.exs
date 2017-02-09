defmodule UserManager.Mixfile do
  use Mix.Project

  def project do
    [app: :user_manager,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger, :poolboy],
     mod: {UserManager.Application, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:postgrex, ">= 0.0.0"},
        {:ecto, "~> 2.1"},
        {:guardian, "~> 0.14"},
        {:guardian_db, git: "https://github.com/ueberauth/guardian_db.git"}, {:faker, "~> 0.7"}, {:credo, "~> 0.5", only: [:dev, :test]},
        {:dialyxir, "~> 0.4", only: [:dev], runtime: false}, {:gen_stage, "~> 0.11"}, {:flow, "~> 0.11"}, {:ex_doc, "~> 0.14", only: :dev} ]
  end

  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.drop --quiet","ecto.create --quiet", "ecto.migrate", "run priv/repo/seeds.exs", "test"]
     ]

  end
end

defmodule UserManager.Mixfile do
  use Mix.Project

  def project do
    [app: :user_manager,
     version: "0.3.0",
     elixir: "~> 1.4",
     description: description(),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps(),
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
     package: package()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger, :poolboy, :httpoison],
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
        {:guardian_db, "~> 0.8.0"}, {:faker, "~> 0.7"}, {:credo, "~> 0.5", only: [:dev, :test]},
        {:dialyxir, "~> 0.4", only: [:dev], runtime: false}, {:gen_stage, "~> 0.11"}, {:flow, "~> 0.11"}, {:ex_doc, "~> 0.14", only: :dev}, {:comeonin, "~> 3.0"},
        {:excoveralls, "~> 0.6", only: :test}, {:exprof, "~> 0.2.0"}, {:inch_ex, only: :docs},
        {:facebook, "~> 0.9.0"}, {:cipher, ">= 1.3.0"}, {:httpoison, "~> 0.10.0"}, {:amnesia, "~> 0.2.5"}]
  end

  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.drop --quiet","ecto.create --quiet", "ecto.migrate", "run priv/repo/seeds.exs", "test"]
     ]
  end

  defp description do
  """
  A User Management system for Elixir Projects
"""
  end
  def package() do
    [
    maintainers: ["Stephen Daubert"],
    licenses: ["MIT"],
    links: %{"GitHub" => "https://github.com/Alezrik/user_manager"}
    ]
  end

end

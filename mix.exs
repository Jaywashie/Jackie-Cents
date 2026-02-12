defmodule Insurance.MixProject do
  use Mix.Project

  def project do
    [
      app: :insurance,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Insurance.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
 defp deps do

  [
    {:phoenix, "~> 1.7.21"},
    {:phoenix_ecto, "~> 4.7"},
    {:ecto_sql, "~> 3.13"},
    {:postgrex, ">= 0.0.0"},
    {:phoenix_html, "~> 3.3.4"},
    {:phoenix_live_reload, "~> 1.6.2", only: :dev},
    {:phoenix_live_view, "~> 1.1.22"},
    {:phoenix_live_dashboard, "~> 0.8.7"},
    {:heroicons, "~> 0.5.6"},
    {:floki, ">= 0.33.0", only: :test},
    {:esbuild, "~> 0.10.0", runtime: Mix.env() == :dev},
    {:tailwind, "~> 0.1.10", runtime: Mix.env() == :dev},
    {:swoosh, "~> 1.21"},
    {:finch, "~> 0.21.0"},
    {:telemetry_metrics, "~> 0.6.2"},
    {:telemetry_poller, "~> 1.3.0"},
    {:gettext, "~> 0.26.2"},
    {:jason, "~> 1.4.4"},
    {:plug_cowboy, "~> 2.8.0"},
    {:pbkdf2_elixir, "~> 2.0"}
  ]
end


  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
    ]
  end
end

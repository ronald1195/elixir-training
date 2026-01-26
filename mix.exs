defmodule ElixirTraining.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_training,
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_options: [warnings_as_errors: false],
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      elixirc_paths: elixirc_paths(Mix.env()),

      # Docs
      name: "Elixir Training",
      description: "Hands-on Elixir training for engineers transitioning from OOP"
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Set test environment for session aliases
  def cli do
    [
      preferred_envs: [
        session1: :test,
        session2: :test,
        session3: :test,
        session4: :test,
        session5: :test,
        session6: :test,
        session7: :test,
        session8: :test,
        session9: :test,
        session10: :test,
        session11: :test,
        session12: :test,
        session13: :test,
        session14: :test,
        session15: :test,
        session16: :test,
        session17: :test,
        "test.sessions": :test,
        "test.pending": :test,
        "session1.pending": :test,
        "session2.pending": :test,
        "session3.pending": :test,
        "session4.pending": :test,
        "session5.pending": :test,
        "session6.pending": :test,
        "session7.pending": :test,
        "session8.pending": :test,
        "session9.pending": :test,
        "session10.pending": :test,
        "session11.pending": :test,
        "session12.pending": :test,
        "session13.pending": :test,
        "session14.pending": :test,
        "session15.pending": :test,
        "session16.pending": :test,
        "session17.pending": :test,
        "validate.session1": :test,
        "validate.session2": :test,
        "validate.session3": :test,
        "validate.session4": :test,
        "validate.session5": :test,
        "validate.session6": :test,
        "validate.session7": :test,
        "validate.session8": :test,
        "validate.session9": :test,
        "validate.session10": :test,
        "validate.session11": :test,
        "validate.session12": :test,
        "validate.session13": :test,
        "validate.session14": :test,
        "validate.session15": :test,
        "validate.session16": :test,
        "validate.session17": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ElixirTraining.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Database
      {:ecto_sql, "~> 3.11"},
      {:postgrex, ">= 0.0.0"},

      # Background jobs
      {:oban, "~> 2.17"},

      # HTTP client
      {:req, "~> 0.5"},

      # Circuit breaker
      {:fuse, "~> 2.5"},

      # GraphQL
      {:absinthe, "~> 1.7"},
      {:absinthe_plug, "~> 1.5"},
      {:dataloader, "~> 2.0"},

      # Message processing
      {:broadway, "~> 1.0"},

      # gRPC
      {:grpc, "~> 0.8"},
      {:protobuf, "~> 0.12"},

      # PubSub for real-time
      {:phoenix_pubsub, "~> 2.1"},

      # Testing
      {:mox, "~> 1.1", only: :test},
      {:ex_machina, "~> 2.7.0", only: :test}
    ]
  end

  # Aliases for workshop convenience
  defp aliases do
    [
      # Setup
      setup: ["deps.get", "compile"],
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],

      # Run IMPLEMENTED tests for specific sessions (pending tests excluded via test_helper.exs)
      # Usage: mix session1, mix session2, etc.
      session1: ["test test/session_01_basics/"],
      session2: ["test test/session_02_pattern_matching/"],
      session3: ["test test/session_03_collections/"],
      session4: ["test test/session_04_umbrella/"],
      session5: ["test test/session_05_processes/"],
      session6: ["test test/session_06_genserver/"],
      session7: ["test test/session_07_supervision/"],
      session8: ["test test/session_08_oban/"],
      session9: ["test test/session_09_ecto/"],
      session10: ["test test/session_10_advanced_ecto/"],
      session11: ["test test/session_11_http/"],
      session12: ["test test/session_12_graphql/"],
      session13: ["test test/session_13_broadway/"],
      session14: ["test test/session_14_grpc/"],
      session15: ["test test/session_15_protocols/"],
      session16: ["test test/session_16_testing/"],
      session17: ["test test/session_17_websockets/"],

      # Run all session tests (excludes pending)
      "test.sessions": ["test test/session_*/"],

      # Run PENDING tests (for working on exercises)
      # Usage: mix session1.pending, mix session2.pending, etc.
      "session1.pending": ["test test/session_01_basics/ --include pending"],
      "session2.pending": ["test test/session_02_pattern_matching/ --include pending"],
      "session3.pending": ["test test/session_03_collections/ --include pending"],
      "session4.pending": ["test test/session_04_umbrella/ --include pending"],
      "session5.pending": ["test test/session_05_processes/ --include pending"],
      "session6.pending": ["test test/session_06_genserver/ --include pending"],
      "session7.pending": ["test test/session_07_supervision/ --include pending"],
      "session8.pending": ["test test/session_08_oban/ --include pending"],
      "session9.pending": ["test test/session_09_ecto/ --include pending"],
      "session10.pending": ["test test/session_10_advanced_ecto/ --include pending"],
      "session11.pending": ["test test/session_11_http/ --include pending"],
      "session12.pending": ["test test/session_12_graphql/ --include pending"],
      "session13.pending": ["test test/session_13_broadway/ --include pending"],
      "session14.pending": ["test test/session_14_grpc/ --include pending"],
      "session15.pending": ["test test/session_15_protocols/ --include pending"],
      "session16.pending": ["test test/session_16_testing/ --include pending"],
      "session17.pending": ["test test/session_17_websockets/ --include pending"],
      "test.pending": ["test test/session_*/ --include pending"],

      # Validate a session (compile + test)
      "validate.session1": ["compile --warnings-as-errors", "session1"],
      "validate.session2": ["compile --warnings-as-errors", "session2"],
      "validate.session3": ["compile --warnings-as-errors", "session3"],
      "validate.session4": ["compile --warnings-as-errors", "session4"],
      "validate.session5": ["compile --warnings-as-errors", "session5"],
      "validate.session6": ["compile --warnings-as-errors", "session6"],
      "validate.session7": ["compile --warnings-as-errors", "session7"],
      "validate.session8": ["compile --warnings-as-errors", "session8"],
      "validate.session9": ["compile --warnings-as-errors", "session9"],
      "validate.session10": ["compile --warnings-as-errors", "session10"],
      "validate.session11": ["compile --warnings-as-errors", "session11"],
      "validate.session12": ["compile --warnings-as-errors", "session12"],
      "validate.session13": ["compile --warnings-as-errors", "session13"],
      "validate.session14": ["compile --warnings-as-errors", "session14"],
      "validate.session15": ["compile --warnings-as-errors", "session15"],
      "validate.session16": ["compile --warnings-as-errors", "session16"],
      "validate.session17": ["compile --warnings-as-errors", "session17"],

      # Check code quality
      lint: ["format --check-formatted", "compile --warnings-as-errors"]
    ]
  end
end

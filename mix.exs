defmodule ElixirTraining.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_training,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),

      # Docs
      name: "Elixir Training",
      description: "Hands-on Elixir training for engineers transitioning from OOP"
    ]
  end

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
        "test.sessions": :test,
        "test.pending": :test,
        "session1.pending": :test,
        "session2.pending": :test,
        "validate.session1": :test,
        "validate.session2": :test
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
      # {:dep_from_hexpm, "~> 0.3.0"},
    ]
  end

  # Aliases for workshop convenience
  defp aliases do
    [
      # Setup
      setup: ["deps.get", "compile"],

      # Run IMPLEMENTED tests for specific sessions (pending tests excluded via test_helper.exs)
      # Usage: mix session1, mix session2, etc.
      session1: ["test test/session_01_basics/"],
      session2: ["test test/session_02_pattern_matching/"],
      session3: ["test test/session_03_collections/"],
      session4: ["test test/session_04_processes/"],
      session5: ["test test/session_05_genserver/"],
      session6: ["test test/session_06_supervision/"],
      session7: ["test test/session_07_ecto/"],
      session8: ["test test/session_08_http/"],
      session9: ["test test/session_09_testing/"],
      session10: ["test test/session_10_kafka/"],
      session11: ["test test/session_11_grpc/"],
      session12: ["test test/session_12_realtime/"],

      # Run all session tests (excludes pending)
      "test.sessions": ["test test/session_*/"],

      # Run PENDING tests (for working on exercises)
      # Usage: mix session1.pending, mix session2.pending, etc.
      "session1.pending": ["test test/session_01_basics/ --include pending"],
      "session2.pending": ["test test/session_02_pattern_matching/ --include pending"],
      "test.pending": ["test test/session_*/ --include pending"],

      # Validate a session (compile + test)
      "validate.session1": ["compile --warnings-as-errors", "session1"],
      "validate.session2": ["compile --warnings-as-errors", "session2"],

      # Check code quality
      lint: ["format --check-formatted", "compile --warnings-as-errors"]
    ]
  end
end

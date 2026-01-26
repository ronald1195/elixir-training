import Config

# Test-specific configuration

# Use sandbox for Ecto during tests
config :elixir_training, ElixirTraining.Repo, pool: Ecto.Adapters.SQL.Sandbox

# Oban inline mode for testing (jobs run immediately)
config :elixir_training, Oban, testing: :inline

# Reduce log noise during tests
config :logger, level: :warning

import Config

# Ecto configuration
config :elixir_training,
  ecto_repos: [ElixirTraining.Repo]

config :elixir_training, ElixirTraining.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "elixir_training_#{config_env()}",
  pool_size: 10,
  show_sensitive_data_on_connection_error: true

# Oban configuration
config :elixir_training, Oban,
  repo: ElixirTraining.Repo,
  queues: [default: 10, invoices: 5]

# Phoenix PubSub for real-time features
config :elixir_training, ElixirTraining.PubSub,
  name: ElixirTraining.PubSub,
  adapter: Phoenix.PubSub.PG2

# Import environment specific config
import_config "#{config_env()}.exs"

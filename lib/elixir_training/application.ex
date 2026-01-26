defmodule ElixirTraining.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      ElixirTraining.Repo,
      # Start PubSub for real-time features
      {Phoenix.PubSub, name: ElixirTraining.PubSub},
      # Start Oban for background jobs
      {Oban, Application.fetch_env!(:elixir_training, Oban)}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirTraining.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

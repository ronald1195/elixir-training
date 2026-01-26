defmodule Session07.PaymentSupervisor do
  @moduledoc """
  Solution for Session 7: Payment Supervisor

  A supervisor for the payment processing system.
  """

  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    children = [
      # Cache - independent, can restart alone
      %{
        id: :cache,
        start: {Session07.Cache, :start_link, [[]]},
        restart: :permanent,
        shutdown: 5000
      },
      # Rate limiter - independent, can restart alone
      %{
        id: :rate_limiter,
        start: {Session07.RateLimiter, :start_link, [[]]},
        restart: :permanent,
        shutdown: 5000
      },
      # Payment processor - depends on cache and rate limiter
      %{
        id: :payment_processor,
        start: {Session07.PaymentProcessor, :start_link, [[]]},
        restart: :permanent,
        shutdown: 30_000  # Long timeout for in-flight transactions
      },
      # Notifier - depends on payment processor
      %{
        id: :notifier,
        start: {Session07.Notifier, :start_link, [[]]},
        restart: :permanent,
        shutdown: 5000
      }
    ]

    # rest_for_one: if a child crashes, restart it and all children started after it
    Supervisor.init(children, strategy: :rest_for_one)
  end

  def get_child_pid(child_id) do
    __MODULE__
    |> Supervisor.which_children()
    |> Enum.find_value(fn
      {^child_id, pid, _type, _modules} when is_pid(pid) -> pid
      _ -> nil
    end)
  end

  def children_info do
    Supervisor.which_children(__MODULE__)
  end

  def count_children do
    Supervisor.count_children(__MODULE__)
  end

  def restart_child(child_id) do
    with :ok <- Supervisor.terminate_child(__MODULE__, child_id),
         {:ok, pid} <- Supervisor.restart_child(__MODULE__, child_id) do
      {:ok, pid}
    end
  end
end

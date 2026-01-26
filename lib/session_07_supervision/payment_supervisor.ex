defmodule Session07.PaymentSupervisor do
  @moduledoc """
  A supervisor for the payment processing system.

  ## Background for OOP Developers

  In Java/C#, you might manage service lifecycle with dependency injection:

      @Configuration
      public class PaymentConfig {
          @Bean
          public PaymentProcessor processor(Cache cache, RateLimiter limiter) {
              return new PaymentProcessor(cache, limiter);
          }

          @Bean
          @DependsOn("processor")
          public NotificationService notifier() {
              return new NotificationService();
          }
      }

  In Elixir, supervisors manage the lifecycle with automatic restart on failure:

      children = [
        {Cache, []},
        {RateLimiter, []},
        {PaymentProcessor, []},  # Started after its dependencies
        {NotificationService, []}
      ]

  ## System Architecture

  ```
  ┌─────────────────────────────────────────────────┐
  │              PaymentSupervisor                   │
  │              (rest_for_one)                      │
  └───────────────────┬─────────────────────────────┘
                      │
    ┌─────────────────┼─────────────────┬───────────────────┐
    ▼                 ▼                 ▼                   ▼
  ┌─────┐      ┌───────────┐    ┌───────────────┐   ┌─────────────┐
  │Cache│  →   │RateLimiter│ →  │PaymentProcessor│ → │Notifier     │
  └─────┘      └───────────┘    └───────────────┘   └─────────────┘
  (start 1)    (start 2)        (start 3)          (start 4)

  If RateLimiter crashes: RateLimiter, PaymentProcessor, Notifier restart
  If PaymentProcessor crashes: PaymentProcessor, Notifier restart
  Cache always stays running (unless it crashes itself)
  ```

  ## Your Task

  Implement a supervisor that manages:
  1. A cache service (independent, can restart alone)
  2. A rate limiter (independent, can restart alone)
  3. A payment processor (depends on cache and rate limiter)
  4. A notification service (depends on payment processor)
  """

  use Supervisor

  @doc """
  Starts the payment supervisor.

  ## Examples

      iex> {:ok, pid} = Session07.PaymentSupervisor.start_link([])
      iex> is_pid(pid)
      true
  """
  def start_link(_opts) do
    # TODO: Start the supervisor
    # Hint: Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
    raise "TODO: Implement start_link/1"
  end

  @doc """
  Returns a list of child specifications for the supervisor.

  The children should be:
  1. Session07.Cache - Simple key-value cache
  2. Session07.RateLimiter - Rate limiting service
  3. Session07.PaymentProcessor - Processes payments
  4. Session07.Notifier - Sends notifications

  Each child should have appropriate:
  - restart strategy (:permanent, :temporary, or :transient)
  - shutdown timeout
  """
  @impl true
  def init(_opts) do
    # TODO: Define children and initialize supervisor
    # Consider:
    # - What order should children start?
    # - What restart strategy for the supervisor?
    # - What restart/shutdown settings for each child?
    raise "TODO: Implement init/1"
  end

  @doc """
  Returns the PID of a specific child by its ID.

  ## Examples

      iex> {:ok, _} = Session07.PaymentSupervisor.start_link([])
      iex> pid = Session07.PaymentSupervisor.get_child_pid(:cache)
      iex> is_pid(pid)
      true
  """
  def get_child_pid(_child_id) do
    # TODO: Find the child PID from Supervisor.which_children/1
    raise "TODO: Implement get_child_pid/1"
  end

  @doc """
  Returns information about all children.

  ## Examples

      iex> {:ok, _} = Session07.PaymentSupervisor.start_link([])
      iex> children = Session07.PaymentSupervisor.children_info()
      iex> length(children)
      4
  """
  def children_info do
    # TODO: Return Supervisor.which_children/1 result
    raise "TODO: Implement children_info/0"
  end

  @doc """
  Counts the current number of running children.

  ## Examples

      iex> {:ok, _} = Session07.PaymentSupervisor.start_link([])
      iex> Session07.PaymentSupervisor.count_children()
      %{active: 4, specs: 4, supervisors: 0, workers: 4}
  """
  def count_children do
    # TODO: Return Supervisor.count_children/1 result
    raise "TODO: Implement count_children/0"
  end

  @doc """
  Restarts a specific child by its ID.

  Returns `{:ok, new_pid}` on success.

  ## Examples

      iex> {:ok, _} = Session07.PaymentSupervisor.start_link([])
      iex> old_pid = Session07.PaymentSupervisor.get_child_pid(:cache)
      iex> {:ok, new_pid} = Session07.PaymentSupervisor.restart_child(:cache)
      iex> old_pid != new_pid
      true
  """
  def restart_child(_child_id) do
    # TODO: Restart a child using Supervisor.restart_child/2
    # Note: For :permanent children, you may need to terminate first
    raise "TODO: Implement restart_child/1"
  end
end

# ============================================================================
# Child Modules (Simple implementations for testing)
# ============================================================================

defmodule Session07.Cache do
  @moduledoc """
  A simple cache GenServer for the payment system.
  """
  use GenServer

  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def get(server \\ __MODULE__, key) do
    GenServer.call(server, {:get, key})
  end

  def put(server \\ __MODULE__, key, value) do
    GenServer.call(server, {:put, key, value})
  end

  @impl true
  def init(_opts), do: {:ok, %{}}

  @impl true
  def handle_call({:get, key}, _from, state) do
    {:reply, Map.get(state, key), state}
  end

  def handle_call({:put, key, value}, _from, state) do
    {:reply, :ok, Map.put(state, key, value)}
  end
end

defmodule Session07.RateLimiter do
  @moduledoc """
  A simple rate limiter GenServer for the payment system.
  """
  use GenServer

  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def check(server \\ __MODULE__, client_id) do
    GenServer.call(server, {:check, client_id})
  end

  @impl true
  def init(opts) do
    limit = Keyword.get(opts, :limit, 100)
    {:ok, %{limit: limit, counts: %{}}}
  end

  @impl true
  def handle_call({:check, client_id}, _from, state) do
    count = Map.get(state.counts, client_id, 0)

    if count < state.limit do
      new_counts = Map.put(state.counts, client_id, count + 1)
      {:reply, {:ok, state.limit - count - 1}, %{state | counts: new_counts}}
    else
      {:reply, {:error, :rate_limited}, state}
    end
  end
end

defmodule Session07.PaymentProcessor do
  @moduledoc """
  A payment processor GenServer.
  """
  use GenServer

  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def process(server \\ __MODULE__, payment) do
    GenServer.call(server, {:process, payment})
  end

  @impl true
  def init(_opts), do: {:ok, %{processed: 0}}

  @impl true
  def handle_call({:process, _payment}, _from, state) do
    new_state = %{state | processed: state.processed + 1}
    {:reply, {:ok, new_state.processed}, new_state}
  end
end

defmodule Session07.Notifier do
  @moduledoc """
  A notification service GenServer.
  """
  use GenServer

  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def notify(server \\ __MODULE__, message) do
    GenServer.call(server, {:notify, message})
  end

  @impl true
  def init(_opts), do: {:ok, %{sent: 0}}

  @impl true
  def handle_call({:notify, _message}, _from, state) do
    new_state = %{state | sent: state.sent + 1}
    {:reply, {:ok, new_state.sent}, new_state}
  end
end

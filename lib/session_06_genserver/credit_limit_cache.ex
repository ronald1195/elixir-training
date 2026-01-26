defmodule Session06.CreditLimitCache do
  @moduledoc """
  A GenServer-based cache for storing credit limits with TTL support.

  ## Background for OOP Developers

  In Java, you might use Guava Cache or Caffeine:

      LoadingCache<String, Integer> creditLimits = Caffeine.newBuilder()
          .expireAfterWrite(5, TimeUnit.MINUTES)
          .maximumSize(10_000)
          .build(key -> fetchFromDatabase(key));

  In Elixir, we implement this as a GenServer that:
  - Stores limits in process state
  - Tracks expiration times for entries
  - Periodically cleans up expired entries
  - Provides cache statistics

  ## Architecture

  ```
  ┌─────────────────────────────────────────────┐
  │           CreditLimitCache GenServer         │
  │                                              │
  │  State:                                      │
  │  - entries: %{account_id => {limit, exp}}    │
  │  - ttl_ms: default TTL for new entries       │
  │  - stats: %{hits: 0, misses: 0, sets: 0}     │
  │                                              │
  │  Callbacks:                                  │
  │  - handle_call(:get)                         │
  │  - handle_call(:put)                         │
  │  - handle_info(:cleanup)                     │
  └─────────────────────────────────────────────┘
  ```

  ## Your Task

  Implement the GenServer callbacks to create a working credit limit cache.
  """

  use GenServer

  # ============================================================================
  # Client API
  # ============================================================================

  @doc """
  Starts the credit limit cache.

  Options:
  - `:ttl_ms` - Default TTL for entries in milliseconds (default: 60_000)
  - `:cleanup_interval_ms` - How often to clean expired entries (default: 10_000)
  - `:name` - Process name (optional, defaults to module name)

  ## Examples

      iex> {:ok, pid} = Session06.CreditLimitCache.start_link(ttl_ms: 5000)
      iex> is_pid(pid)
      true
  """
  def start_link(_opts \\ []) do
    # TODO: Start the GenServer with given options
    # Hint: GenServer.start_link(__MODULE__, opts, name: name)
    raise "TODO: Implement start_link/1"
  end

  @doc """
  Gets the credit limit for an account.

  Returns `{:ok, limit}` if found and not expired, `:miss` otherwise.

  ## Examples

      iex> {:ok, pid} = Session06.CreditLimitCache.start_link()
      iex> Session06.CreditLimitCache.put(pid, "ACC-001", 5000)
      iex> Session06.CreditLimitCache.get(pid, "ACC-001")
      {:ok, 5000}
      iex> Session06.CreditLimitCache.get(pid, "ACC-999")
      :miss
  """
  def get(_server, _account_id) do
    # TODO: Send a synchronous call to get the limit
    raise "TODO: Implement get/2"
  end

  @doc """
  Sets the credit limit for an account.

  Returns `:ok` on success.

  ## Examples

      iex> {:ok, pid} = Session06.CreditLimitCache.start_link()
      iex> Session06.CreditLimitCache.put(pid, "ACC-001", 5000)
      :ok
  """
  def put(_server, _account_id, _limit) do
    # TODO: Send a synchronous call to set the limit
    raise "TODO: Implement put/3"
  end

  @doc """
  Sets the credit limit with a custom TTL.

  ## Examples

      iex> {:ok, pid} = Session06.CreditLimitCache.start_link()
      iex> Session06.CreditLimitCache.put(pid, "ACC-001", 5000, ttl_ms: 1000)
      :ok
  """
  def put(_server, _account_id, _limit, _opts) do
    # TODO: Send a synchronous call to set the limit with custom TTL
    raise "TODO: Implement put/4"
  end

  @doc """
  Deletes an entry from the cache.

  Returns `:ok` regardless of whether the key existed.

  ## Examples

      iex> {:ok, pid} = Session06.CreditLimitCache.start_link()
      iex> Session06.CreditLimitCache.put(pid, "ACC-001", 5000)
      iex> Session06.CreditLimitCache.delete(pid, "ACC-001")
      :ok
      iex> Session06.CreditLimitCache.get(pid, "ACC-001")
      :miss
  """
  def delete(_server, _account_id) do
    # TODO: Send a call to delete the entry
    raise "TODO: Implement delete/2"
  end

  @doc """
  Returns cache statistics.

  ## Examples

      iex> {:ok, pid} = Session06.CreditLimitCache.start_link()
      iex> Session06.CreditLimitCache.put(pid, "ACC-001", 5000)
      iex> Session06.CreditLimitCache.get(pid, "ACC-001")
      iex> Session06.CreditLimitCache.get(pid, "ACC-999")
      iex> Session06.CreditLimitCache.stats(pid)
      %{hits: 1, misses: 1, sets: 1, size: 1}
  """
  def stats(_server) do
    # TODO: Return cache statistics
    raise "TODO: Implement stats/1"
  end

  @doc """
  Clears all entries from the cache.

  Returns `:ok`.

  ## Examples

      iex> {:ok, pid} = Session06.CreditLimitCache.start_link()
      iex> Session06.CreditLimitCache.put(pid, "ACC-001", 5000)
      iex> Session06.CreditLimitCache.clear(pid)
      :ok
      iex> Session06.CreditLimitCache.get(pid, "ACC-001")
      :miss
  """
  def clear(_server) do
    # TODO: Clear all entries
    raise "TODO: Implement clear/1"
  end

  @doc """
  Returns all entries in the cache (for debugging).

  ## Examples

      iex> {:ok, pid} = Session06.CreditLimitCache.start_link()
      iex> Session06.CreditLimitCache.put(pid, "ACC-001", 5000)
      iex> Session06.CreditLimitCache.entries(pid)
      %{"ACC-001" => 5000}
  """
  def entries(_server) do
    # TODO: Return all current entries (just the values, not expiration times)
    raise "TODO: Implement entries/1"
  end

  # ============================================================================
  # Server Callbacks
  # ============================================================================

  @doc """
  Initializes the cache state.

  State should include:
  - `entries`: Map of account_id => {limit, expires_at}
  - `ttl_ms`: Default TTL for entries
  - `cleanup_interval_ms`: Interval between cleanup runs
  - `stats`: Map with hits, misses, sets counters

  Also schedules the first cleanup.
  """
  @impl true
  def init(_opts) do
    # TODO: Initialize state from options
    # Schedule first cleanup with Process.send_after
    # Return {:ok, initial_state}
    raise "TODO: Implement init/1"
  end

  @doc """
  Handles synchronous calls.

  Implement handlers for:
  - `{:get, account_id}` - Return limit if found and not expired
  - `{:put, account_id, limit, opts}` - Store limit with TTL
  - `{:delete, account_id}` - Remove entry
  - `:stats` - Return statistics
  - `:clear` - Clear all entries
  - `:entries` - Return all entries
  """
  @impl true
  def handle_call(_request, _from, _state) do
    # TODO: Handle each call type
    # Remember to update stats for hits/misses/sets
    raise "TODO: Implement handle_call/3"
  end

  @doc """
  Handles asynchronous info messages.

  Implement handler for:
  - `:cleanup` - Remove expired entries and reschedule
  """
  @impl true
  def handle_info(_msg, _state) do
    # TODO: Handle :cleanup message
    # Filter out expired entries
    # Schedule next cleanup
    raise "TODO: Implement handle_info/2"
  end

  # ============================================================================
  # Private Functions
  # ============================================================================

  # TODO: Add helper functions as needed
  # Suggestions:
  # - schedule_cleanup(interval_ms)
  # - entry_expired?(entry, now)
  # - cleanup_expired_entries(entries)
end

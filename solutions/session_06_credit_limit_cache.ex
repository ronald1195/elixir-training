defmodule Session06.CreditLimitCache do
  @moduledoc """
  Solution for Session 6: Credit Limit Cache

  A GenServer-based cache for storing credit limits with TTL support.
  """

  use GenServer

  @default_ttl_ms 60_000
  @default_cleanup_interval_ms 10_000

  defstruct [
    :ttl_ms,
    :cleanup_interval_ms,
    entries: %{},
    stats: %{hits: 0, misses: 0, sets: 0}
  ]

  # ============================================================================
  # Client API
  # ============================================================================

  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name)
    server_opts = if name, do: [name: name], else: []
    GenServer.start_link(__MODULE__, opts, server_opts)
  end

  def get(server, account_id) do
    GenServer.call(server, {:get, account_id})
  end

  def put(server, account_id, limit) do
    GenServer.call(server, {:put, account_id, limit, []})
  end

  def put(server, account_id, limit, opts) do
    GenServer.call(server, {:put, account_id, limit, opts})
  end

  def delete(server, account_id) do
    GenServer.call(server, {:delete, account_id})
  end

  def stats(server) do
    GenServer.call(server, :stats)
  end

  def clear(server) do
    GenServer.call(server, :clear)
  end

  def entries(server) do
    GenServer.call(server, :entries)
  end

  # ============================================================================
  # Server Callbacks
  # ============================================================================

  @impl true
  def init(opts) do
    ttl_ms = Keyword.get(opts, :ttl_ms, @default_ttl_ms)
    cleanup_interval_ms = Keyword.get(opts, :cleanup_interval_ms, @default_cleanup_interval_ms)

    state = %__MODULE__{
      ttl_ms: ttl_ms,
      cleanup_interval_ms: cleanup_interval_ms
    }

    schedule_cleanup(cleanup_interval_ms)

    {:ok, state}
  end

  @impl true
  def handle_call({:get, account_id}, _from, state) do
    now = System.monotonic_time(:millisecond)

    case Map.get(state.entries, account_id) do
      {limit, expires_at} when expires_at > now ->
        new_stats = Map.update!(state.stats, :hits, &(&1 + 1))
        {:reply, {:ok, limit}, %{state | stats: new_stats}}

      _ ->
        new_stats = Map.update!(state.stats, :misses, &(&1 + 1))
        {:reply, :miss, %{state | stats: new_stats}}
    end
  end

  def handle_call({:put, account_id, limit, opts}, _from, state) do
    ttl_ms = Keyword.get(opts, :ttl_ms, state.ttl_ms)
    expires_at = System.monotonic_time(:millisecond) + ttl_ms

    new_entries = Map.put(state.entries, account_id, {limit, expires_at})
    new_stats = Map.update!(state.stats, :sets, &(&1 + 1))

    {:reply, :ok, %{state | entries: new_entries, stats: new_stats}}
  end

  def handle_call({:delete, account_id}, _from, state) do
    new_entries = Map.delete(state.entries, account_id)
    {:reply, :ok, %{state | entries: new_entries}}
  end

  def handle_call(:stats, _from, state) do
    now = System.monotonic_time(:millisecond)
    size = count_valid_entries(state.entries, now)
    stats = Map.put(state.stats, :size, size)
    {:reply, stats, state}
  end

  def handle_call(:clear, _from, state) do
    {:reply, :ok, %{state | entries: %{}}}
  end

  def handle_call(:entries, _from, state) do
    now = System.monotonic_time(:millisecond)

    entries =
      state.entries
      |> Enum.filter(fn {_key, {_value, expires_at}} -> expires_at > now end)
      |> Enum.map(fn {key, {value, _expires_at}} -> {key, value} end)
      |> Map.new()

    {:reply, entries, state}
  end

  @impl true
  def handle_info(:cleanup, state) do
    now = System.monotonic_time(:millisecond)

    new_entries =
      state.entries
      |> Enum.filter(fn {_key, {_value, expires_at}} -> expires_at > now end)
      |> Map.new()

    schedule_cleanup(state.cleanup_interval_ms)

    {:noreply, %{state | entries: new_entries}}
  end

  # ============================================================================
  # Private Functions
  # ============================================================================

  defp schedule_cleanup(interval_ms) do
    Process.send_after(self(), :cleanup, interval_ms)
  end

  defp count_valid_entries(entries, now) do
    Enum.count(entries, fn {_key, {_value, expires_at}} -> expires_at > now end)
  end
end

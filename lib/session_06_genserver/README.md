# Session 6: GenServer - The Foundation of OTP

## Learning Objectives

By the end of this session, you will:
- Understand GenServer as a standardized process pattern
- Implement init, handle_call, handle_cast, and handle_info callbacks
- Design proper state management for concurrent systems
- Build production-ready stateful services
- Apply GenServer patterns to financial service scenarios

## Key Concepts

### What is GenServer?

GenServer (Generic Server) is a behaviour that standardizes the process patterns from Session 5. Instead of writing custom receive loops, you implement callbacks:

```elixir
# Raw process (Session 5)
defp loop(state) do
  receive do
    {:get, caller} -> send(caller, state); loop(state)
    {:set, value, caller} -> send(caller, :ok); loop(value)
  end
end

# GenServer (Session 6)
def handle_call(:get, _from, state), do: {:reply, state, state}
def handle_call({:set, value}, _from, _state), do: {:reply, :ok, value}
```

### OOP Comparison: Service Classes

In Java/C#, you might have a service class:

```java
@Service
public class CreditLimitService {
    private final Map<String, Integer> limits = new ConcurrentHashMap<>();

    public int getLimit(String accountId) {
        return limits.getOrDefault(accountId, 0);
    }

    public void setLimit(String accountId, int limit) {
        limits.put(accountId, limit);
    }
}
```

In Elixir, this becomes a GenServer:

```elixir
defmodule CreditLimitService do
  use GenServer

  # Client API
  def get_limit(pid, account_id) do
    GenServer.call(pid, {:get_limit, account_id})
  end

  def set_limit(pid, account_id, limit) do
    GenServer.call(pid, {:set_limit, account_id, limit})
  end

  # Server Callbacks
  def init(_opts), do: {:ok, %{}}

  def handle_call({:get_limit, account_id}, _from, state) do
    {:reply, Map.get(state, account_id, 0), state}
  end

  def handle_call({:set_limit, account_id, limit}, _from, state) do
    {:reply, :ok, Map.put(state, account_id, limit)}
  end
end
```

### The GenServer Callbacks

#### `init/1` - Initialize State

Called when the GenServer starts. Returns initial state.

```elixir
def init(opts) do
  # opts comes from GenServer.start_link/2
  initial_state = %{
    cache: %{},
    ttl_ms: Keyword.get(opts, :ttl_ms, 60_000)
  }
  {:ok, initial_state}
end

# Return values:
# {:ok, state}           - Start successfully with state
# {:ok, state, timeout}  - Start with timeout (sends :timeout to handle_info)
# {:ok, state, :hibernate} - Start and hibernate (low memory mode)
# {:stop, reason}        - Don't start, return error
# :ignore                - Don't start, but not an error
```

#### `handle_call/3` - Synchronous Requests

For operations where the caller waits for a response.

```elixir
def handle_call({:get, key}, _from, state) do
  value = Map.get(state.cache, key)
  {:reply, value, state}
end

# Arguments:
# - request: The message sent via GenServer.call
# - from: {caller_pid, reference} - usually ignored
# - state: Current state

# Return values:
# {:reply, response, new_state}
# {:reply, response, new_state, timeout}
# {:reply, response, new_state, :hibernate}
# {:noreply, new_state}      - Don't reply yet (manual reply later)
# {:stop, reason, reply, new_state} - Stop with final reply
```

#### `handle_cast/2` - Asynchronous Requests

For "fire and forget" operations with no response.

```elixir
def handle_cast({:put, key, value}, state) do
  new_cache = Map.put(state.cache, key, value)
  {:noreply, %{state | cache: new_cache}}
end

# Arguments:
# - request: The message sent via GenServer.cast
# - state: Current state

# Return values:
# {:noreply, new_state}
# {:noreply, new_state, timeout}
# {:stop, reason, new_state}
```

#### `handle_info/2` - Other Messages

For messages not sent via call/cast (timers, monitors, etc.).

```elixir
def handle_info(:cleanup, state) do
  # Called by Process.send_after(self(), :cleanup, 60_000)
  new_state = cleanup_expired_entries(state)
  schedule_cleanup()
  {:noreply, new_state}
end

def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
  # Monitor notification
  {:noreply, remove_connection(state, pid)}
end
```

### Starting and Using GenServers

```elixir
# Start the GenServer
{:ok, pid} = GenServer.start_link(MyServer, init_arg)

# Or with a name (allows calling by name instead of PID)
{:ok, pid} = GenServer.start_link(MyServer, init_arg, name: MyServer)

# Synchronous call (waits for response)
result = GenServer.call(pid, :get_state)
result = GenServer.call(MyServer, :get_state)  # By name

# Asynchronous cast (fire and forget)
GenServer.cast(pid, {:update, value})
```

### Timeouts and Hibernation

```elixir
def handle_call(:slow_operation, _from, state) do
  # Set a 5 second timeout for this process
  {:reply, :ok, state, 5000}
end

def handle_info(:timeout, state) do
  # Called after 5 seconds of no messages
  {:noreply, cleanup(state)}
end

# Hibernate to reduce memory when idle
def handle_call(:get, _from, state) do
  {:reply, state, state, :hibernate}
end
```

### The Client/Server Pattern

Best practice: separate client API from server callbacks.

```elixir
defmodule Cache do
  use GenServer

  # ============= Client API =============
  # These functions are called by OTHER processes

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def put(key, value) do
    GenServer.cast(__MODULE__, {:put, key, value})
  end

  # ============= Server Callbacks =============
  # These run INSIDE the GenServer process

  @impl true
  def init(_opts) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    {:reply, Map.get(state, key), state}
  end

  @impl true
  def handle_cast({:put, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end
end
```

### Real-World Pattern: Cache with TTL

```elixir
defmodule CacheWithTTL do
  use GenServer

  defstruct [:ttl_ms, entries: %{}]

  # Client API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def get(key), do: GenServer.call(__MODULE__, {:get, key})
  def put(key, value), do: GenServer.call(__MODULE__, {:put, key, value})

  # Server Callbacks

  @impl true
  def init(opts) do
    ttl_ms = Keyword.get(opts, :ttl_ms, 60_000)
    schedule_cleanup()
    {:ok, %__MODULE__{ttl_ms: ttl_ms}}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    case Map.get(state.entries, key) do
      {value, expires_at} when expires_at > System.monotonic_time(:millisecond) ->
        {:reply, {:ok, value}, state}
      _ ->
        {:reply, :not_found, state}
    end
  end

  @impl true
  def handle_call({:put, key, value}, _from, state) do
    expires_at = System.monotonic_time(:millisecond) + state.ttl_ms
    new_entries = Map.put(state.entries, key, {value, expires_at})
    {:reply, :ok, %{state | entries: new_entries}}
  end

  @impl true
  def handle_info(:cleanup, state) do
    now = System.monotonic_time(:millisecond)
    new_entries =
      state.entries
      |> Enum.reject(fn {_k, {_v, expires}} -> expires <= now end)
      |> Map.new()

    schedule_cleanup()
    {:noreply, %{state | entries: new_entries}}
  end

  defp schedule_cleanup do
    Process.send_after(self(), :cleanup, 10_000)
  end
end
```

## Exercises

### Exercise 1: Credit Limit Cache

Build a credit limit cache using GenServer that:
- Stores credit limits by account ID
- Supports TTL (time-to-live) for entries
- Provides statistics about cache usage

Open `lib/session_06_genserver/credit_limit_cache.ex` and implement the GenServer.

```bash
mix test test/session_06_genserver/credit_limit_cache_test.exs --include pending
```

## Hints

<details>
<summary>Hint 1: Structuring State</summary>
Use a struct or map for state with multiple fields:
```elixir
%{
  entries: %{},     # account_id => {limit, expires_at}
  ttl_ms: 60_000,   # default TTL
  stats: %{hits: 0, misses: 0}
}
```
</details>

<details>
<summary>Hint 2: Implementing TTL</summary>
Store expiration time with each entry:
```elixir
expires_at = System.monotonic_time(:millisecond) + ttl_ms
entries = Map.put(entries, key, {value, expires_at})
```
Check on read:
```elixir
case Map.get(entries, key) do
  {value, exp} when exp > now -> {:ok, value}
  _ -> :miss
end
```
</details>

<details>
<summary>Hint 3: Scheduling Cleanup</summary>
In `init/1`, schedule periodic cleanup:
```elixir
Process.send_after(self(), :cleanup, cleanup_interval_ms)
```
In `handle_info(:cleanup, state)`, filter expired entries and reschedule.
</details>

<details>
<summary>Hint 4: Using @impl true</summary>
Mark callback implementations with `@impl true` for clarity and compiler checks:
```elixir
@impl true
def init(opts), do: ...

@impl true
def handle_call(msg, from, state), do: ...
```
</details>

## Common Mistakes

1. **Blocking in callbacks** - GenServer processes one message at a time. Long-running operations block all other callers.

2. **Forgetting @impl true** - While optional, it helps catch typos in callback names.

3. **Not returning properly** - Each callback must return a specific tuple. `{:reply, ...}` for calls, `{:noreply, ...}` for casts.

4. **Ignoring the state** - Always include updated state in return tuples, even if unchanged.

5. **Using call when cast is appropriate** - Use `call` when you need a response, `cast` for fire-and-forget.

## Workshop Discussion Points

1. When should you use `call` vs `cast`?
2. How do you handle a GenServer that needs to do slow work without blocking?
3. What happens if a GenServer crashes? (Preview of supervision in Session 7)
4. How would you test a GenServer?

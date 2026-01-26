# Session 5: Processes - Lightweight Concurrency

## Learning Objectives

By the end of this session, you will:
- Understand the Actor Model and Elixir's process-based concurrency
- Create and communicate with processes using spawn, send, and receive
- Understand process isolation and its benefits for fault tolerance
- Build stateful processes using recursive receive loops
- Apply process-based patterns to financial service scenarios

## Key Concepts

### The Actor Model

Elixir uses the Actor Model for concurrency, where:
- Everything runs in lightweight **processes** (not OS threads)
- Processes don't share memory - they communicate by **sending messages**
- Each process has a **mailbox** for incoming messages
- Processes are **isolated** - one crashing doesn't affect others

### OOP Comparison: Threads vs Processes

In Java, concurrent code might look like:

```java
// Java - Shared state, locks, complexity
class Counter {
    private int count = 0;
    private final Object lock = new Object();

    public void increment() {
        synchronized(lock) {
            count++;  // Shared mutable state!
        }
    }
}

// Multiple threads accessing shared state
Thread t1 = new Thread(() -> counter.increment());
Thread t2 = new Thread(() -> counter.increment());
```

In Elixir, we isolate state in processes:

```elixir
# Elixir - No shared state, message passing
defmodule Counter do
  def start(initial \\ 0) do
    spawn(fn -> loop(initial) end)
  end

  defp loop(count) do
    receive do
      {:increment, caller} ->
        send(caller, {:count, count + 1})
        loop(count + 1)

      {:get, caller} ->
        send(caller, {:count, count})
        loop(count)
    end
  end
end

# Each process has its own state - no locks needed!
pid = Counter.start(0)
send(pid, {:increment, self()})
```

### Creating Processes

```elixir
# spawn/1 - Run a function in a new process
pid = spawn(fn ->
  IO.puts("Hello from process #{inspect(self())}")
end)

# spawn/3 - Run a module function with arguments
pid = spawn(MyModule, :my_function, [arg1, arg2])

# self() returns the current process's PID
IO.puts("My PID is #{inspect(self())}")
```

### Sending Messages

```elixir
# send/2 - Send a message to a process (non-blocking)
send(pid, {:hello, "world"})
send(pid, %{type: :payment, amount: 100})
send(pid, :shutdown)

# Messages are just data - any Elixir term works
```

### Receiving Messages

```elixir
# receive/1 - Wait for and pattern match messages
receive do
  {:hello, name} ->
    IO.puts("Hello, #{name}!")

  {:payment, amount} when amount > 0 ->
    process_payment(amount)

  :shutdown ->
    IO.puts("Shutting down...")
end

# With timeout
receive do
  msg -> handle(msg)
after
  5000 -> IO.puts("No message received in 5 seconds")
end
```

### Process Mailboxes

Each process has a mailbox - a queue of messages waiting to be processed:

```elixir
# Messages queue up in the mailbox
send(pid, :first)
send(pid, :second)
send(pid, :third)

# The process reads them in order with receive
receive do
  msg -> IO.inspect(msg)  # :first
end

receive do
  msg -> IO.inspect(msg)  # :second
end
```

### Stateful Processes: The Recursive Pattern

To maintain state, use a recursive function:

```elixir
defmodule BankAccount do
  def start(initial_balance) do
    spawn(fn -> loop(initial_balance) end)
  end

  defp loop(balance) do
    receive do
      {:deposit, amount, caller} ->
        new_balance = balance + amount
        send(caller, {:ok, new_balance})
        loop(new_balance)  # Recurse with new state

      {:withdraw, amount, caller} when amount <= balance ->
        new_balance = balance - amount
        send(caller, {:ok, new_balance})
        loop(new_balance)

      {:withdraw, _amount, caller} ->
        send(caller, {:error, :insufficient_funds})
        loop(balance)  # Balance unchanged

      {:get_balance, caller} ->
        send(caller, {:balance, balance})
        loop(balance)
    end
  end
end
```

### Process Isolation: Crash One, Others Continue

```elixir
# Start two independent processes
pid1 = spawn(fn ->
  loop_forever()
end)

pid2 = spawn(fn ->
  receive do
    :crash -> raise "Intentional crash!"
  end
end)

# Crash pid2 - pid1 keeps running!
send(pid2, :crash)
Process.alive?(pid1)  # true - unaffected!
```

### Why This Matters for Financial Services

1. **Rate Limiting**: Each client gets a process tracking their API calls
2. **Transaction Processing**: Each transaction runs in isolation
3. **Connection Pools**: Each connection is a process
4. **Session Management**: User sessions as processes
5. **Real-time Updates**: Each subscriber is a process receiving updates

### Linking Processes

Processes can be linked - if one crashes, linked processes also crash:

```elixir
# spawn_link - Create linked process
pid = spawn_link(fn ->
  raise "I will crash!"
end)
# The current process will also crash!

# Process.link/1 - Link existing processes
Process.link(pid)
```

### Monitoring Processes

For notification without crashing:

```elixir
# Monitor a process
ref = Process.monitor(pid)

# When monitored process dies, we get a message
receive do
  {:DOWN, ^ref, :process, ^pid, reason} ->
    IO.puts("Process died: #{inspect(reason)}")
end
```

## Exercises

### Exercise 1: Rate Limiter

Build an in-memory rate limiter using processes. Each client gets a process that tracks their API request count within a time window.

Open `lib/session_05_processes/rate_limiter.ex` and implement the functions.

```bash
mix test test/session_05_processes/rate_limiter_test.exs --include pending
```

## Hints

<details>
<summary>Hint 1: Starting the rate limiter process</summary>
Use `spawn/1` or `spawn_link/1` to create a process that runs a recursive receive loop.
The initial state should include the limit and current count.
</details>

<details>
<summary>Hint 2: Tracking request counts</summary>
Store the count in the recursive loop state. Each `check_request` increments the count.
When the window resets, set count back to 0.
</details>

<details>
<summary>Hint 3: Time windows</summary>
Use `Process.send_after/3` to send yourself a `:reset` message after the window expires.
This is cleaner than tracking timestamps.
</details>

<details>
<summary>Hint 4: Returning results to the caller</summary>
Include the caller's PID in messages: `{:check, caller_pid}`.
Use `send/2` to reply back to the caller.
</details>

<details>
<summary>Hint 5: Handling the response</summary>
After sending a message, use `receive` with a timeout to get the response:
```elixir
receive do
  {:ok, remaining} -> {:ok, remaining}
  {:error, reason} -> {:error, reason}
after
  5000 -> {:error, :timeout}
end
```
</details>

## Common Mistakes

1. **Forgetting to recurse** - The receive loop must call itself to continue processing messages.

2. **Blocking the process** - Long-running work in receive blocks other messages. Consider spawning child processes for heavy work.

3. **Memory leaks in mailboxes** - If you never receive certain message patterns, they accumulate in the mailbox forever.

4. **Not handling unknown messages** - Add a catch-all clause to avoid mailbox buildup:
```elixir
receive do
  {:known, data} -> handle(data)
  _unknown -> :ok  # Discard unknown messages
end
```

5. **Race conditions in tests** - Remember that `send` is async. Use receive with timeout to wait for responses.

## Workshop Discussion Points

1. How does process isolation make debugging easier compared to shared-memory concurrency?
2. What are the trade-offs of message passing vs shared state?
3. When would you use linking vs monitoring?
4. How would you design a process-based system for handling 10,000 concurrent users?

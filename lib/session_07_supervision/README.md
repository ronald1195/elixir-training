# Session 7: Supervision Trees - Let It Crash

## Learning Objectives

By the end of this session, you will:
- Understand the "let it crash" philosophy and why it leads to more reliable systems
- Design supervision trees with appropriate restart strategies
- Implement child specifications for different process types
- Build fault-tolerant systems that recover automatically
- Apply supervision patterns to financial service scenarios

## Key Concepts

### The "Let It Crash" Philosophy

In traditional OOP, we try to handle every possible error:

```java
// Java - Defensive programming
public Result processPayment(Payment payment) {
    try {
        validatePayment(payment);
        checkBalance(payment);
        executeTransfer(payment);
        return Result.success();
    } catch (ValidationException e) {
        return Result.error("Invalid payment");
    } catch (InsufficientFundsException e) {
        return Result.error("Insufficient funds");
    } catch (TransferException e) {
        return Result.error("Transfer failed");
    } catch (Exception e) {
        log.error("Unexpected error", e);
        return Result.error("Unknown error");
    }
}
```

In Elixir, we handle expected cases but let unexpected errors crash:

```elixir
# Elixir - Let unexpected errors crash
def process_payment(payment) do
  with :ok <- validate_payment(payment),
       :ok <- check_balance(payment),
       {:ok, result} <- execute_transfer(payment) do
    {:ok, result}
  else
    {:error, :invalid_payment} -> {:error, "Invalid payment"}
    {:error, :insufficient_funds} -> {:error, "Insufficient funds"}
    # Unexpected errors? Let it crash! Supervisor will restart.
  end
end
```

**Why this works:**
- Supervisors automatically restart crashed processes
- The new process starts in a known good state
- Simpler code - no need to handle impossible states
- Errors are isolated - one crash doesn't bring down the system

### Supervisors

A Supervisor is a process that monitors child processes and restarts them when they crash:

```elixir
defmodule MyApp.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    children = [
      # Child specifications
      {MyApp.Cache, []},
      {MyApp.PaymentProcessor, []},
      {MyApp.NotificationService, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
```

### Restart Strategies

#### `:one_for_one` - Independent Children

If one child crashes, only restart that child.

```
    ┌─────────────────────────┐
    │       Supervisor        │
    │    (one_for_one)        │
    └──────────┬──────────────┘
               │
    ┌──────────┼──────────┐
    ▼          ▼          ▼
┌───────┐ ┌───────┐ ┌───────┐
│Cache A│ │Cache B│ │Cache C│   ← Independent caches
└───────┘ └───────┘ └───────┘
            ↓
         crashes
            ↓
    Only Cache B restarts
```

**Use when:** Children are independent, one crashing doesn't affect others.

#### `:one_for_all` - All or Nothing

If one child crashes, restart ALL children.

```
    ┌─────────────────────────┐
    │       Supervisor        │
    │    (one_for_all)        │
    └──────────┬──────────────┘
               │
    ┌──────────┼──────────┐
    ▼          ▼          ▼
┌───────┐ ┌───────┐ ┌───────┐
│ Auth  │ │Session│ │ API   │   ← Tightly coupled
└───────┘ └───────┘ └───────┘
            ↓
       Any crashes
            ↓
    ALL children restart
```

**Use when:** Children are tightly coupled and share state.

#### `:rest_for_one` - Sequential Dependencies

If a child crashes, restart it AND all children started after it.

```
    ┌─────────────────────────┐
    │       Supervisor        │
    │    (rest_for_one)       │
    └──────────┬──────────────┘
               │
    ┌──────────┼──────────┐
    ▼          ▼          ▼
┌───────┐ ┌───────┐ ┌───────┐
│  DB   │→│ Cache │→│  API  │   ← Sequential dependencies
└───────┘ └───────┘ └───────┘
 (start 1) (start 2) (start 3)
              ↓
          crashes
              ↓
    Cache and API restart
    (DB keeps running)
```

**Use when:** Later children depend on earlier children.

### Child Specifications

A child spec tells the supervisor how to start and manage a child:

```elixir
# Simple - module implements child_spec/1
children = [
  MyWorker,                    # Uses default child_spec
  {MyWorker, arg: :value},     # With init argument
]

# Explicit child spec
children = [
  %{
    id: :my_worker,            # Unique identifier
    start: {MyWorker, :start_link, [[]]},  # {Module, function, args}
    restart: :permanent,       # :permanent | :temporary | :transient
    shutdown: 5000,            # Milliseconds to wait for graceful shutdown
    type: :worker              # :worker | :supervisor
  }
]
```

### Restart Options

- `:permanent` - Always restart (default for GenServers)
- `:temporary` - Never restart (for one-time tasks)
- `:transient` - Only restart if it exits abnormally

```elixir
# Permanent: Always restart (e.g., core services)
%{id: :payment_processor, restart: :permanent, ...}

# Temporary: Never restart (e.g., one-time report generation)
%{id: :report_generator, restart: :temporary, ...}

# Transient: Restart only on crash (e.g., job workers)
%{id: :job_worker, restart: :transient, ...}
```

### Shutdown Options

- Integer: Wait N milliseconds for graceful shutdown
- `:infinity`: Wait forever (for supervisors)
- `:brutal_kill`: Kill immediately

```elixir
# Give the payment processor time to complete transactions
%{id: :payment_processor, shutdown: 30_000, ...}

# Kill the cache immediately - state can be rebuilt
%{id: :cache, shutdown: :brutal_kill, ...}
```

### Real-World Pattern: Payment Processing Supervisor

```elixir
defmodule Payments.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    children = [
      # Database connection pool - must start first
      {Payments.Repo, []},

      # Payment processor depends on DB
      {Payments.Processor, []},

      # Notification service is independent
      {Payments.Notifier, []},

      # Worker pool for async jobs
      {Task.Supervisor, name: Payments.TaskSupervisor}
    ]

    # rest_for_one: if Repo crashes, restart Processor too
    Supervisor.init(children, strategy: :rest_for_one)
  end
end
```

### DynamicSupervisor for Runtime Children

When you need to start/stop children dynamically:

```elixir
defmodule Payments.ConnectionSupervisor do
  use DynamicSupervisor

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  # Start a new connection at runtime
  def start_connection(gateway_config) do
    DynamicSupervisor.start_child(__MODULE__, {
      Payments.GatewayConnection,
      gateway_config
    })
  end

  # Stop a connection
  def stop_connection(pid) do
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end
end
```

## Exercises

### Exercise 1: Payment Supervisor

Design and implement a supervision tree for a payment processing system.

Open `lib/session_07_supervision/payment_supervisor.ex` and implement the supervisor.

```bash
mix test test/session_07_supervision/payment_supervisor_test.exs --include pending
```

## Hints

<details>
<summary>Hint 1: Choosing a strategy</summary>
Think about dependencies:
- Does the payment processor need the cache?
- What happens if the rate limiter crashes?
- Should everything restart together?

For services with sequential dependencies, use `:rest_for_one`.
</details>

<details>
<summary>Hint 2: Child specs</summary>
If your module uses `use GenServer`, it automatically defines `child_spec/1`.
You can override it or provide explicit specs:
```elixir
def child_spec(opts) do
  %{
    id: __MODULE__,
    start: {__MODULE__, :start_link, [opts]},
    restart: :permanent
  }
end
```
</details>

<details>
<summary>Hint 3: Testing supervisors</summary>
- Start the supervisor
- Get child pids with `Supervisor.which_children/1`
- Kill a child with `Process.exit(pid, :kill)`
- Verify it restarts (new pid)
</details>

<details>
<summary>Hint 4: Shutdown timeouts</summary>
Payment processors should have generous shutdown timeouts to complete in-flight transactions.
Caches can be killed immediately.
</details>

## Common Mistakes

1. **Wrong restart strategy** - Using `:one_for_one` when children depend on each other leads to inconsistent state.

2. **Short shutdown timeouts** - Killing payment processors mid-transaction can leave things in bad states.

3. **Not using max_restarts** - Without limits, a constantly crashing process can overwhelm the system.

4. **Circular dependencies** - Child A depends on B, B depends on A. Redesign your architecture!

5. **Starting children in wrong order** - In `:rest_for_one`, order matters. Put dependencies first.

## Workshop Discussion Points

1. How do you decide between `:one_for_one` and `:one_for_all`?
2. What should happen when a payment processor crashes mid-transaction?
3. How deep should supervision trees be? When do you add layers?
4. How would you handle a child that keeps crashing?

# Session 4: Umbrella Applications & Project Architecture

## Learning Objectives

By the end of this session, you will:
- Understand umbrella applications and their benefits for large systems
- Know when to use umbrella vs single app architecture
- Navigate and reason about bounded contexts in Elixir
- Design proper dependency relationships between applications
- Apply domain-driven design concepts to Elixir project structure

## Key Concepts

### What is an Umbrella Application?

An umbrella application is a container for multiple child applications that can share dependencies and be managed together. Think of it like a monorepo with clear boundaries:

```
my_payments_umbrella/
├── apps/
│   ├── payments_core/       # Business logic
│   ├── payments_api/        # HTTP API
│   ├── payments_worker/     # Background processing
│   └── notifications/       # Notification service
├── config/                  # Shared configuration
└── mix.exs                  # Root project file
```

### OOP Comparison: Microservices in a Monorepo

In Java/C# enterprise systems, you might have:

```
PaymentsService/
├── PaymentsService.Core/       # Class library
├── PaymentsService.Api/        # Web API project
├── PaymentsService.Worker/     # Background service
└── PaymentsService.sln         # Solution file
```

Elixir umbrella applications provide similar separation but with:
- Shared BEAM runtime (processes can communicate directly)
- Single deployment unit (but can be split later)
- Clear compile-time dependency enforcement

### Bounded Contexts

Each app in an umbrella should represent a "bounded context" - a logical boundary around related functionality:

```elixir
# apps/payments_core/lib/payments_core.ex
defmodule PaymentsCore do
  @moduledoc """
  Core payment processing logic.

  This context owns:
  - Payment creation and processing
  - Transaction history
  - Refund logic
  """
end

# apps/accounts/lib/accounts.ex
defmodule Accounts do
  @moduledoc """
  Account management context.

  This context owns:
  - User accounts
  - Balance tracking
  - Account limits
  """
end
```

### Dependency Direction

Dependencies should flow in one direction - from "outer" apps to "core" apps:

```
    ┌─────────────┐
    │ payments_api │  (depends on core)
    └──────┬──────┘
           │
           ▼
    ┌─────────────┐
    │payments_core│  (no dependencies on other apps)
    └─────────────┘
```

**Wrong:**
```elixir
# In payments_core/mix.exs - DON'T DO THIS
defp deps do
  [{:payments_api, in_umbrella: true}]  # Core depending on API!
end
```

**Right:**
```elixir
# In payments_api/mix.exs
defp deps do
  [{:payments_core, in_umbrella: true}]  # API depends on Core
end
```

### When to Use Umbrellas

**Good candidates:**
- Large teams working on distinct features
- Clear domain boundaries (payments, notifications, analytics)
- Different deployment/scaling needs for different parts
- Microservice-ready architecture with shared tooling

**Consider single app when:**
- Small team or solo developer
- Unclear boundaries (still discovering the domain)
- Simple CRUD application
- Tightly coupled features

### Communication Between Apps

Apps in an umbrella can communicate via:

1. **Direct function calls** (compile-time dependency):
```elixir
# In payments_api
PaymentsCore.process_payment(payment_data)
```

2. **PubSub/Events** (runtime, loose coupling):
```elixir
# In payments_core - publish event
Phoenix.PubSub.broadcast(MyApp.PubSub, "payments", {:payment_created, payment})

# In notifications - subscribe
Phoenix.PubSub.subscribe(MyApp.PubSub, "payments")
```

3. **Through a shared database** (be careful with this):
```elixir
# Both apps use the same Repo
MyApp.Repo.insert(payment)
```

### Real-World Financial Services Structure

A typical fintech umbrella might look like:

```
fintech_umbrella/
├── apps/
│   ├── core/               # Shared domain models, money handling
│   ├── accounts/           # Account management, balances
│   ├── payments/           # Payment processing, transactions
│   ├── compliance/         # KYC, AML checks
│   ├── notifications/      # Email, SMS, push notifications
│   ├── reporting/          # Analytics, statement generation
│   ├── api_gateway/        # HTTP API (Phoenix)
│   └── admin/              # Internal admin interface
└── ...
```

### The Alternative: Single App with Contexts

For many projects, a single app with well-organized contexts works better:

```
my_app/
├── lib/
│   ├── my_app/
│   │   ├── accounts/       # Account context
│   │   │   ├── account.ex
│   │   │   ├── balance.ex
│   │   │   └── accounts.ex    # Context module (public API)
│   │   ├── payments/       # Payment context
│   │   │   ├── payment.ex
│   │   │   ├── processor.ex
│   │   │   └── payments.ex    # Context module (public API)
│   │   └── notifications/  # Notification context
│   └── my_app_web/         # Web layer
└── ...
```

The context module provides a clean public API:

```elixir
defmodule MyApp.Payments do
  @moduledoc """
  The Payments context - public API for payment operations.
  """

  alias MyApp.Payments.{Payment, Processor}

  def create_payment(attrs) do
    # Implementation
  end

  def process_payment(payment) do
    Processor.process(payment)
  end

  def list_payments(account_id) do
    # Implementation
  end
end
```

## Exercises

### Exercise 1: Project Explorer

This exercise is conceptual - you'll write functions that would analyze and report on project structure. While we're not creating an actual umbrella in this training repo, understanding these patterns is essential.

Open `lib/session_04_umbrella/project_explorer.ex` and implement functions to:
- Analyze module dependencies
- Detect circular dependencies
- Validate context boundaries
- Generate dependency graphs

```bash
mix test test/session_04_umbrella/project_explorer_test.exs --include pending
```

## Hints

<details>
<summary>Hint 1: Analyzing dependencies</summary>
To find dependencies, you can check which modules are referenced in a module's code.
In our exercise, we represent this as a map of module -> list of dependencies.
</details>

<details>
<summary>Hint 2: Detecting cycles</summary>
Use depth-first search (DFS) to detect cycles in a directed graph.
Keep track of visited nodes and nodes in the current path.
</details>

<details>
<summary>Hint 3: Bounded contexts</summary>
A context is typically represented by a top-level namespace.
All modules within a context should primarily depend on modules in the same context or in "lower" contexts.
</details>

<details>
<summary>Hint 4: Layer validation</summary>
Define an ordering of contexts (e.g., Core < Domain < Application < Web).
Dependencies should only flow from higher layers to lower layers.
</details>

## Common Mistakes

1. **Creating circular dependencies** - App A depends on App B which depends on App A. This causes compilation failures and indicates poor boundaries.

2. **Leaking implementation details** - Contexts should expose a clean public API, not internal modules.

3. **Sharing database tables across contexts** - This creates tight coupling. Better to duplicate data or use events.

4. **Over-engineering** - Starting with an umbrella when a single app with contexts would suffice. Start simple, split when needed.

5. **Wrong dependency direction** - Core business logic should not depend on infrastructure (API, database). Infrastructure depends on core.

## Workshop Discussion Points

1. How do you decide when to split a context into its own umbrella app?
2. What are the trade-offs between umbrellas and microservices?
3. How would you handle shared authentication across umbrella apps?
4. When is it appropriate for two contexts to share a database table?

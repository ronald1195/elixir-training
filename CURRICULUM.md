# Elixir Beginner Training Curriculum

**Target Audience:** Engineers with OOP backgrounds (Java, C#, Python) transitioning to Elixir for production application development
**Format:** Workshop sessions with hands-on coding
**Duration:** 15-17 sessions (with optional advanced sessions)

---

## Learning Path Overview

```
Session 1-3:   Foundations (Syntax, FP Mindset, Pattern Matching, Collections)
Session 4-8:   Architecture & Concurrency (Umbrella Apps, Processes, GenServer, Supervision, Oban)
Session 9-10:  Data Layer (Ecto Basics, Advanced Ecto with Multi-tenancy)
Session 11-14: Integration Patterns (HTTP, GraphQL, Broadway/Kafka, gRPC)
Session 15-17: Advanced Patterns (Protocols/Behaviours, Testing, WebSockets)
```

**Note:** This curriculum is optimized for engineers working on large-scale production Elixir applications, covering the technologies and patterns commonly used in the industry.

---

## Session 1: From OOP to Functional - The Elixir Mindset

### Objectives
- Understand why Elixir excels for financial services (fault tolerance, concurrency)
- Grasp immutability and its benefits for correctness
- Write basic Elixir syntax confidently

### Topics
1. **Why Elixir?**
   - The BEAM VM and "let it crash" philosophy
   - Comparison with JVM/CLR approaches to reliability
   - Real-world examples in fintech (Discord, Brex, Square)

2. **Immutability for OOP Developers**
   - No object mutation - data flows through transformations
   - Benefits: no race conditions, easier debugging, audit trails
   - Mental model shift: functions transform data, not objects

3. **Basic Syntax**
   - Modules and functions (no classes!)
   - Data types: atoms, tuples, lists, maps, structs
   - The pipe operator `|>` - your new best friend

### Hands-On Exercise
Build a simple `Money` module that handles currency operations without mutation.

```elixir
# Compare OOP approach vs Elixir approach
# OOP: account.deposit(100) mutates the account
# Elixir: new_balance = Account.deposit(account, 100) returns new state
```

---

## Session 2: Pattern Matching - Elixir's Superpower

### Objectives
- Use pattern matching for control flow
- Destructure complex data structures
- Handle multiple function clauses elegantly

### Topics
1. **Pattern Matching Basics**
   - The `=` operator is not assignment
   - Matching on tuples, lists, maps
   - Pin operator `^` for matching existing values

2. **Function Clauses & Guards**
   - Multiple function heads instead of if/else chains
   - Guard clauses for type checking
   - The beauty of exhaustive matching

3. **Real-World Patterns**
   - Parsing API responses: `{:ok, result}` vs `{:error, reason}`
   - Handling Kafka message types
   - Webhook payload routing

### Hands-On Exercise
Build a payment processor that routes different transaction types using pattern matching.

```elixir
defmodule PaymentProcessor do
  def process(%{type: "credit", amount: amount}) when amount > 0 do
    # Handle credit
  end

  def process(%{type: "debit", amount: amount, account_id: id}) do
    # Handle debit
  end

  def process(_invalid) do
    {:error, :invalid_transaction}
  end
end
```

---

## Session 3: Collections & The Enum Module

### Objectives
- Transform data using Enum and Stream
- Understand lazy vs eager evaluation
- Build data pipelines

### Topics
1. **Enum - Your Data Transformation Toolkit**
   - map, filter, reduce - the holy trinity
   - find, group_by, chunk_by for complex operations
   - Composing transformations with pipes

2. **Streams for Large Data**
   - Lazy evaluation for memory efficiency
   - Processing large files/datasets
   - When to use Stream vs Enum

3. **Comprehensions**
   - `for` as a powerful data transformation tool
   - Filters and multiple generators
   - Into different collectables

### Hands-On Exercise
Process a batch of transactions: validate, transform, and aggregate.

```elixir
transactions
|> Stream.filter(&valid?/1)
|> Stream.map(&normalize_currency/1)
|> Enum.group_by(& &1.account_id)
|> Enum.map(fn {account_id, txns} ->
  {account_id, calculate_balance(txns)}
end)
```

---

## Session 4: Umbrella Applications & Project Architecture

### Objectives
- Understand umbrella applications and when to use them
- Navigate multi-app Elixir projects effectively
- Apply bounded context principles to code organization
- Understand cross-app dependencies

### Topics
1. **Umbrella Applications Explained**
   - What are umbrella apps? Why use them?
   - Real-world example: 40+ sub-applications architecture
   - Monolith vs microservices vs umbrella (best of both worlds)

2. **Project Organization**
   - Bounded contexts (Core, Bank, SharedDb, APIs)
   - Where to put new code
   - Avoiding circular dependencies
   - Shared vs isolated dependencies

3. **Real-World Application Structure**
   - `/apps/core` - Business logic and orchestration
   - `/apps/integrations` - External service integrations
   - `/apps/shared_db` - Ecto schemas and database access
   - `/apps/api` and `/apps/admin_api` - GraphQL endpoints
   - Domain-specific apps (accounting, notifications, payments, etc.)

4. **Working Across Apps**
   - How apps communicate
   - Public vs internal APIs
   - Testing across app boundaries

### Hands-On Exercise
Explore a mini umbrella application with multiple apps, add a new feature that spans contexts.

```elixir
# Understanding when code belongs in different apps
# apps/core/lib/core/cards.ex vs
# apps/bank/lib/bank/card_issuer.ex vs
# apps/shared_db/lib/shared_db/cards/card.ex
```

---

## Session 5: Processes - Lightweight Concurrency

### Objectives
- Understand the Actor model
- Spawn processes and send messages
- Recognize when to use processes

### Topics
1. **The Actor Model**
   - Each process has isolated state
   - Communication only through messages
   - No shared memory = no locks needed

2. **Spawning and Messaging**
   - `spawn`, `spawn_link`, `spawn_monitor`
   - `send` and `receive`
   - Process mailboxes

3. **Process Isolation & Fault Tolerance**
   - One process crashing doesn't affect others
   - Links and monitors for failure detection
   - This is why Elixir is great for financial systems

### Hands-On Exercise
Build a simple in-memory rate limiter using processes.

---

## Session 6: GenServer - The Foundation of OTP

### Objectives
- Implement stateful services with GenServer
- Understand call vs cast
- Handle process lifecycle

### Topics
1. **GenServer Basics**
   - `init`, `handle_call`, `handle_cast`, `handle_info`
   - Synchronous (call) vs asynchronous (cast)
   - State management

2. **Building a Real Service**
   - Connection pools
   - Caches
   - Rate limiters

3. **Common Patterns**
   - Timeouts and `:continue`
   - Handling external messages
   - Testing GenServers

### Hands-On Exercise
Build a `CreditLimitCache` GenServer that caches credit limits with TTL.

```elixir
defmodule CreditLimitCache do
  use GenServer

  def get_limit(account_id) do
    GenServer.call(__MODULE__, {:get, account_id})
  end

  def set_limit(account_id, limit, ttl \\ 60_000) do
    GenServer.cast(__MODULE__, {:set, account_id, limit, ttl})
  end

  # Implement callbacks...
end
```

---

## Session 7: Supervision Trees - Let It Crash

### Objectives
- Design supervision strategies
- Build fault-tolerant service hierarchies
- Understand restart strategies

### Topics
1. **Supervisor Basics**
   - one_for_one, one_for_all, rest_for_one
   - Child specifications
   - Dynamic vs static children

2. **Designing for Failure**
   - What should happen when X crashes?
   - Isolation boundaries
   - Graceful degradation

3. **Real Architecture Patterns**
   - Pool supervision
   - Circuit breakers
   - Health checks

### Hands-On Exercise
Design a supervision tree for a payment processing service with:
- Worker pool for processing
- Cache for rate limits
- Health check process

---

## Session 8: Oban - Background Job Processing

### Objectives
- Understand when to use background jobs vs GenServers
- Implement reliable background workers with Oban
- Handle job retries and dead letter queues
- Design for idempotency

### Topics
1. **Background Jobs vs Long-Running Processes**
   - When to use Oban (jobs) vs GenServer (stateful processes)
   - Job queues for async work
   - Common use cases (50+ queues, multiple workers in large applications)

2. **Oban Fundamentals**
   - Defining workers
   - Enqueueing jobs (immediate, scheduled, recurring)
   - Queue configuration and priorities
   - Job lifecycle and states

3. **Reliability Patterns**
   - Automatic retries with exponential backoff
   - Dead letter queues for failed jobs
   - Unique jobs and duplicate prevention
   - Idempotent job design

4. **Production Patterns**
   - Multiple queues with different priorities
   - Scheduled jobs (daily reports, cleanup tasks)
   - Job monitoring and observability
   - Graceful shutdowns

### Hands-On Exercise
Build an invoice processing worker that:
- Processes invoices asynchronously
- Retries on transient failures
- Handles duplicates gracefully
- Reports failures to a dead letter queue

```elixir
defmodule InvoiceProcessor do
  use Oban.Worker, queue: :invoices, max_attempts: 3

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"invoice_id" => id}}) do
    # Process invoice
    # Handle errors with {:error, reason} for retries
    # Or {:discard, reason} to give up
  end
end

# Enqueue a job
%{invoice_id: 123}
|> InvoiceProcessor.new()
|> Oban.insert()
```

---

## Session 9: Ecto - Database Interactions

### Objectives
- Define schemas and changesets
- Write queries with Ecto.Query
- Handle transactions

### Topics
1. **Schemas & Changesets**
   - Defining data structures
   - Validations and casting
   - Virtual fields

2. **Querying**
   - Ecto.Query DSL
   - Composable queries
   - Preloading associations

3. **Transactions & Consistency**
   - Ecto.Multi for complex operations
   - Optimistic locking
   - Handling conflicts

### Hands-On Exercise
Build a `Transactions` context with proper changeset validations for financial data.

---

## Session 10: Advanced Ecto - Multi-tenancy & Complex Patterns

### Objectives
- Implement multi-tenancy patterns (critical for SaaS applications)
- Write complex queries with joins and aggregations
- Use Ecto.Multi for multi-step transactions
- Optimize queries with preloading strategies

### Topics
1. **Multi-tenancy Patterns**
   - Tenant-scoped queries (essential for SaaS applications)
   - Dynamic query composition
   - Preventing data leakage across tenants
   - Foreign key scoping

2. **Advanced Queries**
   - Joins and associations
   - Aggregations (sum, count, group_by)
   - Subqueries
   - Query fragments for complex SQL
   - Window functions

3. **Ecto.Multi - Composable Transactions**
   - Building multi-step operations
   - Rollback on any step failure
   - Dependent steps
   - Pattern used extensively in production

4. **Performance Optimization**
   - N+1 query problems
   - Preload vs join strategies
   - Batch loading
   - Database indexes

### Hands-On Exercise
Build a multi-tenant expense reporting system:
- Ensure all queries are company-scoped
- Create a transaction that updates multiple tables atomically
- Write reports with complex aggregations
- Optimize for performance

```elixir
defmodule ExpenseReport do
  # Multi-step transaction with Ecto.Multi
  def submit_expense_report(company_id, user_id, expense_ids) do
    Multi.new()
    |> Multi.run(:validate_expenses, fn repo, _ ->
      validate_all_expenses_belong_to_company(repo, company_id, expense_ids)
    end)
    |> Multi.insert(:report, build_report_changeset(company_id, user_id))
    |> Multi.update_all(:mark_submitted, mark_expenses_submitted_query(expense_ids), [])
    |> Repo.transaction()
  end
end
```

---

## Session 11: HTTP Clients & External Integrations

### Objectives
- Make HTTP requests with proper error handling
- Parse and validate external responses
- Implement retry logic

### Topics
1. **HTTP Clients (Req, Finch, HTTPoison)**
   - Making requests
   - Handling responses with pattern matching
   - Timeouts and connection pooling

2. **Robust Integration Patterns**
   - Circuit breakers (Fuse library)
   - Retry with exponential backoff
   - Fallback strategies

3. **Response Handling**
   - Parsing JSON safely
   - Validating external data
   - Error normalization

### Hands-On Exercise
Build a robust client for a credit bureau API with retries and circuit breaker.

---

## Session 12: GraphQL with Absinthe

### Objectives
- Understand GraphQL and its benefits for APIs
- Define schemas and resolvers with Absinthe
- Handle authentication and authorization
- Prevent N+1 queries with Dataloader
- Implement subscriptions for real-time updates

### Topics
1. **GraphQL Fundamentals**
   - Why GraphQL? (Modern API architecture)
   - Queries, mutations, subscriptions
   - Schema definition language
   - Comparison with REST

2. **Absinthe Basics**
   - Defining object types
   - Writing resolvers
   - Input validation
   - Error handling

3. **Context & Middleware**
   - Authentication in resolvers
   - Authorization with middleware
   - Context building
   - Plugs in the GraphQL pipeline

4. **Dataloader - Solving N+1 Queries**
   - Batch loading associations
   - Preloading in resolvers
   - Performance optimization
   - Pattern used heavily in user_api/admin_api

5. **Subscriptions**
   - Phoenix.PubSub integration
   - Real-time updates
   - Connection management

### Hands-On Exercise
Build a GraphQL API for expense management:
- Define schema for expenses, users, categories
- Implement queries with nested data
- Use Dataloader to prevent N+1 queries
- Add mutations for creating/updating expenses
- Implement authorization middleware

```elixir
defmodule ExpenseApi.Schema do
  use Absinthe.Schema
  import_types ExpenseApi.Schema.ExpenseTypes

  query do
    field :expenses, list_of(:expense) do
      arg :company_id, non_null(:id)
      resolve &ExpenseResolver.list_expenses/3
    end
  end

  mutation do
    field :submit_expense, :expense do
      arg :input, non_null(:expense_input)
      middleware ExpenseApi.Middleware.Authenticate
      resolve &ExpenseResolver.submit_expense/3
    end
  end
end
```

---

## Session 13: Broadway & Kafka Integration

### Objectives
- Understand event-driven architecture patterns
- Process Kafka messages with Broadway pipelines
- Handle acknowledgment and error scenarios
- Design for idempotent message processing

### Topics
1. **Event-Driven Architecture**
   - Why Kafka? (100+ consumers in large applications)
   - Event sourcing patterns
   - Debezium CDC (database change data capture)
   - Topic organization and naming conventions

2. **Broadway Fundamentals**
   - Declarative data processing pipelines
   - Producer, processor, batcher stages
   - Automatic acknowledgment
   - Concurrency and batching

3. **Kafka with Broadway**
   - BroadwayKafka producer
   - Consumer groups and partition assignment
   - Offset management
   - Message deserialization (JSON, Avro, Protobuf)

4. **Reliability Patterns**
   - Exactly-once semantics (or as close as possible)
   - Idempotent message handlers
   - Dead letter queues
   - Backpressure and rate limiting
   - Handling poison messages

5. **Production Patterns**
   - Sanitizers for Debezium events
   - Event transformation pipelines
   - Cross-service communication via events
   - Monitoring and alerting

### Hands-On Exercise
Build a Broadway pipeline that:
- Consumes transaction events from Kafka
- Processes them in batches
- Handles failures with retries
- Ensures idempotency (duplicate events don't cause issues)

```elixir
defmodule TransactionEventConsumer do
  use Broadway

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {BroadwayKafka.Producer, [
          hosts: [localhost: 9092],
          group_id: "transaction_processor",
          topics: ["transactions.created"]
        ]},
        concurrency: 10
      ],
      processors: [
        default: [concurrency: 20]
      ],
      batchers: [
        default: [batch_size: 100, batch_timeout: 1000]
      ]
    )
  end

  @impl true
  def handle_message(_processor, message, _context) do
    # Process individual message
    # Mark for batching or handle immediately
    message
  end

  @impl true
  def handle_batch(_batcher, messages, _batch_info, _context) do
    # Process batch of messages efficiently
    messages
  end
end
```

---

## Session 14: gRPC Services

### Objectives
- Write effective ExUnit tests
- Test async code and GenServers
- Use mocks appropriately

### Topics
1. **ExUnit Fundamentals**
   - Test structure and assertions
   - Setup and context
   - Tags and filtering

2. **Testing Concurrent Code**
   - Testing GenServers
   - Async tests and sandboxing
   - Process isolation in tests

3. **Mocking & Test Doubles**
   - Mox for behaviour-based mocking
   - When to mock vs when to use real implementations
   - Testing external integrations

### Hands-On Exercise
Write comprehensive tests for:
- The CreditLimitCache GenServer from Session 6
- A Broadway pipeline processor
- GraphQL resolvers with authentication
- Multi-tenancy with Ecto sandboxing

**Production Testing Patterns:**
- Use ExMachina factories for test data
- Test with Ecto sandbox for isolation
- Mock external services with Mox (behavior-based mocking)

---

## Session 10: Kafka Integration

### Objectives
- Produce and consume Kafka messages
- Handle message processing reliably
- Design for idempotency

### Topics
1. **Kafka Basics with Broadway/Elsa**
   - Consumer groups
   - Partitioning strategies
   - Offset management

2. **Message Processing Patterns**
   - Exactly-once semantics (or close to it)
   - Dead letter queues
   - Batch processing

3. **Production Considerations**
   - Backpressure handling
   - Monitoring and observability
   - Schema evolution

### Hands-On Exercise
Build a transaction event consumer that processes financial events idempotently.

---

## Session 14: gRPC Services

### Objectives
- Define and implement gRPC services
- Handle streaming
- Error handling in gRPC

### Topics
1. **Protobuf & Service Definitions**
   - Defining messages
   - Service contracts
   - Code generation

2. **Implementing gRPC Servers**
   - Request handling
   - Streaming (unary, server, client, bidirectional)
   - Interceptors/middleware

3. **gRPC Clients**
   - Connection management
   - Timeouts and deadlines
   - Error handling

### Hands-On Exercise
Implement a gRPC service for credit limit checks.

---

## Session 15: Protocols, Behaviours & Polymorphism

### Objectives
- Understand polymorphism in Elixir (protocols vs behaviours)
- Implement protocols for polymorphic dispatch
- Define and implement behaviours for contracts
- Apply dependency injection patterns in production code

### Topics
1. **Protocols - Polymorphism for Data**
   - What are protocols?
   - Defining and implementing protocols
   - Protocol dispatch
   - Examples: String.Chars, Enumerable, Inspect

2. **Behaviours - Contracts for Modules**
   - Defining behaviours with `@callback`
   - Implementing behaviours
   - Compile-time contract verification
   - Comparison with OOP interfaces

3. **Real-World Patterns**
   - `PaymentGateway` behaviour with multiple implementations
     - StripeClient, PayPalClient, SquareClient
   - Notification protocols for different channels
   - Feature flag behaviours (feature toggle abstraction)
   - Payment method handlers

4. **Dependency Injection**
   - Application config for behaviour selection
   - Runtime module selection
   - Testing with mock implementations (via behaviours + Mox)

### Hands-On Exercise
Build a payment gateway abstraction:
- Define a `PaymentGateway` behaviour
- Implement for multiple providers (Stripe, PayPal, Square)
- Use protocols for formatting payment responses
- Inject the implementation via config

```elixir
# Define behaviour
defmodule PaymentGateway do
  @callback charge(amount :: Money.t(), source :: String.t()) ::
    {:ok, transaction_id :: String.t()} | {:error, reason :: String.t()}

  @callback refund(transaction_id :: String.t()) ::
    {:ok, refund_id :: String.t()} | {:error, reason :: String.t()}
end

# Implementations
defmodule StripeGateway do
  @behaviour PaymentGateway

  @impl true
  def charge(amount, source), do: # ...

  @impl true
  def refund(transaction_id), do: # ...
end

# Protocol for formatting
defprotocol PaymentFormatter do
  @doc "Format payment details for display"
  def format(payment)
end

defimpl PaymentFormatter, for: CreditCard do
  def format(%CreditCard{last_four: last_four}),
    do: "Card ending in #{last_four}"
end

defimpl PaymentFormatter, for: BankAccount do
  def format(%BankAccount{account_number: num}),
    do: "Bank account #{num}"
end
```

---

## Session 16: Testing in Elixir

### Objectives
- Implement WebSocket connections
- Handle webhook receivers
- Build real-time notifications

### Topics
1. **WebSocket Servers**
   - Connection lifecycle
   - Message handling
   - Broadcasting to multiple clients

2. **Webhook Receivers**
   - Verification and security
   - Idempotent processing
   - Async processing patterns

3. **Putting It All Together**
   - Real-time transaction notifications
   - System-wide events
   - Monitoring and debugging

### Hands-On Exercise
Build a real-time transaction notification system.

---

## Session 17: WebSockets & Real-Time Features

### Objectives
- Implement WebSocket connections with Phoenix
- Handle webhook receivers securely
- Build real-time notifications
- Understand PubSub patterns

### Topics
1. **WebSocket Servers with Phoenix**
   - Phoenix Channels
   - Connection lifecycle
   - Message handling
   - Broadcasting to multiple clients
   - Presence tracking

2. **Webhook Receivers**
   - Verification and security (HMAC signatures)
   - Idempotent processing
   - Async processing patterns
   - Handling retries from webhook senders

3. **Phoenix.PubSub**
   - Broadcasting across nodes
   - Topic subscriptions
   - Integration with GraphQL subscriptions
   - Real-time updates in production applications

4. **Putting It All Together**
   - Real-time transaction notifications
   - System-wide events
   - Monitoring and debugging WebSocket connections

### Hands-On Exercise
Build a real-time transaction notification system that:
- Connects users via WebSocket
- Broadcasts transaction events in real-time
- Handles webhook callbacks from banking partners
- Ensures security and idempotency

```elixir
defmodule NotificationChannel do
  use Phoenix.Channel

  def join("transactions:" <> company_id, _params, socket) do
    # Authenticate and authorize
    {:ok, assign(socket, :company_id, company_id)}
  end

  def handle_in("subscribe", %{"account_id" => account_id}, socket) do
    # Subscribe to account-specific events
    {:reply, :ok, socket}
  end

  # Broadcast to all connected clients for a company
  def broadcast_transaction(company_id, transaction) do
    Endpoint.broadcast("transactions:#{company_id}", "new_transaction", transaction)
  end
end
```

---

## Appendix: Additional Topics for Future Sessions

### Advanced OTP
- GenStage and Flow for data pipelines (beyond Broadway)
- DynamicSupervisor patterns
- Registry and process discovery
- Distributed Elixir (libcluster, clustering strategies)

### Advanced Data
- Custom Ecto types (Money, encrypted fields)
- Read replicas and write splitting
- Database connection pooling strategies
- Working with database views and materialized views

### Infrastructure & Integration
- OpenSearch/Elasticsearch integration
- Custom Ecto adapters
- Apache Flink integration patterns
- AWS integrations (S3, SQS, SNS, Secrets Manager)

### Observability & Operations
- Telemetry and metrics (StatsD, Datadog)
- Distributed tracing with Spandex
- Logging best practices (structured logging, log aggregation)
- Hot code upgrades and releases

### Production Application Deep Dives
- Navigating large codebases (Supervisor hierarchy walkthrough)
- Understanding complex domain models (Multi-entity relationships)
- External service abstractions (Payment gateways, APIs)
- State machines with EctoStateMachine
- Working with ExMachina test factories

---

## Resources

### Books
- "Elixir in Action" by Sasa Juric
- "Programming Elixir" by Dave Thomas
- "Designing Elixir Systems with OTP" by James Gray & Bruce Tate

### Online
- [Elixir School](https://elixirschool.com)
- [HexDocs](https://hexdocs.pm)
- [Elixir Forum](https://elixirforum.com)

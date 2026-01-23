# Elixir Beginner Training Curriculum

**Target Audience:** Engineers with OOP backgrounds (Java, C#, Python) transitioning to Elixir
**Format:** Workshop sessions with hands-on coding
**Duration:** 8-12 sessions (expandable)

---

## Learning Path Overview

```
Session 1-3:   Foundations (Syntax, FP Mindset, Pattern Matching)
Session 4-6:   Concurrency & OTP (Processes, GenServer, Supervision)
Session 7-9:   Data & Integration (Ecto, HTTP Clients, Testing)
Session 10-12: Production Patterns (Kafka, gRPC, WebSockets)
```

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

## Session 4: Processes - Lightweight Concurrency

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

## Session 5: GenServer - The Foundation of OTP

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

## Session 6: Supervision Trees - Let It Crash

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

## Session 7: Ecto - Database Interactions

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

## Session 8: HTTP Clients & External Integrations

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

## Session 9: Testing in Elixir

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
Write comprehensive tests for the CreditLimitCache from Session 5.

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

## Session 11: gRPC Services

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

## Session 12: WebSockets & Real-Time Features

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

## Appendix: Additional Topics for Future Sessions

### Advanced OTP
- GenStage and Flow for data pipelines
- DynamicSupervisor patterns
- Registry and process discovery

### Advanced Data
- Custom Ecto types
- Multi-tenancy patterns
- Read replicas and write splitting

### Infrastructure
- OpenSearch/Elasticsearch integration
- Custom Ecto adapters
- Apache Flink integration patterns

### Observability
- Telemetry and metrics
- Distributed tracing
- Logging best practices

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

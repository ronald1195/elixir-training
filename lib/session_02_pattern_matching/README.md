# Session 2: Pattern Matching - Elixir's Superpower

## Learning Objectives

By the end of this session, you will:
- Use pattern matching for control flow instead of if/else chains
- Destructure complex data structures in function heads
- Write multiple function clauses with guards
- Handle real-world patterns like API responses and message routing

## Key Concepts

### The `=` Operator is NOT Assignment

In most languages, `=` assigns a value to a variable. In Elixir, `=` is the **match operator**:

```elixir
# This is pattern matching, not assignment
{:ok, result} = {:ok, 42}
# result is now bound to 42

# This will crash! The pattern doesn't match
{:ok, result} = {:error, "something went wrong"}
# ** (MatchError) no match of right hand side value: {:error, "something went wrong"}
```

This is powerful for:
- Asserting expected shapes of data
- Extracting values from complex structures
- Failing fast when data is unexpected

### Destructuring Data Structures

**Tuples:**
```elixir
{status, code, message} = {:error, 500, "Internal Server Error"}
# status = :error, code = 500, message = "Internal Server Error"
```

**Lists:**
```elixir
[first | rest] = [1, 2, 3, 4]
# first = 1, rest = [2, 3, 4]

[a, b, c] = [1, 2, 3]
# a = 1, b = 2, c = 3
```

**Maps:**
```elixir
%{name: name, account_id: id} = %{name: "Acme Corp", account_id: "ACC-123", balance: 5000}
# name = "Acme Corp", id = "ACC-123"
# Note: We don't have to match ALL keys, just the ones we care about
```

### The Pin Operator `^`

Use `^` to match against an existing variable's value instead of rebinding:

```elixir
expected_status = :ok

# Without pin - this would rebind `expected_status`
{expected_status, value} = {:error, 42}
# expected_status is now :error (rebinding!)

# With pin - this asserts the value must match
{^expected_status, value} = {:error, 42}
# ** (MatchError) - crashes because :error != :ok
```

### Multiple Function Clauses

Instead of if/else chains, use pattern matching in function heads:

```elixir
# OOP style (don't do this in Elixir)
def handle_response(response) do
  if response.status == :ok do
    process_success(response.data)
  else if response.status == :error do
    handle_error(response.reason)
  else
    raise "Unknown status"
  end
end

# Elixir style - pattern match in function heads
def handle_response(%{status: :ok, data: data}) do
  process_success(data)
end

def handle_response(%{status: :error, reason: reason}) do
  handle_error(reason)
end

def handle_response(_unknown) do
  raise "Unknown response format"
end
```

**Benefits:**
- Each clause handles one case clearly
- The compiler warns about unreachable clauses
- Easy to add new cases without modifying existing code

### Guards for Additional Conditions

When pattern matching isn't enough, add guards:

```elixir
def process_transaction(%{amount: amount}) when amount > 0 do
  # Handle positive amounts
end

def process_transaction(%{amount: amount}) when amount < 0 do
  # Handle negative amounts (refunds?)
end

def process_transaction(%{amount: 0}) do
  {:error, :zero_amount}
end
```

Common guards:
- `is_integer/1`, `is_binary/1`, `is_atom/1`, `is_list/1`, `is_map/1`
- `>`, `<`, `>=`, `<=`, `==`, `!=`
- `and`, `or`, `not`
- `in` (for checking membership in a list)

### Real-World Pattern: API Responses

Financial APIs often return different shapes. Pattern matching handles this elegantly:

```elixir
def handle_credit_check({:ok, %{"approved" => true, "limit" => limit}}) do
  {:approved, limit}
end

def handle_credit_check({:ok, %{"approved" => false, "reason" => reason}}) do
  {:denied, reason}
end

def handle_credit_check({:error, %{"code" => code, "message" => msg}}) do
  {:error, {code, msg}}
end

def handle_credit_check({:error, :timeout}) do
  {:error, :service_unavailable}
end
```

### Real-World Pattern: Message Routing

Kafka messages or webhooks often have a `type` field:

```elixir
def process_event(%{"type" => "payment.created"} = event) do
  PaymentHandler.handle_created(event)
end

def process_event(%{"type" => "payment.failed"} = event) do
  PaymentHandler.handle_failed(event)
end

def process_event(%{"type" => "account.updated"} = event) do
  AccountHandler.handle_updated(event)
end

def process_event(%{"type" => type}) do
  Logger.warning("Unknown event type: #{type}")
  :ignored
end
```

## Exercises

### Exercise 1: Payment Processor

Build a payment processor that routes different transaction types using pattern matching.

Open `lib/session_02_pattern_matching/payment_processor.ex` and implement the functions.

```bash
mix test test/session_02_pattern_matching/payment_processor_test.exs
```

### Exercise 2: Response Parser

Parse various API response formats into a normalized structure.

Open `lib/session_02_pattern_matching/response_parser.ex` and implement the functions.

```bash
mix test test/session_02_pattern_matching/response_parser_test.exs
```

### Exercise 3: Message Router

Route webhook/Kafka messages to appropriate handlers based on their type.

Open `lib/session_02_pattern_matching/message_router.ex` and implement the functions.

```bash
mix test test/session_02_pattern_matching/message_router_test.exs
```

## Hints

<details>
<summary>Hint 1: Order matters</summary>
Function clauses are tried from top to bottom. Put more specific patterns before general ones.

```elixir
# Wrong - the first clause catches everything!
def process(transaction), do: :generic
def process(%{type: :credit}), do: :credit  # Never reached!

# Right - specific first
def process(%{type: :credit}), do: :credit
def process(transaction), do: :generic
```
</details>

<details>
<summary>Hint 2: Matching map keys</summary>
You can match string keys or atom keys, but not interchangeably:

```elixir
# Atom keys
%{type: type} = %{type: :credit}

# String keys (common in JSON)
%{"type" => type} = %{"type" => "credit"}
```
</details>

<details>
<summary>Hint 3: Capturing the whole structure</summary>
Use `=` in a pattern to bind both the whole and parts:

```elixir
def process(%{type: type, amount: amount} = transaction) do
  # `transaction` is the whole map
  # `type` and `amount` are extracted values
  Logger.info("Processing #{type}")
  do_something(transaction)
end
```
</details>

<details>
<summary>Hint 4: Default/catch-all clause</summary>
Always consider adding a catch-all clause to handle unexpected input:

```elixir
def process(%{type: :known}), do: :ok
def process(other) do
  {:error, {:unknown_type, other}}
end
```
</details>

## Common Mistakes

1. **Wrong key type** - JSON data has string keys (`"type"`), not atom keys (`:type`). Check your input format!

2. **Clause ordering** - A catch-all pattern `def f(x)` will match everything. Put it last.

3. **Forgetting to handle errors** - What happens when the pattern doesn't match? Consider all cases.

4. **Over-matching** - You don't need to match every key in a map. Only match what you need.

## Workshop Discussion Points

1. How does pattern matching compare to switch/case statements in Java/C#?
2. What are the benefits of failing fast with MatchError vs silently handling bad data?
3. How would you test exhaustiveness of your pattern matching?

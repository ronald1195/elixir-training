# Session 1: From OOP to Functional - The Elixir Mindset

## Learning Objectives

By the end of this session, you will:
- Understand why Elixir is well-suited for financial services
- Grasp immutability and how it differs from OOP
- Write basic Elixir functions using pipes and pattern matching

## Key Concepts

### Immutability: The Core Difference

In OOP, you typically mutate objects:

```java
// Java - mutating the account object
account.deposit(100);
System.out.println(account.getBalance()); // Changed!
```

In Elixir, data is never mutated. Instead, functions return new values:

```elixir
# Elixir - returns a NEW account, original unchanged
new_account = Account.deposit(account, 100)
IO.inspect(account)     # Original - unchanged!
IO.inspect(new_account) # New account with updated balance
```

**Why this matters for financial systems:**
- No race conditions - two processes can't corrupt shared state
- Audit trails are easy - you can keep old versions of data
- Debugging is simpler - data doesn't change unexpectedly

### The Pipe Operator

Instead of nested function calls:
```elixir
# Hard to read
String.trim(String.downcase(String.replace(input, "-", "_")))
```

Use pipes to read left-to-right:
```elixir
# Easy to read - data flows through transformations
input
|> String.replace("-", "_")
|> String.downcase()
|> String.trim()
```

### Modules Instead of Classes

Elixir has no classes. Instead, modules group related functions:

```elixir
defmodule Money do
  def add(amount1, amount2) do
    # Functions take data as arguments
    # No "self" or "this"
    amount1 + amount2
  end
end
```

## Exercises

### Exercise 1: The Money Module

Your task is to implement a `Money` module that handles currency operations.

Open `lib/session_01_basics/money.ex` and implement the stubbed functions.

Run tests with:
```bash
mix test test/session_01_basics/money_test.exs
```

### Exercise 2: Data Transformation Pipeline

Implement a function that processes a raw transaction string into a structured format.

Open `lib/session_01_basics/transaction_parser.ex` and implement the pipeline.

## Hints

<details>
<summary>Hint 1: Money.add/2</summary>
Remember that you're not mutating anything - just return the sum of the two amounts.
</details>

<details>
<summary>Hint 2: Using pipes</summary>
Each function in a pipe receives the result of the previous function as its first argument.
</details>

<details>
<summary>Hint 3: Working with maps</summary>
Create maps with `%{key: value}` syntax. Access values with `map.key` or `map[:key]`.
</details>

## Common Mistakes (from OOP developers)

1. **Trying to modify variables** - Remember, `x = x + 1` doesn't modify `x`, it rebinds the name to a new value.

2. **Looking for constructors** - Use functions like `Money.new(100, :usd)` instead of constructors.

3. **Expecting methods on data** - Call `Money.add(m1, m2)` not `m1.add(m2)`.

# Session 3: Collections & The Enum Module

## Learning Objectives

By the end of this session, you will:
- Master data transformations using the `Enum` module
- Understand when to use `Stream` vs `Enum` for memory efficiency
- Write data pipelines using the pipe operator
- Use comprehensions for complex transformations
- Apply these patterns to real-world financial data processing

## Why This Matters for Financial Services

In financial systems, you're constantly transforming data:
- Processing batches of transactions
- Generating reports and summaries
- Validating and filtering large datasets
- Aggregating spending across accounts and time periods

Elixir's `Enum` module provides a powerful, composable toolkit for these operations. Unlike imperative loops that modify state, Enum functions transform data immutably - creating audit trails and making concurrent processing safe.

---

## 1. Enum - Your Data Transformation Toolkit

### The Holy Trinity: map, filter, reduce

In OOP languages, you might write loops that mutate collections:

```java
// Java - imperative approach
List<Transaction> validTransactions = new ArrayList<>();
for (Transaction txn : transactions) {
    if (txn.amount > 0) {
        validTransactions.add(txn);
    }
}

double total = 0;
for (Transaction txn : validTransactions) {
    total += txn.amount;
}
```

In Elixir, you transform data through a pipeline:

```elixir
# Elixir - functional approach
total =
  transactions
  |> Enum.filter(fn txn -> txn.amount > 0 end)
  |> Enum.map(fn txn -> txn.amount end)
  |> Enum.sum()
```

### Common Enum Functions

```elixir
# map - transform each element
[1, 2, 3]
|> Enum.map(fn x -> x * 2 end)
# => [2, 4, 6]

# filter - keep elements matching a condition
[1, 2, 3, 4]
|> Enum.filter(fn x -> rem(x, 2) == 0 end)
# => [2, 4]

# reduce - aggregate into a single value
[1, 2, 3, 4]
|> Enum.reduce(0, fn x, acc -> x + acc end)
# => 10

# Shorthand with capture operator
[1, 2, 3] |> Enum.map(&(&1 * 2))
```

### More Powerful Enum Functions

```elixir
# find - get first matching element
transactions
|> Enum.find(fn txn -> txn.id == "txn_123" end)
# => %{id: "txn_123", ...} or nil

# group_by - organize by a key
transactions
|> Enum.group_by(fn txn -> txn.account_id end)
# => %{"acc_1" => [...], "acc_2" => [...]}

# chunk_by - group consecutive elements by a function
[1, 1, 2, 2, 2, 3]
|> Enum.chunk_by(fn x -> x end)
# => [[1, 1], [2, 2, 2], [3]]

# chunk_every - split into fixed-size groups
[1, 2, 3, 4, 5, 6]
|> Enum.chunk_every(2)
# => [[1, 2], [3, 4], [5, 6]]

# reject - opposite of filter
[1, 2, 3, 4]
|> Enum.reject(fn x -> rem(x, 2) == 0 end)
# => [1, 3]

# any? / all? - check conditions
Enum.any?([1, 2, 3], fn x -> x > 2 end)  # => true
Enum.all?([1, 2, 3], fn x -> x > 0 end)  # => true

# take / drop - get/skip elements
Enum.take([1, 2, 3, 4], 2)  # => [1, 2]
Enum.drop([1, 2, 3, 4], 2)  # => [3, 4]

# sort_by - custom sorting
transactions
|> Enum.sort_by(fn txn -> txn.amount end, :desc)
```

---

## 2. Streams - Lazy Evaluation for Large Data

### The Problem with Eager Evaluation

```elixir
# Enum creates intermediate lists
1..1_000_000
|> Enum.map(&(&1 * 2))      # Creates 1M element list
|> Enum.filter(&(&1 > 100)) # Creates another list
|> Enum.take(10)            # Finally gets 10 elements
```

Each `Enum` operation creates a new list in memory. For large datasets, this is wasteful.

### Streams to the Rescue

```elixir
# Stream is lazy - only computes what's needed
1..1_000_000
|> Stream.map(&(&1 * 2))      # No computation yet
|> Stream.filter(&(&1 > 100)) # Still no computation
|> Enum.take(10)              # Only now computes (just 10 elements!)
```

### When to Use Stream vs Enum

**Use Enum when:**
- Working with small to medium datasets (< 10k elements)
- You need the entire result
- Simple, one-step transformations

**Use Stream when:**
- Processing large files or datasets
- You only need a subset of results
- Chaining multiple transformations
- Working with infinite sequences

### Real-World Stream Example

```elixir
# Process a large CSV file without loading it all into memory
File.stream!("/path/to/large_file.csv")
|> Stream.drop(1)  # Skip header
|> Stream.map(&String.trim/1)
|> Stream.map(&String.split(&1, ","))
|> Stream.filter(fn [_, amount, _] -> String.to_float(amount) > 1000 end)
|> Stream.map(fn [id, amount, date] ->
  %{transaction_id: id, amount: String.to_float(amount), date: date}
end)
|> Enum.to_list()
```

---

## 3. Comprehensions - Declarative Transformations

Comprehensions provide a concise syntax for transformations with multiple generators and filters.

### Basic Comprehension

```elixir
# Instead of this:
Enum.map([1, 2, 3], fn x -> x * 2 end)

# You can write:
for x <- [1, 2, 3], do: x * 2
# => [2, 4, 6]
```

### With Filters

```elixir
for x <- [1, 2, 3, 4, 5],
    rem(x, 2) == 0,  # filter
    do: x * 2
# => [4, 8]
```

### Multiple Generators (Cartesian Product)

```elixir
accounts = ["acc_1", "acc_2"]
statuses = [:pending, :approved]

for account <- accounts,
    status <- statuses,
    do: {account, status}
# => [{"acc_1", :pending}, {"acc_1", :approved},
#     {"acc_2", :pending}, {"acc_2", :approved}]
```

### Into Different Collectables

```elixir
# Into a map
for {k, v} <- [a: 1, b: 2], into: %{}, do: {k, v * 2}
# => %{a: 2, b: 4}

# Into a MapSet
for x <- [1, 2, 2, 3], into: MapSet.new(), do: x
# => MapSet.new([1, 2, 3])
```

### Pattern Matching in Comprehensions

```elixir
transactions = [
  {:ok, %{amount: 100}},
  {:error, :declined},
  {:ok, %{amount: 200}}
]

# Extract only successful transactions
for {:ok, txn} <- transactions, do: txn.amount
# => [100, 200]
```

---

## 4. Building Data Pipelines

The real power comes from composing these operations:

```elixir
defmodule TransactionAnalyzer do
  def daily_spending_by_account(transactions) do
    transactions
    |> Enum.filter(&valid?/1)
    |> Enum.group_by(&extract_date/1)
    |> Enum.map(fn {date, txns} ->
      {date, calculate_totals_by_account(txns)}
    end)
    |> Enum.into(%{})
  end

  defp valid?(%{status: :approved, amount: amount}) when amount > 0, do: true
  defp valid?(_), do: false

  defp extract_date(%{timestamp: timestamp}) do
    timestamp
    |> DateTime.to_date()
  end

  defp calculate_totals_by_account(txns) do
    txns
    |> Enum.group_by(& &1.account_id)
    |> Enum.map(fn {account_id, txns} ->
      total = Enum.reduce(txns, 0, fn txn, acc -> acc + txn.amount end)
      {account_id, total}
    end)
    |> Enum.into(%{})
  end
end
```

---

## 5. Performance Tips

### Use the Right Tool

```elixir
# BAD - multiple passes through the list
transactions
|> Enum.filter(&(&1.amount > 0))
|> Enum.map(&(&1.amount))
|> Enum.sum()

# BETTER - single pass with reduce
transactions
|> Enum.reduce(0, fn
  %{amount: amount}, acc when amount > 0 -> acc + amount
  _, acc -> acc
end)

# OR - use Enum.sum_by (available in newer Elixir versions)
transactions
|> Enum.filter(&(&1.amount > 0))
|> Enum.sum_by(&(&1.amount))
```

### Avoid Unnecessary Conversions

```elixir
# BAD - converts to list multiple times
1..1000
|> Enum.to_list()
|> Enum.map(&(&1 * 2))
|> Enum.filter(&(&1 > 100))

# GOOD - ranges implement Enumerable protocol
1..1000
|> Enum.map(&(&1 * 2))
|> Enum.filter(&(&1 > 100))
```

---

## Exercises

You'll implement two modules:

1. **TransactionBatchProcessor** - Process batches of financial transactions
   - Validate transactions
   - Filter by criteria
   - Calculate aggregations
   - Group by various dimensions

2. **ReportGenerator** - Generate reports from large datasets
   - Use Streams for memory-efficient processing
   - Calculate spending summaries
   - Find top spenders
   - Detect anomalies

---

## Tips & Hints

<details>
<summary>Hint 1: Using Enum.group_by</summary>

`Enum.group_by/2` is perfect when you need to organize data by a key:

```elixir
transactions
|> Enum.group_by(fn txn -> txn.account_id end)
# Returns: %{account_id => [transactions]}
```

You can also provide a value function:

```elixir
transactions
|> Enum.group_by(
  fn txn -> txn.account_id end,     # Key function
  fn txn -> txn.amount end          # Value function
)
# Returns: %{account_id => [amounts]}
```
</details>

<details>
<summary>Hint 2: Chaining with `|>`</summary>

Break complex operations into clear steps:

```elixir
def process(transactions) do
  transactions
  |> step_1_filter()
  |> step_2_transform()
  |> step_3_aggregate()
end
```

Each step should do one thing and return the data in the format the next step needs.
</details>

<details>
<summary>Hint 3: Pattern Matching in Function Heads</summary>

Combine pattern matching with Enum for cleaner code:

```elixir
def process_status({:ok, txn}), do: txn.amount
def process_status({:error, _}), do: 0

transactions
|> Enum.map(&process_status/1)
|> Enum.sum()
```
</details>

<details>
<summary>Hint 4: When to Use Stream</summary>

If you're processing more than a few thousand items or reading from a file, use Stream:

```elixir
# For large data
large_dataset
|> Stream.filter(&valid?/1)
|> Stream.map(&transform/1)
|> Enum.take(100)  # Only process what's needed
```
</details>

---

## Common Pitfalls

1. **Don't forget to `Enum.to_list()` a Stream when you need the full result**
   ```elixir
   # Returns a Stream, not a list!
   result = 1..100 |> Stream.map(&(&1 * 2))

   # Convert to list when needed
   result = 1..100 |> Stream.map(&(&1 * 2)) |> Enum.to_list()
   ```

2. **Watch out for `nil` values**
   ```elixir
   # This will crash if any amount is nil
   Enum.sum([1, 2, nil])  # ** (ArithmeticError)

   # Filter out nils first
   [1, 2, nil]
   |> Enum.reject(&is_nil/1)
   |> Enum.sum()
   ```

3. **Enum.map returns a list, even if you give it a map**
   ```elixir
   %{a: 1, b: 2}
   |> Enum.map(fn {k, v} -> {k, v * 2} end)
   # => [a: 2, b: 4]  (keyword list, not a map!)

   # Use Enum.into to convert back
   %{a: 1, b: 2}
   |> Enum.map(fn {k, v} -> {k, v * 2} end)
   |> Enum.into(%{})
   # => %{a: 2, b: 4}
   ```

---

## Additional Resources

- [Elixir Enum documentation](https://hexdocs.pm/elixir/Enum.html)
- [Elixir Stream documentation](https://hexdocs.pm/elixir/Stream.html)
- [Comprehensions guide](https://hexdocs.pm/elixir/comprehensions.html)

---

## Running the Exercises

```bash
# Run all Session 3 tests
mix session3

# Run in watch mode (if you have mix test.watch installed)
mix test.watch test/session_03_collections/

# Run a specific test file
mix test test/session_03_collections/transaction_batch_processor_test.exs
```

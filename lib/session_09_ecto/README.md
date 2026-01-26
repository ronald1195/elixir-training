# Session 9: Ecto Basics - Database Interactions

## Learning Objectives

By the end of this session, you will:
- Define Ecto schemas with proper types and associations
- Write changesets for validations and data transformations
- Perform CRUD operations using Ecto.Repo
- Write queries using Ecto.Query
- Use transactions for atomic operations

## Key Concepts

### What is Ecto?

Ecto is Elixir's database toolkit. Unlike ORMs that hide SQL, Ecto embraces the database:
- **Schemas** define your data structures
- **Changesets** handle validation and casting
- **Queries** are composable and explicit
- **Repo** handles database operations

### OOP Comparison: Active Record vs Ecto

In Rails (Active Record), models mix everything:

```ruby
# Ruby/Rails - Model does everything
class Account < ApplicationRecord
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :balance, numericality: { greater_than_or_equal_to: 0 }

  def deposit(amount)
    update!(balance: balance + amount)
  end
end

account = Account.find(1)
account.deposit(100)
```

In Ecto, concerns are separated:

```elixir
# Elixir/Ecto - Separated concerns

# Schema - defines structure
defmodule MyApp.Account do
  use Ecto.Schema

  schema "accounts" do
    field :email, :string
    field :balance, :integer, default: 0
    timestamps()
  end
end

# Changeset - handles validation
def changeset(account, attrs) do
  account
  |> cast(attrs, [:email, :balance])
  |> validate_required([:email])
  |> validate_format(:email, ~r/@/)
  |> validate_number(:balance, greater_than_or_equal_to: 0)
end

# Context - business logic
defmodule MyApp.Accounts do
  def deposit(account, amount) do
    account
    |> change(balance: account.balance + amount)
    |> Repo.update()
  end
end
```

### Defining Schemas

```elixir
defmodule MyApp.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :amount, :integer           # Amount in cents
    field :type, Ecto.Enum, values: [:credit, :debit]
    field :status, :string, default: "pending"
    field :reference, :string
    field :metadata, :map, default: %{}

    belongs_to :account, MyApp.Account

    timestamps()  # Adds inserted_at and updated_at
  end
end
```

### Field Types

```elixir
# Common types
field :name, :string
field :amount, :integer
field :rate, :decimal
field :is_active, :boolean
field :balance, :float           # Avoid for money!
field :data, :map
field :tags, {:array, :string}

# Date/time types
field :date, :date
field :time, :time
field :occurred_at, :utc_datetime
field :processed_at, :naive_datetime

# Special types
field :status, Ecto.Enum, values: [:pending, :completed, :failed]
field :uuid, :binary_id
```

### Changesets

Changesets validate and transform data:

```elixir
defmodule MyApp.Account do
  use Ecto.Schema
  import Ecto.Changeset

  schema "accounts" do
    field :email, :string
    field :name, :string
    field :balance, :integer, default: 0
    timestamps()
  end

  def changeset(account, attrs) do
    account
    |> cast(attrs, [:email, :name, :balance])  # Allow these fields
    |> validate_required([:email, :name])       # These must be present
    |> validate_format(:email, ~r/@/)           # Email format
    |> validate_length(:name, min: 2, max: 100) # Name length
    |> validate_number(:balance, greater_than_or_equal_to: 0)
    |> unique_constraint(:email)                # DB constraint
  end

  # Different changeset for updates
  def update_changeset(account, attrs) do
    account
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 100)
  end
end
```

### Common Validations

```elixir
changeset
|> validate_required([:field1, :field2])
|> validate_format(:email, ~r/@/)
|> validate_length(:name, min: 2, max: 100)
|> validate_number(:amount, greater_than: 0)
|> validate_inclusion(:status, ["active", "inactive"])
|> validate_exclusion(:role, ["admin"])
|> validate_confirmation(:password)
|> unique_constraint(:email)
|> foreign_key_constraint(:account_id)
|> check_constraint(:balance, name: :balance_must_be_positive)
```

### Custom Validations

```elixir
def changeset(account, attrs) do
  account
  |> cast(attrs, [:amount, :currency])
  |> validate_currency_amount()
end

defp validate_currency_amount(changeset) do
  validate_change(changeset, :amount, fn :amount, amount ->
    currency = get_field(changeset, :currency)

    cond do
      currency == "JPY" and rem(amount, 1) != 0 ->
        [amount: "JPY cannot have decimal amounts"]
      amount <= 0 ->
        [amount: "must be positive"]
      true ->
        []
    end
  end)
end
```

### CRUD Operations

```elixir
# Create
{:ok, account} =
  %Account{}
  |> Account.changeset(%{email: "user@example.com", name: "Alice"})
  |> Repo.insert()

# Read
account = Repo.get(Account, 1)
account = Repo.get!(Account, 1)  # Raises if not found
account = Repo.get_by(Account, email: "user@example.com")

# Update
{:ok, updated} =
  account
  |> Account.changeset(%{name: "Bob"})
  |> Repo.update()

# Delete
{:ok, deleted} = Repo.delete(account)
```

### Ecto.Query

```elixir
import Ecto.Query

# Simple queries
Account
|> where([a], a.status == "active")
|> Repo.all()

# With bindings
Account
|> where([a], a.balance > ^minimum_balance)
|> order_by([a], desc: a.balance)
|> limit(10)
|> Repo.all()

# Joins
Transaction
|> join(:inner, [t], a in Account, on: t.account_id == a.id)
|> where([t, a], a.status == "active")
|> select([t, a], {t.amount, a.email})
|> Repo.all()

# Aggregations
Transaction
|> where([t], t.type == :credit)
|> select([t], sum(t.amount))
|> Repo.one()

# Named bindings
Transaction
|> join(:inner, [t], a in Account, on: t.account_id == a.id, as: :account)
|> where([account: a], a.status == "active")
|> Repo.all()
```

### Transactions

```elixir
# Simple transaction
Repo.transaction(fn ->
  {:ok, sender} = debit_account(sender, amount)
  {:ok, receiver} = credit_account(receiver, amount)
  {:ok, sender, receiver}
end)

# With Ecto.Multi (recommended)
Multi.new()
|> Multi.update(:sender, debit_changeset(sender, amount))
|> Multi.update(:receiver, credit_changeset(receiver, amount))
|> Multi.insert(:transaction, transaction_changeset(attrs))
|> Repo.transaction()

# Handling Multi results
case Repo.transaction(multi) do
  {:ok, %{sender: sender, receiver: receiver, transaction: txn}} ->
    {:ok, txn}
  {:error, :sender, changeset, _changes} ->
    {:error, :insufficient_funds}
  {:error, failed_operation, changeset, _changes} ->
    {:error, failed_operation}
end
```

## Exercises

### Exercise 1: Account Schema and Context

Build a complete account management system with schemas, changesets, and context functions.

Open `lib/session_09_ecto/account.ex` and `lib/session_09_ecto/accounts.ex`.

```bash
mix test test/session_09_ecto/ --include pending
```

## Hints

<details>
<summary>Hint 1: Schema definition</summary>
```elixir
defmodule MyApp.Account do
  use Ecto.Schema
  import Ecto.Changeset

  schema "accounts" do
    field :name, :string
    # ... more fields
    timestamps()
  end
end
```
</details>

<details>
<summary>Hint 2: Changeset pattern</summary>
```elixir
def changeset(struct, attrs) do
  struct
  |> cast(attrs, [:field1, :field2])
  |> validate_required([:field1])
  |> validate_format(:email, ~r/@/)
end
```
</details>

<details>
<summary>Hint 3: Query composition</summary>
```elixir
def list_active_accounts do
  Account
  |> where([a], a.status == "active")
  |> order_by([a], asc: a.name)
  |> Repo.all()
end
```
</details>

<details>
<summary>Hint 4: Transactions with Multi</summary>
```elixir
Multi.new()
|> Multi.update(:step1, changeset1)
|> Multi.update(:step2, changeset2)
|> Repo.transaction()
```
</details>

## Common Mistakes

1. **Using float for money** - Always use integer cents or Decimal.

2. **Missing validations** - Validate at the changeset level, not just DB constraints.

3. **Ignoring changeset errors** - Always check `changeset.valid?` or pattern match on `{:ok, _}/{:error, _}`.

4. **N+1 queries** - Use `preload` or `join` instead of loading associations in a loop.

5. **Not using transactions** - Multi-step operations should be atomic.

## Workshop Discussion Points

1. When should validation be in changeset vs. database constraint?
2. How do you handle soft deletes?
3. What's the difference between `preload` and `join`?
4. How do you handle migrations in production?

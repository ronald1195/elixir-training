# Session 12: GraphQL with Absinthe

## Learning Objectives

By the end of this session, you will:
- Define GraphQL schemas with Absinthe
- Implement resolvers for queries and mutations
- Use Dataloader to solve N+1 query problems
- Build a complete expense management API

## Key Concepts

### Absinthe Schema

```elixir
defmodule MyApp.Schema do
  use Absinthe.Schema

  query do
    field :expenses, list_of(:expense) do
      resolve &ExpenseResolver.list/3
    end
  end

  mutation do
    field :create_expense, :expense do
      arg :input, non_null(:expense_input)
      resolve &ExpenseResolver.create/3
    end
  end
end
```

### Object Types

```elixir
object :expense do
  field :id, non_null(:id)
  field :amount, non_null(:integer)
  field :category, non_null(:string)
  field :submitter, :user, resolve: dataloader(Users)
end
```

### Dataloader

```elixir
def context(ctx) do
  loader =
    Dataloader.new()
    |> Dataloader.add_source(Users, Users.data())

  Map.put(ctx, :loader, loader)
end
```

## Exercises

### Exercise 1: Expense GraphQL API

Build a complete GraphQL API for expense management.

Open `lib/session_12_graphql/expense_schema.ex`.

```bash
mix test test/session_12_graphql/ --include pending
```

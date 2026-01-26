# Session 10: Advanced Ecto - Multi-tenancy & Complex Patterns

## Learning Objectives

By the end of this session, you will:
- Implement multi-tenant database patterns
- Use Ecto.Multi for complex transactional operations
- Write advanced queries with joins and aggregations
- Optimize queries for performance
- Build an expense reporting system with complex business rules

## Key Concepts

### Multi-tenancy Approaches

**Schema-based**: Each tenant has their own schema/namespace
```elixir
# Set prefix for queries
from(e in Expense, prefix: "tenant_123")
|> Repo.all()
```

**Column-based**: All data in one table with tenant_id column
```elixir
defmodule Expense do
  schema "expenses" do
    field :tenant_id, :string
    field :amount, :integer
    # ...
  end
end

# Always filter by tenant
Expense
|> where([e], e.tenant_id == ^tenant_id)
|> Repo.all()
```

### Ecto.Multi for Complex Operations

```elixir
Multi.new()
|> Multi.insert(:expense, expense_changeset)
|> Multi.update(:budget, fn %{expense: expense} ->
     Budget.deduct_changeset(budget, expense.amount)
   end)
|> Multi.run(:notify, fn _repo, %{expense: expense} ->
     Notifications.send_expense_created(expense)
   end)
|> Repo.transaction()
```

### Advanced Queries

```elixir
# Subqueries
expense_totals =
  from e in Expense,
    group_by: e.category,
    select: %{category: e.category, total: sum(e.amount)}

from e in subquery(expense_totals),
  where: e.total > 10000
```

## Exercises

### Exercise 1: Multi-tenant Expense System

Build a multi-tenant expense reporting system with complex queries and validations.

Open `lib/session_10_advanced_ecto/expense_report.ex`.

```bash
mix test test/session_10_advanced_ecto/ --include pending
```

## Hints

<details>
<summary>Hint 1: Multi-tenant queries</summary>
Create a helper to scope all queries:
```elixir
def scope_to_tenant(query, tenant_id) do
  where(query, [x], x.tenant_id == ^tenant_id)
end
```
</details>

<details>
<summary>Hint 2: Ecto.Multi with dynamic steps</summary>
Use `Multi.run/3` for steps that depend on previous results.
</details>

## Common Mistakes

1. **Forgetting tenant filter** - Every query must include tenant_id check
2. **N+1 queries in reports** - Use aggregations instead of loading all records
3. **Missing indexes** - Add indexes for tenant_id and commonly queried columns

defmodule Session10.ExpenseReport do
  @moduledoc """
  Multi-tenant expense reporting system using advanced Ecto patterns.

  ## Features
  - Multi-tenant data isolation
  - Complex aggregation queries
  - Ecto.Multi for transactional operations
  - Budget validation and tracking

  ## Your Task
  Implement the expense reporting functions with proper multi-tenancy support.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Ecto.Multi
  alias ElixirTraining.Repo

  schema "expense_reports" do
    field(:tenant_id, :string)
    field(:title, :string)
    field(:description, :string)
    field(:amount, :integer)
    field(:category, :string)
    field(:status, :string, default: "pending")
    field(:submitted_by, :string)
    field(:approved_by, :string)
    field(:submitted_at, :utc_datetime)
    field(:approved_at, :utc_datetime)

    timestamps()
  end

  @categories ~w(travel meals office_supplies software equipment other)
  @statuses ~w(draft pending approved rejected)

  @doc """
  Creates a changeset for a new expense report.
  """
  def changeset(expense, attrs) do
    # TODO: Implement changeset with validations
    # - tenant_id, title, amount, category, submitted_by are required
    # - category must be in @categories
    # - status must be in @statuses
    # - amount must be positive
    raise "TODO: Implement changeset/2"
  end

  @doc """
  Creates an expense report for a tenant.
  Validates against monthly budget if set.
  """
  def create_expense(_tenant_id, _attrs) do
    # TODO: Create expense with tenant_id
    raise "TODO: Implement create_expense/2"
  end

  @doc """
  Lists all expenses for a tenant.
  """
  def list_expenses(_tenant_id) do
    # TODO: Query expenses filtered by tenant_id
    raise "TODO: Implement list_expenses/1"
  end

  @doc """
  Lists expenses by category for a tenant.
  """
  def list_by_category(_tenant_id, _category) do
    # TODO: Query expenses filtered by tenant_id and category
    raise "TODO: Implement list_by_category/2"
  end

  @doc """
  Gets expense totals grouped by category for a tenant.

  Returns a map like: %{"travel" => 50000, "meals" => 25000}
  """
  def totals_by_category(_tenant_id) do
    # TODO: Aggregate expenses by category
    raise "TODO: Implement totals_by_category/1"
  end

  @doc """
  Gets monthly expense totals for a tenant.

  Returns a list like: [%{month: ~D[2024-01-01], total: 100000}, ...]
  """
  def monthly_totals(_tenant_id, _year) do
    # TODO: Aggregate expenses by month
    raise "TODO: Implement monthly_totals/2"
  end

  @doc """
  Approves an expense report using Ecto.Multi.
  - Updates status to "approved"
  - Sets approved_by and approved_at
  - Deducts from budget if tracking enabled
  """
  def approve_expense(_expense_id, _approver_id) do
    # TODO: Use Ecto.Multi for atomic approval
    raise "TODO: Implement approve_expense/2"
  end

  @doc """
  Rejects an expense report.
  """
  def reject_expense(_expense_id, _rejector_id, _reason) do
    # TODO: Update status to rejected
    raise "TODO: Implement reject_expense/3"
  end

  @doc """
  Gets top spenders for a tenant.
  Returns list of {submitted_by, total} sorted by total desc.
  """
  def top_spenders(_tenant_id, _limit \\ 10) do
    # TODO: Aggregate by submitted_by, limit results
    raise "TODO: Implement top_spenders/2"
  end

  @doc """
  Checks if tenant is within budget for a category.
  """
  def within_budget?(_tenant_id, _category, _budget_limit) do
    # TODO: Sum expenses for category, compare to limit
    raise "TODO: Implement within_budget?/3"
  end
end

defmodule Session10.ExpenseReport do
  @moduledoc """
  Solution for Session 10: Multi-tenant Expense Report System
  """

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Ecto.Multi
  alias ElixirTraining.Repo

  schema "expense_reports" do
    field :tenant_id, :string
    field :title, :string
    field :description, :string
    field :amount, :integer
    field :category, :string
    field :status, :string, default: "pending"
    field :submitted_by, :string
    field :approved_by, :string
    field :submitted_at, :utc_datetime
    field :approved_at, :utc_datetime

    timestamps()
  end

  @categories ~w(travel meals office_supplies software equipment other)
  @statuses ~w(draft pending approved rejected)

  def changeset(expense, attrs) do
    expense
    |> cast(attrs, [:tenant_id, :title, :description, :amount, :category, :status, :submitted_by])
    |> validate_required([:tenant_id, :title, :amount, :category, :submitted_by])
    |> validate_inclusion(:category, @categories)
    |> validate_inclusion(:status, @statuses)
    |> validate_number(:amount, greater_than: 0)
  end

  def create_expense(tenant_id, attrs) do
    %__MODULE__{}
    |> changeset(Map.put(attrs, :tenant_id, tenant_id))
    |> Repo.insert()
  end

  def list_expenses(tenant_id) do
    __MODULE__
    |> where([e], e.tenant_id == ^tenant_id)
    |> Repo.all()
  end

  def list_by_category(tenant_id, category) do
    __MODULE__
    |> where([e], e.tenant_id == ^tenant_id and e.category == ^category)
    |> Repo.all()
  end

  def totals_by_category(tenant_id) do
    __MODULE__
    |> where([e], e.tenant_id == ^tenant_id)
    |> group_by([e], e.category)
    |> select([e], {e.category, sum(e.amount)})
    |> Repo.all()
    |> Map.new()
  end

  def monthly_totals(tenant_id, year) do
    start_date = Date.new!(year, 1, 1)
    end_date = Date.new!(year, 12, 31)

    __MODULE__
    |> where([e], e.tenant_id == ^tenant_id)
    |> where([e], fragment("date(?)", e.inserted_at) >= ^start_date)
    |> where([e], fragment("date(?)", e.inserted_at) <= ^end_date)
    |> group_by([e], fragment("strftime('%Y-%m', ?)", e.inserted_at))
    |> select([e], %{
      month: fragment("strftime('%Y-%m', ?)", e.inserted_at),
      total: sum(e.amount)
    })
    |> order_by([e], fragment("strftime('%Y-%m', ?)", e.inserted_at))
    |> Repo.all()
  end

  def approve_expense(expense_id, approver_id) do
    now = DateTime.utc_now()

    Multi.new()
    |> Multi.run(:expense, fn repo, _ ->
      case repo.get(__MODULE__, expense_id) do
        nil -> {:error, :not_found}
        expense -> {:ok, expense}
      end
    end)
    |> Multi.update(:approve, fn %{expense: expense} ->
      change(expense, %{
        status: "approved",
        approved_by: approver_id,
        approved_at: now
      })
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{approve: approved}} -> {:ok, approved}
      {:error, :expense, reason, _} -> {:error, reason}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  def reject_expense(expense_id, rejector_id, _reason) do
    __MODULE__
    |> Repo.get(expense_id)
    |> change(%{status: "rejected", approved_by: rejector_id})
    |> Repo.update()
  end

  def top_spenders(tenant_id, limit \\ 10) do
    __MODULE__
    |> where([e], e.tenant_id == ^tenant_id and e.status == "approved")
    |> group_by([e], e.submitted_by)
    |> select([e], {e.submitted_by, sum(e.amount)})
    |> order_by([e], desc: sum(e.amount))
    |> limit(^limit)
    |> Repo.all()
  end

  def within_budget?(tenant_id, category, budget_limit) do
    total =
      __MODULE__
      |> where([e], e.tenant_id == ^tenant_id and e.category == ^category)
      |> select([e], sum(e.amount))
      |> Repo.one() || 0

    total <= budget_limit
  end
end

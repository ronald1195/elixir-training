defmodule Session12.ExpenseSchema do
  @moduledoc """
  Solution for Session 12: Expense GraphQL Schema
  """

  use Absinthe.Schema

  object :expense do
    field :id, non_null(:id)
    field :title, non_null(:string)
    field :amount, non_null(:integer)
    field :category, non_null(:string)
    field :status, non_null(:string)
    field :submitted_by, non_null(:string)
    field :created_at, :string
  end

  input_object :create_expense_input do
    field :title, non_null(:string)
    field :amount, non_null(:integer)
    field :category, non_null(:string)
    field :submitted_by, :string
  end

  query do
    field :expenses, list_of(:expense) do
      resolve &Session12.ExpenseResolver.list/3
    end

    field :expense, :expense do
      arg :id, non_null(:id)
      resolve &Session12.ExpenseResolver.get/3
    end

    field :expenses_by_category, list_of(:expense) do
      arg :category, non_null(:string)
      resolve &Session12.ExpenseResolver.list_by_category/3
    end
  end

  mutation do
    field :create_expense, :expense do
      arg :input, non_null(:create_expense_input)
      resolve &Session12.ExpenseResolver.create/3
    end

    field :approve_expense, :expense do
      arg :id, non_null(:id)
      resolve &Session12.ExpenseResolver.approve/3
    end

    field :reject_expense, :expense do
      arg :id, non_null(:id)
      arg :reason, non_null(:string)
      resolve &Session12.ExpenseResolver.reject/3
    end
  end
end

defmodule Session12.ExpenseResolver do
  @moduledoc """
  Solution: Expense resolvers
  """

  # Simulated data store
  @expenses %{
    "1" => %{id: "1", title: "Conference", amount: 50000, category: "travel", status: "pending", submitted_by: "user1"},
    "2" => %{id: "2", title: "Team Lunch", amount: 15000, category: "meals", status: "approved", submitted_by: "user2"}
  }

  def list(_parent, _args, _resolution) do
    {:ok, Map.values(@expenses)}
  end

  def get(_parent, %{id: id}, _resolution) do
    case Map.get(@expenses, id) do
      nil -> {:error, "Expense not found"}
      expense -> {:ok, expense}
    end
  end

  def list_by_category(_parent, %{category: category}, _resolution) do
    expenses = @expenses |> Map.values() |> Enum.filter(&(&1.category == category))
    {:ok, expenses}
  end

  def create(_parent, %{input: input}, _resolution) do
    expense = Map.merge(input, %{
      id: "#{System.unique_integer([:positive])}",
      status: "pending",
      submitted_by: input[:submitted_by] || "anonymous"
    })
    {:ok, expense}
  end

  def approve(_parent, %{id: id}, _resolution) do
    case Map.get(@expenses, id) do
      nil -> {:error, "Expense not found"}
      expense -> {:ok, %{expense | status: "approved"}}
    end
  end

  def reject(_parent, %{id: id, reason: _reason}, _resolution) do
    case Map.get(@expenses, id) do
      nil -> {:error, "Expense not found"}
      expense -> {:ok, %{expense | status: "rejected"}}
    end
  end
end

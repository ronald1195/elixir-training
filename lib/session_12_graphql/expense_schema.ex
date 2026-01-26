defmodule Session12.ExpenseSchema do
  @moduledoc """
  GraphQL schema for expense management using Absinthe.

  ## Your Task
  Study this schema and implement the resolvers in Session12.ExpenseResolver.
  The schema types are provided - you need to implement the resolver functions.
  """

  use Absinthe.Schema

  # Schema types are provided - implement resolvers below

  object :expense do
    field(:id, non_null(:id))
    field(:title, non_null(:string))
    field(:amount, non_null(:integer))
    field(:category, non_null(:string))
    field(:status, non_null(:string))
    field(:submitted_by, non_null(:string))
    field(:created_at, :string)
  end

  input_object :create_expense_input do
    field(:title, non_null(:string))
    field(:amount, non_null(:integer))
    field(:category, non_null(:string))
    field(:submitted_by, :string)
  end

  query do
    @desc "List all expenses"
    field :expenses, list_of(:expense) do
      resolve(&Session12.ExpenseResolver.list/3)
    end

    @desc "Get a single expense by ID"
    field :expense, :expense do
      arg(:id, non_null(:id))
      resolve(&Session12.ExpenseResolver.get/3)
    end

    @desc "List expenses by category"
    field :expenses_by_category, list_of(:expense) do
      arg(:category, non_null(:string))
      resolve(&Session12.ExpenseResolver.list_by_category/3)
    end
  end

  mutation do
    @desc "Create a new expense"
    field :create_expense, :expense do
      arg(:input, non_null(:create_expense_input))
      resolve(&Session12.ExpenseResolver.create/3)
    end

    @desc "Approve an expense"
    field :approve_expense, :expense do
      arg(:id, non_null(:id))
      resolve(&Session12.ExpenseResolver.approve/3)
    end

    @desc "Reject an expense"
    field :reject_expense, :expense do
      arg(:id, non_null(:id))
      arg(:reason, non_null(:string))
      resolve(&Session12.ExpenseResolver.reject/3)
    end
  end
end

defmodule Session12.ExpenseResolver do
  @moduledoc """
  Resolvers for expense GraphQL operations.

  ## Your Task
  Implement these resolver functions to make the GraphQL API work.
  """

  @doc """
  Lists all expenses.

  Should return {:ok, list_of_expenses} or {:error, reason}
  """
  def list(_parent, _args, _resolution) do
    # TODO: Fetch expenses from database/context
    # Hint: Return {:ok, [%{id: "1", title: "...", ...}, ...]}
    raise "TODO: Implement list/3"
  end

  @doc """
  Gets a single expense by ID.

  Should return {:ok, expense} or {:error, "Not found"}
  """
  def get(_parent, %{id: _id}, _resolution) do
    # TODO: Fetch expense by ID
    raise "TODO: Implement get/3"
  end

  @doc """
  Lists expenses by category.
  """
  def list_by_category(_parent, %{category: _category}, _resolution) do
    # TODO: Filter expenses by category
    raise "TODO: Implement list_by_category/3"
  end

  @doc """
  Creates a new expense.

  Should return {:ok, created_expense} or {:error, reason}
  """
  def create(_parent, %{input: _input}, _resolution) do
    # TODO: Create expense with input data
    raise "TODO: Implement create/3"
  end

  @doc """
  Approves an expense.

  Should return {:ok, updated_expense} or {:error, reason}
  """
  def approve(_parent, %{id: _id}, _resolution) do
    # TODO: Update expense status to approved
    raise "TODO: Implement approve/3"
  end

  @doc """
  Rejects an expense with a reason.

  Should return {:ok, updated_expense} or {:error, reason}
  """
  def reject(_parent, %{id: _id, reason: _reason}, _resolution) do
    # TODO: Update expense status to rejected
    raise "TODO: Implement reject/3"
  end
end

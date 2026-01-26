defmodule Session12.ExpenseSchemaTest do
  use ExUnit.Case, async: true
  @moduletag :pending

  alias Session12.{ExpenseSchema, ExpenseResolver}

  describe "ExpenseResolver.list/3" do
    test "returns list of expenses" do
      {:ok, expenses} = ExpenseResolver.list(nil, %{}, %{})
      assert is_list(expenses)
    end
  end

  describe "ExpenseResolver.get/3" do
    test "returns expense by id" do
      {:ok, expense} = ExpenseResolver.get(nil, %{id: "1"}, %{})
      assert expense.id == "1"
    end

    test "returns error for unknown id" do
      {:error, _} = ExpenseResolver.get(nil, %{id: "unknown"}, %{})
    end
  end

  describe "ExpenseResolver.create/3" do
    test "creates expense with valid input" do
      input = %{title: "Test", amount: 1000, category: "travel"}
      {:ok, expense} = ExpenseResolver.create(nil, %{input: input}, %{})
      assert expense.title == "Test"
    end
  end

  describe "ExpenseResolver.approve/3" do
    test "approves pending expense" do
      {:ok, expense} = ExpenseResolver.approve(nil, %{id: "1"}, %{})
      assert expense.status == "approved"
    end
  end

  describe "ExpenseResolver.reject/3" do
    test "rejects expense with reason" do
      {:ok, expense} = ExpenseResolver.reject(nil, %{id: "1", reason: "Over budget"}, %{})
      assert expense.status == "rejected"
    end
  end
end

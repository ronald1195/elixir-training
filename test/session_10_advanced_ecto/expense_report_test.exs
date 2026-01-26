defmodule Session10.ExpenseReportTest do
  use ExUnit.Case, async: true
  @moduletag :pending

  alias Session10.ExpenseReport

  describe "changeset/2" do
    test "valid changeset with all required fields" do
      attrs = %{
        tenant_id: "tenant-1",
        title: "Conference Travel",
        amount: 50000,
        category: "travel",
        submitted_by: "user-1"
      }

      changeset = ExpenseReport.changeset(%ExpenseReport{}, attrs)
      assert changeset.valid?
    end

    test "invalid changeset missing required fields" do
      changeset = ExpenseReport.changeset(%ExpenseReport{}, %{})
      refute changeset.valid?
    end

    test "validates category is in allowed list" do
      attrs = %{
        tenant_id: "tenant-1",
        title: "Test",
        amount: 100,
        category: "invalid_category",
        submitted_by: "user-1"
      }

      changeset = ExpenseReport.changeset(%ExpenseReport{}, attrs)
      refute changeset.valid?
    end

    test "validates amount is positive" do
      attrs = %{
        tenant_id: "tenant-1",
        title: "Test",
        amount: -100,
        category: "travel",
        submitted_by: "user-1"
      }

      changeset = ExpenseReport.changeset(%ExpenseReport{}, attrs)
      refute changeset.valid?
    end
  end

  describe "create_expense/2" do
    test "creates expense with tenant_id" do
      attrs = %{
        title: "Office Supplies",
        amount: 5000,
        category: "office_supplies",
        submitted_by: "user-1"
      }

      {:ok, expense} = ExpenseReport.create_expense("tenant-123", attrs)
      assert expense.tenant_id == "tenant-123"
    end
  end

  describe "list_expenses/1" do
    test "returns only expenses for specified tenant" do
      # Assuming expenses exist for multiple tenants
      expenses = ExpenseReport.list_expenses("tenant-1")
      assert Enum.all?(expenses, &(&1.tenant_id == "tenant-1"))
    end
  end

  describe "totals_by_category/1" do
    test "returns map of category totals" do
      totals = ExpenseReport.totals_by_category("tenant-1")
      assert is_map(totals)
    end
  end

  describe "approve_expense/2" do
    test "updates status and sets approval fields" do
      {:ok, approved} = ExpenseReport.approve_expense(1, "approver-1")
      assert approved.status == "approved"
      assert approved.approved_by == "approver-1"
      assert approved.approved_at != nil
    end
  end

  describe "top_spenders/2" do
    test "returns list of top spenders with totals" do
      spenders = ExpenseReport.top_spenders("tenant-1", 5)
      assert is_list(spenders)
    end
  end

  describe "within_budget?/3" do
    test "returns true when under budget" do
      # Assuming travel expenses total 5000 for tenant
      assert ExpenseReport.within_budget?("tenant-1", "travel", 10000)
    end

    test "returns false when over budget" do
      assert not ExpenseReport.within_budget?("tenant-1", "travel", 1000)
    end
  end
end

defmodule Session03Collections.TransactionBatchProcessorTest do
  use ExUnit.Case, async: true
  @moduletag :pending

  alias Session03Collections.TransactionBatchProcessor

  describe "filter_valid/1" do
    test "keeps only valid transactions" do
      transactions = [
        %{id: "txn_1", amount: 100, status: :approved},
        %{id: "txn_2", amount: -50, status: :approved},
        %{id: "txn_3", amount: 200, status: :pending},
        %{id: "txn_4", amount: nil, status: :approved},
        %{id: "txn_5", amount: 150, status: :approved}
      ]

      result = TransactionBatchProcessor.filter_valid(transactions)

      assert length(result) == 2
      assert Enum.all?(result, fn txn -> txn.amount > 0 and txn.status == :approved end)
    end

    test "returns empty list when all transactions are invalid" do
      transactions = [
        %{amount: -100, status: :approved},
        %{amount: 50, status: :declined}
      ]

      assert TransactionBatchProcessor.filter_valid(transactions) == []
    end

    test "handles empty list" do
      assert TransactionBatchProcessor.filter_valid([]) == []
    end
  end

  describe "calculate_total/1" do
    test "sums all transaction amounts" do
      transactions = [
        %{amount: 100.50},
        %{amount: 200.25},
        %{amount: 50.00}
      ]

      assert TransactionBatchProcessor.calculate_total(transactions) == 350.75
    end

    test "returns 0 for empty list" do
      assert TransactionBatchProcessor.calculate_total([]) == 0
    end

    test "handles single transaction" do
      assert TransactionBatchProcessor.calculate_total([%{amount: 123.45}]) == 123.45
    end
  end

  describe "group_by_account/1" do
    test "groups transactions by account ID" do
      transactions = [
        %{account_id: "acc_1", amount: 100},
        %{account_id: "acc_2", amount: 200},
        %{account_id: "acc_1", amount: 50},
        %{account_id: "acc_3", amount: 75}
      ]

      result = TransactionBatchProcessor.group_by_account(transactions)

      assert map_size(result) == 3
      assert length(result["acc_1"]) == 2
      assert length(result["acc_2"]) == 1
      assert length(result["acc_3"]) == 1
    end

    test "returns empty map for empty list" do
      assert TransactionBatchProcessor.group_by_account([]) == %{}
    end
  end

  describe "total_by_account/1" do
    test "calculates total spending per account" do
      transactions = [
        %{account_id: "acc_1", amount: 100},
        %{account_id: "acc_2", amount: 200},
        %{account_id: "acc_1", amount: 50},
        %{account_id: "acc_2", amount: 150}
      ]

      result = TransactionBatchProcessor.total_by_account(transactions)

      assert result["acc_1"] == 150
      assert result["acc_2"] == 350
    end

    test "returns empty map for empty list" do
      assert TransactionBatchProcessor.total_by_account([]) == %{}
    end
  end

  describe "highest_amount/1" do
    test "finds the maximum transaction amount" do
      transactions = [
        %{amount: 100},
        %{amount: 500},
        %{amount: 250}
      ]

      assert TransactionBatchProcessor.highest_amount(transactions) == 500
    end

    test "returns nil for empty list" do
      assert TransactionBatchProcessor.highest_amount([]) == nil
    end

    test "works with single transaction" do
      assert TransactionBatchProcessor.highest_amount([%{amount: 123}]) == 123
    end
  end

  describe "top_transactions/2" do
    test "returns top N transactions by amount" do
      transactions = [
        %{id: "txn_1", amount: 100},
        %{id: "txn_2", amount: 500},
        %{id: "txn_3", amount: 250},
        %{id: "txn_4", amount: 300}
      ]

      result = TransactionBatchProcessor.top_transactions(transactions, 2)

      assert length(result) == 2
      assert hd(result).amount == 500
      assert Enum.at(result, 1).amount == 300
    end

    test "returns all transactions if N is greater than list size" do
      transactions = [
        %{id: "txn_1", amount: 100},
        %{id: "txn_2", amount: 200}
      ]

      result = TransactionBatchProcessor.top_transactions(transactions, 5)

      assert length(result) == 2
    end

    test "returns empty list when given empty list" do
      assert TransactionBatchProcessor.top_transactions([], 5) == []
    end
  end

  describe "count_by_category/1" do
    test "counts transactions per category" do
      transactions = [
        %{category: "food"},
        %{category: "travel"},
        %{category: "food"},
        %{category: "office"},
        %{category: "food"}
      ]

      result = TransactionBatchProcessor.count_by_category(transactions)

      assert result["food"] == 3
      assert result["travel"] == 1
      assert result["office"] == 1
    end

    test "returns empty map for empty list" do
      assert TransactionBatchProcessor.count_by_category([]) == %{}
    end
  end

  describe "unique_merchants/1" do
    test "returns sorted list of unique merchants" do
      transactions = [
        %{merchant: "Coffee Shop"},
        %{merchant: "Gas Station"},
        %{merchant: "Coffee Shop"},
        %{merchant: "Restaurant"},
        %{merchant: "Gas Station"}
      ]

      result = TransactionBatchProcessor.unique_merchants(transactions)

      assert result == ["Coffee Shop", "Gas Station", "Restaurant"]
      assert length(result) == 3
    end

    test "returns empty list for empty input" do
      assert TransactionBatchProcessor.unique_merchants([]) == []
    end
  end

  describe "any_exceeds?/2" do
    test "returns true if any transaction exceeds limit" do
      transactions = [
        %{amount: 100},
        %{amount: 200}
      ]

      assert TransactionBatchProcessor.any_exceeds?(transactions, 150) == true
    end

    test "returns false if no transaction exceeds limit" do
      transactions = [
        %{amount: 100},
        %{amount: 200}
      ]

      assert TransactionBatchProcessor.any_exceeds?(transactions, 300) == false
    end

    test "returns false for empty list" do
      assert TransactionBatchProcessor.any_exceeds?([], 100) == false
    end
  end

  describe "all_below?/2" do
    test "returns true if all transactions are below limit" do
      transactions = [
        %{amount: 100},
        %{amount: 200}
      ]

      assert TransactionBatchProcessor.all_below?(transactions, 250) == true
    end

    test "returns false if any transaction meets or exceeds limit" do
      transactions = [
        %{amount: 100},
        %{amount: 200}
      ]

      assert TransactionBatchProcessor.all_below?(transactions, 200) == false
      assert TransactionBatchProcessor.all_below?(transactions, 150) == false
    end

    test "returns true for empty list" do
      assert TransactionBatchProcessor.all_below?([], 100) == true
    end
  end

  describe "daily_totals/1" do
    test "groups and sums transactions by date" do
      transactions = [
        %{amount: 100, timestamp: ~U[2024-01-15 10:30:00Z]},
        %{amount: 200, timestamp: ~U[2024-01-15 14:00:00Z]},
        %{amount: 150, timestamp: ~U[2024-01-16 09:00:00Z]},
        %{amount: 300, timestamp: ~U[2024-01-16 16:30:00Z]}
      ]

      result = TransactionBatchProcessor.daily_totals(transactions)

      assert result[~D[2024-01-15]] == 300
      assert result[~D[2024-01-16]] == 450
    end

    test "returns empty map for empty list" do
      assert TransactionBatchProcessor.daily_totals([]) == %{}
    end
  end

  describe "find_matching/2" do
    test "finds transactions matching all criteria" do
      transactions = [
        %{amount: 100, category: "food", status: :approved},
        %{amount: 500, category: "food", status: :approved},
        %{amount: 200, category: "travel", status: :approved},
        %{amount: 150, category: "food", status: :pending},
        %{amount: 250, category: "food", status: :approved}
      ]

      result =
        TransactionBatchProcessor.find_matching(transactions,
          min_amount: 100,
          max_amount: 300,
          allowed_categories: ["food", "office"]
        )

      assert length(result) == 2

      assert Enum.all?(result, fn txn ->
               txn.amount >= 100 and txn.amount <= 300 and
                 txn.category in ["food", "office"] and
                 txn.status == :approved
             end)
    end

    test "returns empty list when no transactions match" do
      transactions = [
        %{amount: 1000, category: "food", status: :approved}
      ]

      result =
        TransactionBatchProcessor.find_matching(transactions,
          min_amount: 100,
          max_amount: 500,
          allowed_categories: ["food"]
        )

      assert result == []
    end

    test "handles empty list" do
      result =
        TransactionBatchProcessor.find_matching([],
          min_amount: 100,
          max_amount: 500,
          allowed_categories: ["food"]
        )

      assert result == []
    end
  end
end

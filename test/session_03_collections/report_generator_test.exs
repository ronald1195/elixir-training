defmodule Session03Collections.ReportGeneratorTest do
  use ExUnit.Case, async: true
  @moduletag :pending
  alias Session03Collections.ReportGenerator

  describe "top_n_stream/2" do
    test "returns top N transactions using streams" do
      transactions = [
        %{id: "txn_1", amount: 100},
        %{id: "txn_2", amount: 500},
        %{id: "txn_3", amount: 250},
        %{id: "txn_4", amount: 300},
        %{id: "txn_5", amount: 150}
      ]

      result = ReportGenerator.top_n_stream(transactions, 3)

      assert length(result) == 3
      assert hd(result).amount == 500
      assert Enum.at(result, 1).amount == 300
      assert Enum.at(result, 2).amount == 250
    end

    test "handles requesting more items than available" do
      transactions = [
        %{id: "txn_1", amount: 100}
      ]

      result = ReportGenerator.top_n_stream(transactions, 5)

      assert length(result) == 1
    end
  end

  describe "process_large_dataset/3" do
    test "filters and limits large dataset efficiently" do
      # Simulating a large dataset
      large_dataset =
        Stream.map(1..1000, fn id ->
          %{
            id: "txn_#{id}",
            amount: id * 10,
            status: if(rem(id, 2) == 0, do: :approved, else: :declined)
          }
        end)

      result = ReportGenerator.process_large_dataset(large_dataset, 100, 5)

      assert length(result) == 5
      assert Enum.all?(result, fn txn ->
        txn.status == :approved and txn.amount > 100
      end)
    end

    test "works with minimum amount filter" do
      dataset =
        Stream.map(1..100, fn id ->
          %{id: "txn_#{id}", amount: id, status: :approved}
        end)

      result = ReportGenerator.process_large_dataset(dataset, 95, 3)

      assert length(result) == 3
      assert Enum.all?(result, fn txn -> txn.amount > 95 end)
    end
  end

  describe "category_statistics/1" do
    test "calculates statistics per category" do
      transactions = [
        %{category: "food", amount: 100},
        %{category: "food", amount: 200},
        %{category: "travel", amount: 500},
        %{category: "food", amount: 150}
      ]

      result = ReportGenerator.category_statistics(transactions)

      assert result["food"] == %{total: 450, count: 3, average: 150.0}
      assert result["travel"] == %{total: 500, count: 1, average: 500.0}
    end

    test "handles empty list" do
      assert ReportGenerator.category_statistics([]) == %{}
    end

    test "handles single category" do
      transactions = [
        %{category: "food", amount: 100},
        %{category: "food", amount: 200}
      ]

      result = ReportGenerator.category_statistics(transactions)

      assert result["food"] == %{total: 300, count: 2, average: 150.0}
    end
  end

  describe "detect_anomalies/2" do
    test "detects transactions significantly above average" do
      transactions = [
        %{id: "txn_1", amount: 100},
        %{id: "txn_2", amount: 120},
        %{id: "txn_3", amount: 90},
        %{id: "txn_4", amount: 1000},
        %{id: "txn_5", amount: 110}
      ]

      # Average is 284, threshold 3.0 means > 852
      result = ReportGenerator.detect_anomalies(transactions, 3.0)

      assert length(result) == 1
      assert hd(result).id == "txn_4"
      assert hd(result).amount == 1000
    end

    test "returns empty list when no anomalies" do
      transactions = [
        %{id: "txn_1", amount: 100},
        %{id: "txn_2", amount: 110},
        %{id: "txn_3", amount: 90}
      ]

      result = ReportGenerator.detect_anomalies(transactions, 5.0)

      assert result == []
    end

    test "handles empty list" do
      assert ReportGenerator.detect_anomalies([], 2.0) == []
    end
  end

  describe "summary_report/1" do
    test "generates comprehensive summary" do
      transactions = [
        %{amount: 100, category: "food", timestamp: ~U[2024-01-15 10:00:00Z]},
        %{amount: 200, category: "travel", timestamp: ~U[2024-01-16 10:00:00Z]},
        %{amount: 150, category: "food", timestamp: ~U[2024-01-17 10:00:00Z]}
      ]

      result = ReportGenerator.summary_report(transactions)

      assert result.total_transactions == 3
      assert result.total_amount == 450
      assert result.average_amount == 150.0
      assert Enum.sort(result.categories) == ["food", "travel"]
      assert result.date_range == {~D[2024-01-15], ~D[2024-01-17]}
    end

    test "handles single transaction" do
      transactions = [
        %{amount: 100, category: "food", timestamp: ~U[2024-01-15 10:00:00Z]}
      ]

      result = ReportGenerator.summary_report(transactions)

      assert result.total_transactions == 1
      assert result.total_amount == 100
      assert result.average_amount == 100.0
      assert result.categories == ["food"]
      assert result.date_range == {~D[2024-01-15], ~D[2024-01-15]}
    end
  end

  describe "batch_totals/2" do
    test "calculates totals for each batch" do
      transactions = [
        %{amount: 100},
        %{amount: 200},
        %{amount: 150},
        %{amount: 250},
        %{amount: 300}
      ]

      result = ReportGenerator.batch_totals(transactions, 2)

      assert result == [300, 400, 300]
    end

    test "handles uneven batches" do
      transactions = [
        %{amount: 100},
        %{amount: 200},
        %{amount: 150}
      ]

      result = ReportGenerator.batch_totals(transactions, 2)

      assert result == [300, 150]
    end

    test "handles batch size larger than list" do
      transactions = [
        %{amount: 100},
        %{amount: 200}
      ]

      result = ReportGenerator.batch_totals(transactions, 5)

      assert result == [300]
    end
  end

  describe "daily_spending_trend/1" do
    test "returns sorted daily totals" do
      transactions = [
        %{amount: 100, timestamp: ~U[2024-01-15 10:00:00Z]},
        %{amount: 200, timestamp: ~U[2024-01-15 14:00:00Z]},
        %{amount: 150, timestamp: ~U[2024-01-16 09:00:00Z]},
        %{amount: 300, timestamp: ~U[2024-01-17 11:00:00Z]}
      ]

      result = ReportGenerator.daily_spending_trend(transactions)

      assert result == [
               {~D[2024-01-15], 300},
               {~D[2024-01-16], 150},
               {~D[2024-01-17], 300}
             ]
    end

    test "handles empty list" do
      assert ReportGenerator.daily_spending_trend([]) == []
    end
  end

  describe "most_frequent_merchant/1" do
    test "finds merchant with most transactions" do
      transactions = [
        %{merchant: "Coffee Shop"},
        %{merchant: "Gas Station"},
        %{merchant: "Coffee Shop"},
        %{merchant: "Restaurant"},
        %{merchant: "Coffee Shop"}
      ]

      result = ReportGenerator.most_frequent_merchant(transactions)

      assert result == {"Coffee Shop", 3}
    end

    test "returns nil for empty list" do
      assert ReportGenerator.most_frequent_merchant([]) == nil
    end

    test "handles single merchant" do
      transactions = [%{merchant: "Coffee Shop"}]

      result = ReportGenerator.most_frequent_merchant(transactions)

      assert result == {"Coffee Shop", 1}
    end

    test "handles tie (returns one of them)" do
      transactions = [
        %{merchant: "Shop A"},
        %{merchant: "Shop B"},
        %{merchant: "Shop A"},
        %{merchant: "Shop B"}
      ]

      {merchant, count} = ReportGenerator.most_frequent_merchant(transactions)

      assert merchant in ["Shop A", "Shop B"]
      assert count == 2
    end
  end

  describe "rolling_average/2" do
    test "calculates rolling average for given window" do
      transactions = [
        %{amount: 100},
        %{amount: 200},
        %{amount: 300},
        %{amount: 400},
        %{amount: 500}
      ]

      result = ReportGenerator.rolling_average(transactions, 3)

      assert result == [200.0, 300.0, 400.0]
    end

    test "handles window size equal to list length" do
      transactions = [
        %{amount: 100},
        %{amount: 200},
        %{amount: 300}
      ]

      result = ReportGenerator.rolling_average(transactions, 3)

      assert result == [200.0]
    end

    test "handles window larger than list" do
      transactions = [
        %{amount: 100},
        %{amount: 200}
      ]

      result = ReportGenerator.rolling_average(transactions, 5)

      assert result == []
    end
  end
end

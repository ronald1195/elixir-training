defmodule Session02.PaymentProcessorTest do
  use ExUnit.Case, async: true

  alias Session02.PaymentProcessor

  describe "process/1" do
    test "processes credit transactions" do
      transaction = %{
        type: :credit,
        amount: 1000,
        account_id: "ACC-123",
        source: "wire_transfer"
      }

      assert PaymentProcessor.process(transaction) == {:ok, :credited, "ACC-123", 1000}
    end

    test "processes debit transactions" do
      transaction = %{
        type: :debit,
        amount: 500,
        account_id: "ACC-123",
        destination: "vendor_payment"
      }

      assert PaymentProcessor.process(transaction) == {:ok, :debited, "ACC-123", 500}
    end

    test "processes transfer transactions" do
      transaction = %{
        type: :transfer,
        amount: 250,
        from_account: "ACC-123",
        to_account: "ACC-456"
      }

      assert PaymentProcessor.process(transaction) ==
               {:ok, :transferred, "ACC-123", "ACC-456", 250}
    end

    test "processes refund transactions" do
      transaction = %{
        type: :refund,
        amount: 100,
        account_id: "ACC-123",
        original_transaction_id: "TXN-789"
      }

      assert PaymentProcessor.process(transaction) == {:ok, :refunded, "ACC-123", 100, "TXN-789"}
    end

    test "returns error for unknown transaction type" do
      transaction = %{type: :unknown, amount: 100}

      assert PaymentProcessor.process(transaction) == {:error, :invalid_transaction}
    end

    test "returns error for missing type" do
      transaction = %{amount: 100, account_id: "ACC-123"}

      assert PaymentProcessor.process(transaction) == {:error, :invalid_transaction}
    end
  end

  describe "validate/1" do
    test "validates a valid credit transaction" do
      transaction = %{type: :credit, amount: 100, account_id: "ACC-123"}

      assert PaymentProcessor.validate(transaction) == {:ok, transaction}
    end

    test "validates a valid debit transaction" do
      transaction = %{type: :debit, amount: 100, account_id: "ACC-123"}

      assert PaymentProcessor.validate(transaction) == {:ok, transaction}
    end

    test "validates a valid transfer transaction" do
      transaction = %{
        type: :transfer,
        amount: 100,
        from_account: "ACC-123",
        to_account: "ACC-456"
      }

      assert PaymentProcessor.validate(transaction) == {:ok, transaction}
    end

    test "rejects zero amount" do
      transaction = %{type: :credit, amount: 0, account_id: "ACC-123"}

      assert PaymentProcessor.validate(transaction) == {:error, :invalid_amount}
    end

    test "rejects negative amount" do
      transaction = %{type: :credit, amount: -50, account_id: "ACC-123"}

      assert PaymentProcessor.validate(transaction) == {:error, :invalid_amount}
    end

    test "rejects nil account_id for credit" do
      transaction = %{type: :credit, amount: 100, account_id: nil}

      assert PaymentProcessor.validate(transaction) == {:error, :missing_account}
    end

    test "rejects empty string account_id" do
      transaction = %{type: :credit, amount: 100, account_id: ""}

      assert PaymentProcessor.validate(transaction) == {:error, :missing_account}
    end

    test "rejects transfer to same account" do
      transaction = %{
        type: :transfer,
        amount: 100,
        from_account: "ACC-123",
        to_account: "ACC-123"
      }

      assert PaymentProcessor.validate(transaction) == {:error, :same_account_transfer}
    end

    test "rejects transfer with missing from_account" do
      transaction = %{type: :transfer, amount: 100, from_account: nil, to_account: "ACC-456"}

      assert PaymentProcessor.validate(transaction) == {:error, :missing_account}
    end
  end

  describe "balance_delta/2" do
    test "credit increases balance" do
      transaction = %{type: :credit, amount: 1000, account_id: "ACC-123"}

      assert PaymentProcessor.balance_delta("ACC-123", transaction) == 1000
    end

    test "debit decreases balance" do
      transaction = %{type: :debit, amount: 500, account_id: "ACC-123"}

      assert PaymentProcessor.balance_delta("ACC-123", transaction) == -500
    end

    test "refund increases balance" do
      transaction = %{
        type: :refund,
        amount: 100,
        account_id: "ACC-123",
        original_transaction_id: "TXN-1"
      }

      assert PaymentProcessor.balance_delta("ACC-123", transaction) == 100
    end

    test "transfer decreases sender balance" do
      transaction = %{
        type: :transfer,
        amount: 250,
        from_account: "ACC-123",
        to_account: "ACC-456"
      }

      assert PaymentProcessor.balance_delta("ACC-123", transaction) == -250
    end

    test "transfer increases receiver balance" do
      transaction = %{
        type: :transfer,
        amount: 250,
        from_account: "ACC-123",
        to_account: "ACC-456"
      }

      assert PaymentProcessor.balance_delta("ACC-456", transaction) == 250
    end

    test "returns 0 for unrelated account" do
      transaction = %{type: :credit, amount: 1000, account_id: "ACC-123"}

      assert PaymentProcessor.balance_delta("ACC-999", transaction) == 0
    end

    test "returns 0 for unrelated account in transfer" do
      transaction = %{
        type: :transfer,
        amount: 250,
        from_account: "ACC-123",
        to_account: "ACC-456"
      }

      assert PaymentProcessor.balance_delta("ACC-999", transaction) == 0
    end
  end

  describe "categorize/1" do
    test "categorizes credit as incoming" do
      assert PaymentProcessor.categorize(%{type: :credit}) == :incoming
    end

    test "categorizes refund as incoming" do
      assert PaymentProcessor.categorize(%{type: :refund}) == :incoming
    end

    test "categorizes debit as outgoing" do
      assert PaymentProcessor.categorize(%{type: :debit}) == :outgoing
    end

    test "categorizes transfer as internal" do
      assert PaymentProcessor.categorize(%{type: :transfer}) == :internal
    end

    test "categorizes unknown type as unknown" do
      assert PaymentProcessor.categorize(%{type: :something_else}) == :unknown
    end

    test "categorizes missing type as unknown" do
      assert PaymentProcessor.categorize(%{amount: 100}) == :unknown
    end
  end
end

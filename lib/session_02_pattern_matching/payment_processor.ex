defmodule Session02.PaymentProcessor do
  @moduledoc """
  A payment processor that routes different transaction types using pattern matching.

  ## Background

  In a financial system, you receive various transaction types:
  - Credits (money coming in)
  - Debits (money going out)
  - Transfers (money moving between accounts)
  - Refunds (reversing previous transactions)

  Each type requires different handling. Instead of using if/else chains,
  we'll use pattern matching to route transactions cleanly.

  ## Transaction Structure

  Transactions are maps with the following shapes:

  Credit:
      %{
        type: :credit,
        amount: 1000,          # in cents
        account_id: "ACC-123",
        source: "wire_transfer"
      }

  Debit:
      %{
        type: :debit,
        amount: 500,
        account_id: "ACC-123",
        destination: "vendor_payment"
      }

  Transfer:
      %{
        type: :transfer,
        amount: 250,
        from_account: "ACC-123",
        to_account: "ACC-456"
      }

  Refund:
      %{
        type: :refund,
        amount: 100,
        account_id: "ACC-123",
        original_transaction_id: "TXN-789"
      }

  ## Your Task

  Implement the functions using pattern matching in function heads.
  Each function should have multiple clauses - one for each case.
  """

  @doc """
  Process a transaction and return the result.

  Returns:
  - `{:ok, :credited, account_id, amount}` for credits
  - `{:ok, :debited, account_id, amount}` for debits
  - `{:ok, :transferred, from, to, amount}` for transfers
  - `{:ok, :refunded, account_id, amount, original_id}` for refunds
  - `{:error, :invalid_transaction}` for unknown transaction types

  ## Examples

      iex> Session02.PaymentProcessor.process(%{type: :credit, amount: 1000, account_id: "ACC-123", source: "wire"})
      {:ok, :credited, "ACC-123", 1000}

      iex> Session02.PaymentProcessor.process(%{type: :debit, amount: 500, account_id: "ACC-123", destination: "vendor"})
      {:ok, :debited, "ACC-123", 500}

      iex> Session02.PaymentProcessor.process(%{type: :unknown})
      {:error, :invalid_transaction}
  """
  def process(_transaction) do
    # TODO: Implement multiple function clauses using pattern matching
    # Hint: Create separate function heads for each transaction type
    # Example:
    #   def process(%{type: :credit, amount: amount, account_id: id}) do
    #     {:ok, :credited, id, amount}
    #   end
    raise "TODO: Implement process/1"
  end

  @doc """
  Validate a transaction before processing.

  Rules:
  - Amount must be positive (greater than 0)
  - Account IDs must be present (not nil or empty string)
  - For transfers, from_account and to_account must be different

  Returns:
  - `{:ok, transaction}` if valid
  - `{:error, reason}` if invalid

  Reasons:
  - `:invalid_amount` - amount is zero or negative
  - `:missing_account` - required account ID is missing
  - `:same_account_transfer` - transfer to same account

  ## Examples

      iex> Session02.PaymentProcessor.validate(%{type: :credit, amount: 100, account_id: "ACC-123"})
      {:ok, %{type: :credit, amount: 100, account_id: "ACC-123"}}

      iex> Session02.PaymentProcessor.validate(%{type: :credit, amount: -50, account_id: "ACC-123"})
      {:error, :invalid_amount}

      iex> Session02.PaymentProcessor.validate(%{type: :credit, amount: 100, account_id: nil})
      {:error, :missing_account}
  """
  def validate(_transaction) do
    # TODO: Implement validation using pattern matching and guards
    # Hint: Use guards like `when amount > 0`
    # Hint: Match on specific patterns for transfers vs other types
    raise "TODO: Implement validate/1"
  end

  @doc """
  Calculate the net effect on an account's balance.

  Given an account_id and a transaction, determine how the balance changes:
  - Credits increase the balance
  - Debits decrease the balance
  - Transfers: decrease if from_account matches, increase if to_account matches
  - Refunds increase the balance (money coming back)

  Returns the delta (positive for increase, negative for decrease).
  Returns 0 if the transaction doesn't affect the given account.

  ## Examples

      iex> Session02.PaymentProcessor.balance_delta("ACC-123", %{type: :credit, amount: 1000, account_id: "ACC-123"})
      1000

      iex> Session02.PaymentProcessor.balance_delta("ACC-123", %{type: :debit, amount: 500, account_id: "ACC-123"})
      -500

      iex> Session02.PaymentProcessor.balance_delta("ACC-123", %{type: :transfer, amount: 250, from_account: "ACC-123", to_account: "ACC-456"})
      -250

      iex> Session02.PaymentProcessor.balance_delta("ACC-456", %{type: :transfer, amount: 250, from_account: "ACC-123", to_account: "ACC-456"})
      250

      iex> Session02.PaymentProcessor.balance_delta("ACC-999", %{type: :credit, amount: 1000, account_id: "ACC-123"})
      0
  """
  def balance_delta(_account_id, _transaction) do
    # TODO: Implement using pattern matching
    # Hint: Use the pin operator ^ to match account_id in patterns
    # Example:
    #   def balance_delta(account_id, %{type: :credit, account_id: ^account_id, amount: amount}) do
    #     amount
    #   end
    raise "TODO: Implement balance_delta/2"
  end

  @doc """
  Categorize a transaction for reporting purposes.

  Categories:
  - `:incoming` - money coming into an account (credits, refunds)
  - `:outgoing` - money leaving an account (debits)
  - `:internal` - money moving within the system (transfers)
  - `:unknown` - unrecognized transaction type

  ## Examples

      iex> Session02.PaymentProcessor.categorize(%{type: :credit, amount: 100})
      :incoming

      iex> Session02.PaymentProcessor.categorize(%{type: :debit, amount: 100})
      :outgoing

      iex> Session02.PaymentProcessor.categorize(%{type: :transfer, amount: 100})
      :internal
  """
  def categorize(_transaction) do
    # TODO: Implement using pattern matching
    # This is a simple routing exercise - match on :type
    raise "TODO: Implement categorize/1"
  end
end

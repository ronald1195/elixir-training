defmodule Session03Collections.TransactionBatchProcessor do
  @moduledoc """
  SOLUTION FILE for Session 3: Collections & The Enum Module
  TransactionBatchProcessor - Processes batches of financial transactions
  """

  def filter_valid(transactions) do
    Enum.filter(transactions, fn txn ->
      not is_nil(txn.amount) and txn.amount > 0 and txn.status == :approved
    end)
  end

  def calculate_total(transactions) do
    Enum.reduce(transactions, 0, fn txn, acc -> acc + txn.amount end)
    # Alternative: Enum.sum_by(transactions, & &1.amount)
  end

  def group_by_account(transactions) do
    Enum.group_by(transactions, fn txn -> txn.account_id end)
  end

  def total_by_account(transactions) do
    transactions
    |> Enum.group_by(fn txn -> txn.account_id end)
    |> Enum.map(fn {account_id, txns} ->
      total = Enum.reduce(txns, 0, fn txn, acc -> acc + txn.amount end)
      {account_id, total}
    end)
    |> Enum.into(%{})
  end

  def highest_amount(transactions) do
    case transactions do
      [] -> nil
      _ -> Enum.max_by(transactions, fn txn -> txn.amount end).amount
    end
    # Alternative: Enum.map(transactions, & &1.amount) |> Enum.max(fn -> nil end)
  end

  def top_transactions(transactions, n) do
    transactions
    |> Enum.sort_by(fn txn -> txn.amount end, :desc)
    |> Enum.take(n)
  end

  def count_by_category(transactions) do
    Enum.frequencies_by(transactions, fn txn -> txn.category end)
    # Alternative using reduce:
    # Enum.reduce(transactions, %{}, fn txn, acc ->
    #   Map.update(acc, txn.category, 1, &(&1 + 1))
    # end)
  end

  def unique_merchants(transactions) do
    transactions
    |> Enum.map(fn txn -> txn.merchant end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  def any_exceeds?(transactions, limit) do
    Enum.any?(transactions, fn txn -> txn.amount > limit end)
  end

  def all_below?(transactions, limit) do
    Enum.all?(transactions, fn txn -> txn.amount < limit end)
  end

  def daily_totals(transactions) do
    transactions
    |> Enum.group_by(fn txn -> DateTime.to_date(txn.timestamp) end)
    |> Enum.map(fn {date, txns} ->
      total = Enum.reduce(txns, 0, fn txn, acc -> acc + txn.amount end)
      {date, total}
    end)
    |> Enum.into(%{})
  end

  def find_matching(transactions, opts) do
    min_amount = Keyword.fetch!(opts, :min_amount)
    max_amount = Keyword.fetch!(opts, :max_amount)
    allowed_categories = Keyword.fetch!(opts, :allowed_categories)

    Enum.filter(transactions, fn txn ->
      txn.amount >= min_amount and
        txn.amount <= max_amount and
        txn.category in allowed_categories and
        txn.status == :approved
    end)
  end
end

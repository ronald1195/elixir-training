defmodule Session03Collections.ReportGenerator do
  @moduledoc """
  SOLUTION FILE for Session 3: Collections & The Enum Module
  ReportGenerator - Generates reports using Streams for efficiency
  """

  def top_n_stream(transactions, n) do
    transactions
    |> Stream.map(& &1)  # Convert to stream if not already
    |> Enum.sort_by(fn txn -> txn.amount end, :desc)
    |> Enum.take(n)
  end

  def process_large_dataset(transaction_stream, minimum_amount, limit) do
    transaction_stream
    |> Stream.filter(fn txn -> txn.status == :approved end)
    |> Stream.filter(fn txn -> txn.amount > minimum_amount end)
    |> Enum.take(limit)
  end

  def category_statistics(transactions) do
    transactions
    |> Enum.group_by(fn txn -> txn.category end)
    |> Enum.map(fn {category, txns} ->
      total = Enum.reduce(txns, 0, fn txn, acc -> acc + txn.amount end)
      count = length(txns)
      average = total / count

      {category, %{total: total, count: count, average: average}}
    end)
    |> Enum.into(%{})
  end

  def detect_anomalies(transactions, threshold_multiplier) do
    case transactions do
      [] ->
        []

      _ ->
        total = Enum.reduce(transactions, 0, fn txn, acc -> acc + txn.amount end)
        average = total / length(transactions)
        threshold = average * threshold_multiplier

        Enum.filter(transactions, fn txn -> txn.amount > threshold end)
    end
  end

  def summary_report(transactions) do
    total_transactions = length(transactions)
    total_amount = Enum.reduce(transactions, 0, fn txn, acc -> acc + txn.amount end)
    average_amount = total_amount / total_transactions

    categories =
      transactions
      |> Enum.map(fn txn -> txn.category end)
      |> Enum.uniq()
      |> Enum.sort()

    dates =
      transactions
      |> Enum.map(fn txn -> DateTime.to_date(txn.timestamp) end)

    earliest = Enum.min(dates)
    latest = Enum.max(dates)

    %{
      total_transactions: total_transactions,
      total_amount: total_amount,
      average_amount: average_amount,
      categories: categories,
      date_range: {earliest, latest}
    }
  end

  def batch_totals(transactions, batch_size) do
    transactions
    |> Enum.chunk_every(batch_size)
    |> Enum.map(fn batch ->
      Enum.reduce(batch, 0, fn txn, acc -> acc + txn.amount end)
    end)
  end

  def daily_spending_trend(transactions) do
    transactions
    |> Enum.group_by(fn txn -> DateTime.to_date(txn.timestamp) end)
    |> Enum.map(fn {date, txns} ->
      total = Enum.reduce(txns, 0, fn txn, acc -> acc + txn.amount end)
      {date, total}
    end)
    |> Enum.sort_by(fn {date, _total} -> date end)
  end

  def most_frequent_merchant(transactions) do
    case transactions do
      [] ->
        nil

      _ ->
        transactions
        |> Enum.frequencies_by(fn txn -> txn.merchant end)
        |> Enum.max_by(fn {_merchant, count} -> count end)
    end
  end

  def rolling_average(transactions, window_size) do
    transactions
    |> Enum.chunk_every(window_size, 1, :discard)
    |> Enum.map(fn window ->
      total = Enum.reduce(window, 0, fn txn, acc -> acc + txn.amount end)
      total / window_size
    end)
  end
end

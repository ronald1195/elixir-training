defmodule Session01.TransactionParser do
  @moduledoc """
  A module for parsing raw transaction strings into structured data.

  ## Background for OOP developers

  In Java/C#, you might have a parser class with multiple methods that
  mutate an internal state object step by step.

  In Elixir, we use the pipe operator (|>) to transform data through
  a series of functions, each returning a new value.

  ## Your Task

  Implement the functions below to parse a transaction string like:
  "2024-01-15|DEPOSIT|USD|100.50|John Doe"

  Into a structured map like:
  %{
    date: "2024-01-15",
    type: :deposit,
    currency: :usd,
    amount: 10050,
    description: "John Doe"
  }

  Notice that the amount is converted from dollars to cents (100.50 -> 10050).
  """

  @doc """
  Parses a raw transaction string into a structured map.

  The input format is: "DATE|TYPE|CURRENCY|AMOUNT|DESCRIPTION"
  - DATE: ISO format (YYYY-MM-DD)
  - TYPE: DEPOSIT, WITHDRAWAL, TRANSFER
  - CURRENCY: USD, EUR, MXN, etc.
  - AMOUNT: Decimal amount (e.g., "100.50")
  - DESCRIPTION: Any text

  ## Examples

      iex> Session01.TransactionParser.parse("2024-01-15|DEPOSIT|USD|100.50|John Doe")
      %{
        date: "2024-01-15",
        type: :deposit,
        currency: :usd,
        amount: 10050,
        description: "John Doe"
      }

      iex> Session01.TransactionParser.parse("2024-02-20|WITHDRAWAL|EUR|50.25|ATM Withdrawal")
      %{
        date: "2024-02-20",
        type: :withdrawal,
        currency: :eur,
        amount: 5025,
        description: "ATM Withdrawal"
      }
  """
  def parse(raw_string) do
    # TODO: Implement the pipeline
    # Hint: Use String.split/2, then pipe through helper functions below
    # Example pipeline:
    # raw_string
    # |> String.split("|")
    # |> parse_parts()
    raise "TODO: Implement parse/1"
  end

  @doc """
  Converts a list of string parts into a structured map.

  ## Examples

      iex> Session01.TransactionParser.parse_parts(["2024-01-15", "DEPOSIT", "USD", "100.50", "John Doe"])
      %{
        date: "2024-01-15",
        type: :deposit,
        currency: :usd,
        amount: 10050,
        description: "John Doe"
      }
  """
  def parse_parts([date, type, currency, amount, description]) do
    # TODO: Create a map with the parsed values
    # Hint: Use normalize_type/1, normalize_currency/1, and parse_amount/1
    raise "TODO: Implement parse_parts/1"
  end

  @doc """
  Normalizes a transaction type from uppercase string to lowercase atom.

  ## Examples

      iex> Session01.TransactionParser.normalize_type("DEPOSIT")
      :deposit

      iex> Session01.TransactionParser.normalize_type("WITHDRAWAL")
      :withdrawal

      iex> Session01.TransactionParser.normalize_type("TRANSFER")
      :transfer
  """
  def normalize_type(type_string) do
    # TODO: Convert uppercase string to lowercase atom
    # Hint: type_string |> String.downcase() |> String.to_atom()
    raise "TODO: Implement normalize_type/1"
  end

  @doc """
  Normalizes a currency code from uppercase string to lowercase atom.

  ## Examples

      iex> Session01.TransactionParser.normalize_currency("USD")
      :usd

      iex> Session01.TransactionParser.normalize_currency("EUR")
      :eur
  """
  def normalize_currency(currency_string) do
    # TODO: Convert uppercase string to lowercase atom
    raise "TODO: Implement normalize_currency/1"
  end

  @doc """
  Parses an amount string and converts dollars to cents.

  ## Examples

      iex> Session01.TransactionParser.parse_amount("100.50")
      10050

      iex> Session01.TransactionParser.parse_amount("50.00")
      5000

      iex> Session01.TransactionParser.parse_amount("0.99")
      99
  """
  def parse_amount(amount_string) do
    # TODO: Convert string to float, multiply by 100, round to integer
    # Hint: amount_string |> String.to_float() |> Kernel.*(100) |> round()
    raise "TODO: Implement parse_amount/1"
  end

  @doc """
  Parses multiple transaction lines.

  ## Examples

      iex> lines = \"\"\"
      ...> 2024-01-15|DEPOSIT|USD|100.50|John Doe
      ...> 2024-01-16|WITHDRAWAL|USD|20.00|ATM
      ...> \"\"\"
      iex> Session01.TransactionParser.parse_batch(lines)
      [
        %{date: "2024-01-15", type: :deposit, currency: :usd, amount: 10050, description: "John Doe"},
        %{date: "2024-01-16", type: :withdrawal, currency: :usd, amount: 2000, description: "ATM"}
      ]
  """
  def parse_batch(multi_line_string) do
    # TODO: Split by newlines, filter empty lines, parse each line
    # Hint: Use String.split/2, Enum.reject/2, and Enum.map/2
    # Example pipeline:
    # multi_line_string
    # |> String.split("\n")
    # |> Enum.reject(fn line -> line == "" end)
    # |> Enum.map(&parse/1)
    raise "TODO: Implement parse_batch/1"
  end
end

defmodule Session01.TransactionParserTest do
  use ExUnit.Case, async: true
  doctest Session01.TransactionParser

  alias Session01.TransactionParser

  describe "normalize_type/1" do
    test "converts DEPOSIT to atom" do
      assert TransactionParser.normalize_type("DEPOSIT") == :deposit
    end

    test "converts WITHDRAWAL to atom" do
      assert TransactionParser.normalize_type("WITHDRAWAL") == :withdrawal
    end

    test "converts TRANSFER to atom" do
      assert TransactionParser.normalize_type("TRANSFER") == :transfer
    end
  end

  describe "normalize_currency/1" do
    test "converts USD to atom" do
      assert TransactionParser.normalize_currency("USD") == :usd
    end

    test "converts EUR to atom" do
      assert TransactionParser.normalize_currency("EUR") == :eur
    end

    test "converts MXN to atom" do
      assert TransactionParser.normalize_currency("MXN") == :mxn
    end
  end

  describe "parse_amount/1" do
    test "parses whole dollars" do
      assert TransactionParser.parse_amount("100.00") == 10000
    end

    test "parses dollars with cents" do
      assert TransactionParser.parse_amount("100.50") == 10050
    end

    test "parses amounts less than a dollar" do
      assert TransactionParser.parse_amount("0.99") == 99
    end

    test "parses decimal amounts correctly" do
      assert TransactionParser.parse_amount("50.25") == 5025
    end
  end

  describe "parse_parts/1" do
    test "converts list of parts into structured map" do
      parts = ["2024-01-15", "DEPOSIT", "USD", "100.50", "John Doe"]

      expected = %{
        date: "2024-01-15",
        type: :deposit,
        currency: :usd,
        amount: 10050,
        description: "John Doe"
      }

      assert TransactionParser.parse_parts(parts) == expected
    end

    test "handles different transaction types" do
      parts = ["2024-02-20", "WITHDRAWAL", "EUR", "50.00", "ATM"]

      expected = %{
        date: "2024-02-20",
        type: :withdrawal,
        currency: :eur,
        amount: 5000,
        description: "ATM"
      }

      assert TransactionParser.parse_parts(parts) == expected
    end
  end

  describe "parse/1" do
    test "parses a deposit transaction" do
      raw = "2024-01-15|DEPOSIT|USD|100.50|John Doe"

      expected = %{
        date: "2024-01-15",
        type: :deposit,
        currency: :usd,
        amount: 10050,
        description: "John Doe"
      }

      assert TransactionParser.parse(raw) == expected
    end

    test "parses a withdrawal transaction" do
      raw = "2024-02-20|WITHDRAWAL|EUR|50.25|ATM Withdrawal"

      expected = %{
        date: "2024-02-20",
        type: :withdrawal,
        currency: :eur,
        amount: 5025,
        description: "ATM Withdrawal"
      }

      assert TransactionParser.parse(raw) == expected
    end

    test "parses a transfer transaction" do
      raw = "2024-03-10|TRANSFER|MXN|1000.00|Rent Payment"

      expected = %{
        date: "2024-03-10",
        type: :transfer,
        currency: :mxn,
        amount: 100000,
        description: "Rent Payment"
      }

      assert TransactionParser.parse(raw) == expected
    end
  end

  describe "parse_batch/1" do
    test "parses multiple transactions" do
      batch = """
      2024-01-15|DEPOSIT|USD|100.50|John Doe
      2024-01-16|WITHDRAWAL|USD|20.00|ATM
      """

      expected = [
        %{
          date: "2024-01-15",
          type: :deposit,
          currency: :usd,
          amount: 10050,
          description: "John Doe"
        },
        %{
          date: "2024-01-16",
          type: :withdrawal,
          currency: :usd,
          amount: 2000,
          description: "ATM"
        }
      ]

      assert TransactionParser.parse_batch(batch) == expected
    end

    test "handles empty lines" do
      batch = """
      2024-01-15|DEPOSIT|USD|100.00|Salary

      2024-01-16|WITHDRAWAL|USD|20.00|Coffee
      """

      result = TransactionParser.parse_batch(batch)

      assert length(result) == 2
      assert Enum.at(result, 0).description == "Salary"
      assert Enum.at(result, 1).description == "Coffee"
    end

    test "parses mixed currency transactions" do
      batch = """
      2024-01-15|DEPOSIT|USD|100.00|USD Deposit
      2024-01-16|DEPOSIT|EUR|50.00|EUR Deposit
      2024-01-17|DEPOSIT|MXN|1000.00|MXN Deposit
      """

      result = TransactionParser.parse_batch(batch)

      assert length(result) == 3
      assert Enum.at(result, 0).currency == :usd
      assert Enum.at(result, 1).currency == :eur
      assert Enum.at(result, 2).currency == :mxn
    end
  end
end

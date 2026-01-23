defmodule Session01.MoneyTest do
  use ExUnit.Case, async: true
  @moduletag :pending

  alias Session01.Money

  describe "new/2" do
    test "creates a money map with amount and currency" do
      assert Money.new(100, :usd) == %{amount: 100, currency: :usd}
    end

    test "works with different currencies" do
      assert Money.new(500, :eur) == %{amount: 500, currency: :eur}
      assert Money.new(1000, :mxn) == %{amount: 1000, currency: :mxn}
    end
  end

  describe "add/2" do
    test "adds two money values of the same currency" do
      m1 = Money.new(100, :usd)
      m2 = Money.new(50, :usd)

      assert Money.add(m1, m2) == {:ok, %{amount: 150, currency: :usd}}
    end

    test "returns error when currencies don't match" do
      m1 = Money.new(100, :usd)
      m2 = Money.new(50, :eur)

      assert Money.add(m1, m2) == {:error, :currency_mismatch}
    end

    test "adding zero works" do
      m1 = Money.new(100, :usd)
      m2 = Money.new(0, :usd)

      assert Money.add(m1, m2) == {:ok, %{amount: 100, currency: :usd}}
    end
  end

  describe "subtract/2" do
    test "subtracts money values of the same currency" do
      m1 = Money.new(100, :usd)
      m2 = Money.new(30, :usd)

      assert Money.subtract(m1, m2) == {:ok, %{amount: 70, currency: :usd}}
    end

    test "returns error for currency mismatch" do
      m1 = Money.new(100, :usd)
      m2 = Money.new(30, :eur)

      assert Money.subtract(m1, m2) == {:error, :currency_mismatch}
    end

    test "returns error for insufficient funds" do
      m1 = Money.new(30, :usd)
      m2 = Money.new(100, :usd)

      assert Money.subtract(m1, m2) == {:error, :insufficient_funds}
    end

    test "subtracting to exactly zero works" do
      m1 = Money.new(100, :usd)
      m2 = Money.new(100, :usd)

      assert Money.subtract(m1, m2) == {:ok, %{amount: 0, currency: :usd}}
    end
  end

  describe "multiply/2" do
    test "multiplies amount by factor" do
      m = Money.new(100, :usd)

      assert Money.multiply(m, 3) == %{amount: 300, currency: :usd}
    end

    test "multiplying by 1 returns same amount" do
      m = Money.new(100, :usd)

      assert Money.multiply(m, 1) == %{amount: 100, currency: :usd}
    end

    test "multiplying by 0 returns zero" do
      m = Money.new(100, :usd)

      assert Money.multiply(m, 0) == %{amount: 0, currency: :usd}
    end
  end

  describe "format/1" do
    test "formats USD with dollar sign" do
      m = Money.new(1234, :usd)

      assert Money.format(m) == "$12.34"
    end

    test "formats EUR with euro sign" do
      m = Money.new(1234, :eur)

      assert Money.format(m) == "€12.34"
    end

    test "formats other currencies with code" do
      m = Money.new(1234, :mxn)

      assert Money.format(m) == "MXN 12.34"
    end

    test "formats whole dollars correctly" do
      m = Money.new(500, :usd)

      assert Money.format(m) == "$5.00"
    end

    test "formats cents correctly" do
      m = Money.new(5, :usd)

      assert Money.format(m) == "$0.05"
    end
  end
end

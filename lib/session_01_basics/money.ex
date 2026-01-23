defmodule Session01.Money do
  @moduledoc """
  A module for handling monetary values with currency awareness.

  ## Background for OOP developers

  In Java/C#, you might have:

      class Money {
          private int amount;
          private String currency;

          public Money add(Money other) {
              this.amount += other.amount;  // Mutation!
              return this;
          }
      }

  In Elixir, we represent Money as a simple map and use functions
  that return NEW values instead of mutating:

      %{amount: 100, currency: :usd}

  ## Your Task

  Implement the functions below. Each one should return a new value,
  never modify the input.
  """

  @doc """
  Creates a new money struct.

  ## Examples

      iex> Session01.Money.new(100, :usd)
      %{amount: 100, currency: :usd}

      iex> Session01.Money.new(50, :eur)
      %{amount: 50, currency: :eur}
  """
  def new(_amount, _currency) do
    # TODO: Return a map with :amount and :currency keys
    # Hint: Remove the underscores from the parameters when implementing
    raise "TODO: Implement new/2"
  end

  @doc """
  Adds two money values of the same currency.
  Returns {:ok, result} or {:error, reason}.

  ## Examples

      iex> m1 = %{amount: 100, currency: :usd}
      iex> m2 = %{amount: 50, currency: :usd}
      iex> Session01.Money.add(m1, m2)
      {:ok, %{amount: 150, currency: :usd}}

      iex> m1 = %{amount: 100, currency: :usd}
      iex> m2 = %{amount: 50, currency: :eur}
      iex> Session01.Money.add(m1, m2)
      {:error, :currency_mismatch}
  """
  def add(_money1, _money2) do
    # TODO: Add two money values if currencies match
    # Return {:ok, new_money} or {:error, :currency_mismatch}
    # Hint: Use pattern matching to check if currencies are the same
    raise "TODO: Implement add/2"
  end

  @doc """
  Subtracts money2 from money1.
  Returns {:ok, result} or {:error, reason}.

  ## Examples

      iex> m1 = %{amount: 100, currency: :usd}
      iex> m2 = %{amount: 30, currency: :usd}
      iex> Session01.Money.subtract(m1, m2)
      {:ok, %{amount: 70, currency: :usd}}

  Should return {:error, :insufficient_funds} if result would be negative.
  Should return {:error, :currency_mismatch} if currencies differ.
  """
  def subtract(_money1, _money2) do
    # TODO: Subtract money2 from money1
    # Handle currency mismatch and insufficient funds
    raise "TODO: Implement subtract/2"
  end

  @doc """
  Multiplies a money value by a factor.

  ## Examples

      iex> m = %{amount: 100, currency: :usd}
      iex> Session01.Money.multiply(m, 3)
      %{amount: 300, currency: :usd}
  """
  def multiply(_money, _factor) do
    # TODO: Multiply the amount by the factor
    # Remember: return a NEW map, don't try to modify the input
    raise "TODO: Implement multiply/2"
  end

  @doc """
  Formats money for display.

  ## Examples

      iex> Session01.Money.format(%{amount: 1234, currency: :usd})
      "$12.34"

      iex> Session01.Money.format(%{amount: 1234, currency: :eur})
      "€12.34"

      iex> Session01.Money.format(%{amount: 1234, currency: :mxn})
      "MXN 12.34"
  """
  def format(_money) do
    # TODO: Format the money value as a string
    # Amounts are in cents, so divide by 100 for display
    # Use "$" for :usd, "€" for :eur, currency code + space for others
    raise "TODO: Implement format/1"
  end
end

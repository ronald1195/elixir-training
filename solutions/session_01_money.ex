# SOLUTION FILE - Do not distribute to participants

defmodule Session01.Money.Solution do
  @moduledoc """
  Reference implementation for the Money module.
  """

  def new(amount, currency) do
    %{amount: amount, currency: currency}
  end

  def add(%{currency: currency} = m1, %{currency: currency} = m2) do
    {:ok, %{amount: m1.amount + m2.amount, currency: currency}}
  end

  def add(_m1, _m2) do
    {:error, :currency_mismatch}
  end

  def subtract(%{currency: currency} = m1, %{currency: currency} = m2) do
    case m1.amount - m2.amount do
      result when result >= 0 ->
        {:ok, %{amount: result, currency: currency}}

      _ ->
        {:error, :insufficient_funds}
    end
  end

  def subtract(_m1, _m2) do
    {:error, :currency_mismatch}
  end

  def multiply(%{amount: amount, currency: currency}, factor) do
    %{amount: amount * factor, currency: currency}
  end

  def format(%{amount: amount, currency: :usd}) do
    format_amount("$", amount)
  end

  def format(%{amount: amount, currency: :eur}) do
    format_amount("€", amount)
  end

  def format(%{amount: amount, currency: currency}) do
    code = currency |> Atom.to_string() |> String.upcase()
    format_amount("#{code} ", amount)
  end

  defp format_amount(prefix, amount) do
    dollars = div(amount, 100)
    cents = rem(amount, 100)
    "#{prefix}#{dollars}.#{String.pad_leading(Integer.to_string(cents), 2, "0")}"
  end
end

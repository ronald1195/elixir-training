defmodule Session16.PaymentService do
  @moduledoc """
  A payment service module for testing exercises.

  ## Your Task
  This module is the subject of testing exercises.
  Study the implementation, then write tests that cover:
  1. Happy path scenarios
  2. Error cases
  3. Edge cases
  4. Async behavior
  """

  @gateway_module Application.compile_env(
                    :elixir_training,
                    :payment_gateway,
                    Session16.MockGateway
                  )

  defmodule Payment do
    defstruct [:id, :amount, :currency, :status, :error_reason]
  end

  @doc """
  Creates a new payment.

  Validates input and returns a Payment struct.
  """
  def create_payment(attrs) do
    with :ok <- validate_amount(attrs[:amount]),
         :ok <- validate_currency(attrs[:currency]) do
      {:ok,
       %Payment{
         id: generate_id(),
         amount: attrs[:amount],
         currency: attrs[:currency],
         status: "pending"
       }}
    end
  end

  @doc """
  Processes a payment through the gateway.

  Uses the configured gateway module (supports dependency injection for testing).
  """
  def process_payment(payment, gateway \\ @gateway_module) do
    case gateway.charge(payment.amount, payment.currency) do
      {:ok, transaction_id} ->
        {:ok, %{payment | status: "completed", id: transaction_id}}

      {:error, :declined} ->
        {:error, %{payment | status: "declined", error_reason: "Card declined"}}

      {:error, :insufficient_funds} ->
        {:error, %{payment | status: "failed", error_reason: "Insufficient funds"}}

      {:error, reason} ->
        {:error, %{payment | status: "failed", error_reason: inspect(reason)}}
    end
  end

  @doc """
  Refunds a payment.
  """
  def refund_payment(payment, amount, gateway \\ @gateway_module) do
    cond do
      payment.status != "completed" ->
        {:error, :invalid_status}

      amount > payment.amount ->
        {:error, :invalid_amount}

      true ->
        case gateway.refund(payment.id, amount) do
          {:ok, refund_id} -> {:ok, %{refund_id: refund_id, amount: amount}}
          {:error, reason} -> {:error, reason}
        end
    end
  end

  # Private functions

  defp validate_amount(nil), do: {:error, :missing_amount}
  defp validate_amount(amount) when amount <= 0, do: {:error, :invalid_amount}
  defp validate_amount(_amount), do: :ok

  defp validate_currency(nil), do: {:error, :missing_currency}
  defp validate_currency(currency) when currency in ~w(USD EUR GBP), do: :ok
  defp validate_currency(_), do: {:error, :unsupported_currency}

  defp generate_id, do: "pay_#{System.unique_integer([:positive])}"
end

defmodule Session16.MockGateway do
  @moduledoc """
  Mock gateway for testing.
  """

  def charge(_amount, _currency) do
    {:ok, "txn_#{System.unique_integer([:positive])}"}
  end

  def refund(_payment_id, _amount) do
    {:ok, "ref_#{System.unique_integer([:positive])}"}
  end
end

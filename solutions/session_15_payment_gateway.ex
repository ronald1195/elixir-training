defmodule Session15.PaymentGateway do
  @moduledoc """
  Solution for Session 15: Payment Gateway Behaviour
  """

  @callback process_payment(params :: map()) :: {:ok, map()} | {:error, term()}
  @callback refund_payment(payment_id :: String.t(), amount :: integer()) ::
              {:ok, map()} | {:error, term()}
  @callback get_payment(payment_id :: String.t()) :: {:ok, map()} | {:error, term()}
  @callback verify_webhook(payload :: binary(), signature :: String.t()) ::
              {:ok, map()} | {:error, term()}
end

defmodule Session15.StripeGateway do
  @behaviour Session15.PaymentGateway

  @impl true
  def process_payment(params) do
    {:ok,
     %{
       id: "pi_#{System.unique_integer([:positive])}",
       status: "succeeded",
       amount: params.amount,
       currency: params.currency
     }}
  end

  @impl true
  def refund_payment(payment_id, amount) do
    {:ok,
     %{
       id: "re_#{System.unique_integer([:positive])}",
       payment_id: payment_id,
       amount: amount,
       status: "succeeded"
     }}
  end

  @impl true
  def get_payment(payment_id) do
    {:ok, %{id: payment_id, status: "succeeded", amount: 5000}}
  end

  @impl true
  def verify_webhook(_payload, _signature) do
    {:ok, %{type: "payment_intent.succeeded"}}
  end
end

defmodule Session15.PayPalGateway do
  @behaviour Session15.PaymentGateway

  @impl true
  def process_payment(params) do
    {:ok,
     %{
       id: "PAYPAL-#{System.unique_integer([:positive])}",
       status: "COMPLETED",
       amount: params.amount,
       currency: params.currency
     }}
  end

  @impl true
  def refund_payment(payment_id, amount) do
    {:ok, %{id: "REFUND-#{System.unique_integer([:positive])}", payment_id: payment_id, amount: amount}}
  end

  @impl true
  def get_payment(payment_id) do
    {:ok, %{id: payment_id, status: "COMPLETED"}}
  end

  @impl true
  def verify_webhook(_payload, _signature) do
    {:ok, %{event_type: "PAYMENT.CAPTURE.COMPLETED"}}
  end
end

defprotocol Session15.PaymentFormatter do
  @doc "Formats payment data for display"
  def format(payment)
end

defimpl Session15.PaymentFormatter, for: Session15.CreditCardPayment do
  def format(payment) do
    amount = :erlang.float_to_binary(payment.amount / 100, decimals: 2)
    "#{payment.brand} ****#{payment.last_four}: #{payment.currency} #{amount}"
  end
end

defimpl Session15.PaymentFormatter, for: Session15.BankTransfer do
  def format(payment) do
    amount = :erlang.float_to_binary(payment.amount / 100, decimals: 2)
    "#{payment.bank_name} ****#{payment.account_last_four}: #{payment.currency} #{amount}"
  end
end

defimpl Session15.PaymentFormatter, for: Session15.CryptoPayment do
  def format(payment) do
    short_addr = String.slice(payment.wallet_address, 0..7)
    "#{payment.network}: #{payment.amount} #{payment.currency} to #{short_addr}..."
  end
end

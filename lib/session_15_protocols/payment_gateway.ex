defmodule Session15.PaymentGateway do
  @moduledoc """
  Behaviour definition for payment gateway implementations.

  ## Background for OOP Developers

  In Java, you'd use an interface:

      public interface PaymentGateway {
          PaymentResult processPayment(PaymentRequest request);
          RefundResult refundPayment(String paymentId, BigDecimal amount);
      }

  In Elixir, behaviours define the contract:

      @callback process_payment(map()) :: {:ok, map()} | {:error, term()}

  ## Your Task
  1. Define the PaymentGateway behaviour with callbacks
  2. Implement StripeGateway
  3. Implement PayPalGateway
  """

  @doc """
  Callback for processing a payment.

  Params should include:
  - amount: integer (in cents)
  - currency: string
  - source: string (card token, etc.)
  - metadata: map (optional)

  Returns:
  - {:ok, %{id: string, status: string, ...}}
  - {:error, reason}
  """
  @callback process_payment(params :: map()) :: {:ok, map()} | {:error, term()}

  @doc """
  Callback for refunding a payment.
  """
  @callback refund_payment(payment_id :: String.t(), amount :: integer()) ::
              {:ok, map()} | {:error, term()}

  @doc """
  Callback for checking payment status.
  """
  @callback get_payment(payment_id :: String.t()) :: {:ok, map()} | {:error, term()}

  @doc """
  Callback for verifying webhook signatures.
  """
  @callback verify_webhook(payload :: binary(), signature :: String.t()) ::
              {:ok, map()} | {:error, term()}
end

defmodule Session15.StripeGateway do
  @moduledoc """
  Stripe payment gateway implementation.
  """

  # TODO: Add @behaviour Session15.PaymentGateway

  @doc """
  Processes a payment through Stripe.
  """
  def process_payment(_params) do
    # TODO: Implement Stripe payment processing
    raise "TODO: Implement process_payment/1"
  end

  @doc """
  Refunds a Stripe payment.
  """
  def refund_payment(_payment_id, _amount) do
    # TODO: Implement Stripe refund
    raise "TODO: Implement refund_payment/2"
  end

  @doc """
  Gets a Stripe payment by ID.
  """
  def get_payment(_payment_id) do
    # TODO: Implement get payment
    raise "TODO: Implement get_payment/1"
  end

  @doc """
  Verifies Stripe webhook signature.
  """
  def verify_webhook(_payload, _signature) do
    # TODO: Implement webhook verification
    raise "TODO: Implement verify_webhook/2"
  end
end

defmodule Session15.PayPalGateway do
  @moduledoc """
  PayPal payment gateway implementation.
  """

  # TODO: Add @behaviour Session15.PaymentGateway

  def process_payment(_params) do
    raise "TODO: Implement process_payment/1"
  end

  def refund_payment(_payment_id, _amount) do
    raise "TODO: Implement refund_payment/2"
  end

  def get_payment(_payment_id) do
    raise "TODO: Implement get_payment/1"
  end

  def verify_webhook(_payload, _signature) do
    raise "TODO: Implement verify_webhook/2"
  end
end

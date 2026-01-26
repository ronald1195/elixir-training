defmodule Session15.PaymentGatewayTest do
  use ExUnit.Case, async: true
  @moduletag :pending

  alias Session15.{StripeGateway, PayPalGateway}

  describe "StripeGateway" do
    test "process_payment returns ok tuple on success" do
      params = %{amount: 5000, currency: "usd", source: "tok_visa"}
      {:ok, result} = StripeGateway.process_payment(params)

      assert result.id
      assert result.status == "succeeded"
    end

    test "refund_payment returns ok tuple" do
      {:ok, result} = StripeGateway.refund_payment("pi_123", 2500)

      assert result.id
      assert result.amount == 2500
    end

    test "get_payment returns payment details" do
      {:ok, payment} = StripeGateway.get_payment("pi_123")

      assert payment.id == "pi_123"
    end
  end

  describe "PayPalGateway" do
    test "process_payment returns ok tuple on success" do
      params = %{amount: 5000, currency: "usd"}
      {:ok, result} = PayPalGateway.process_payment(params)

      assert result.id
    end
  end

  describe "PaymentFormatter protocol" do
    alias Session15.{CreditCardPayment, BankTransfer}

    test "formats credit card payment" do
      payment = %CreditCardPayment{
        amount: 5000,
        currency: "USD",
        last_four: "1234",
        brand: "VISA"
      }

      formatted = Session15.PaymentFormatter.format(payment)
      assert formatted =~ "VISA"
      assert formatted =~ "1234"
      assert formatted =~ "50.00"
    end

    test "formats bank transfer" do
      payment = %BankTransfer{
        amount: 10000,
        currency: "USD",
        bank_name: "Chase",
        account_last_four: "5678"
      }

      formatted = Session15.PaymentFormatter.format(payment)
      assert formatted =~ "Chase"
      assert formatted =~ "5678"
    end
  end
end

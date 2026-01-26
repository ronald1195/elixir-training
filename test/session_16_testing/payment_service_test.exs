defmodule Session16.PaymentServiceTest do
  use ExUnit.Case, async: true
  @moduletag :pending

  alias Session16.PaymentService
  alias Session16.PaymentService.Payment

  describe "create_payment/1" do
    test "creates payment with valid attributes" do
      attrs = %{amount: 1000, currency: "USD"}

      assert {:ok, %Payment{} = payment} = PaymentService.create_payment(attrs)
      assert payment.amount == 1000
      assert payment.currency == "USD"
      assert payment.status == "pending"
      assert payment.id != nil
    end

    test "returns error for missing amount" do
      attrs = %{currency: "USD"}

      assert {:error, :missing_amount} = PaymentService.create_payment(attrs)
    end

    test "returns error for invalid amount" do
      attrs = %{amount: -100, currency: "USD"}

      assert {:error, :invalid_amount} = PaymentService.create_payment(attrs)
    end

    test "returns error for zero amount" do
      attrs = %{amount: 0, currency: "USD"}

      assert {:error, :invalid_amount} = PaymentService.create_payment(attrs)
    end

    test "returns error for missing currency" do
      attrs = %{amount: 1000}

      assert {:error, :missing_currency} = PaymentService.create_payment(attrs)
    end

    test "returns error for unsupported currency" do
      attrs = %{amount: 1000, currency: "BTC"}

      assert {:error, :unsupported_currency} = PaymentService.create_payment(attrs)
    end

    test "accepts supported currencies" do
      for currency <- ~w(USD EUR GBP) do
        assert {:ok, _} = PaymentService.create_payment(%{amount: 100, currency: currency})
      end
    end
  end

  describe "process_payment/2" do
    setup do
      {:ok, payment} = PaymentService.create_payment(%{amount: 1000, currency: "USD"})
      {:ok, payment: payment}
    end

    test "processes payment successfully", %{payment: payment} do
      # Using default mock gateway
      assert {:ok, processed} = PaymentService.process_payment(payment)
      assert processed.status == "completed"
    end

    test "handles declined payment", %{payment: payment} do
      defmodule DeclinedGateway do
        def charge(_, _), do: {:error, :declined}
      end

      assert {:error, failed} = PaymentService.process_payment(payment, DeclinedGateway)
      assert failed.status == "declined"
      assert failed.error_reason =~ "declined"
    end

    test "handles insufficient funds", %{payment: payment} do
      defmodule InsufficientFundsGateway do
        def charge(_, _), do: {:error, :insufficient_funds}
      end

      assert {:error, failed} = PaymentService.process_payment(payment, InsufficientFundsGateway)
      assert failed.status == "failed"
      assert failed.error_reason =~ "Insufficient"
    end
  end

  describe "refund_payment/3" do
    setup do
      {:ok, payment} = PaymentService.create_payment(%{amount: 1000, currency: "USD"})
      {:ok, processed} = PaymentService.process_payment(payment)
      {:ok, payment: processed}
    end

    test "refunds completed payment", %{payment: payment} do
      assert {:ok, refund} = PaymentService.refund_payment(payment, 500)
      assert refund.amount == 500
      assert refund.refund_id != nil
    end

    test "rejects refund for pending payment" do
      pending = %Payment{id: "1", amount: 1000, status: "pending"}

      assert {:error, :invalid_status} = PaymentService.refund_payment(pending, 500)
    end

    test "rejects refund exceeding payment amount", %{payment: payment} do
      assert {:error, :invalid_amount} = PaymentService.refund_payment(payment, 2000)
    end

    test "allows full refund", %{payment: payment} do
      assert {:ok, refund} = PaymentService.refund_payment(payment, 1000)
      assert refund.amount == 1000
    end
  end
end

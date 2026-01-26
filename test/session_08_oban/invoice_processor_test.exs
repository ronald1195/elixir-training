defmodule Session08.InvoiceProcessorTest do
  use ExUnit.Case, async: true
  @moduletag :pending

  alias Session08.InvoiceProcessor

  # Helper to create a job struct for testing
  defp create_job(args, opts \\ []) do
    %Oban.Job{
      args: args,
      attempt: Keyword.get(opts, :attempt, 1),
      max_attempts: Keyword.get(opts, :max_attempts, 5)
    }
  end

  setup do
    # Reset test state before each test
    Process.delete(:test_invoices)
    Process.delete(:pdf_behavior)
    Process.delete(:email_behavior)
    :ok
  end

  describe "perform/1 - successful processing" do
    test "processes a pending invoice successfully" do
      job = create_job(%{"invoice_id" => 123})

      assert :ok = InvoiceProcessor.perform(job)
    end

    test "returns :ok for already sent invoices (idempotent)" do
      # Set up an already-sent invoice
      Process.put(:test_invoices, %{
        456 => %{
          id: 456,
          status: "sent",
          customer_email: "customer@example.com",
          amount: 5000,
          items: []
        }
      })

      job = create_job(%{"invoice_id" => 456})

      # Should return success without reprocessing
      assert :ok = InvoiceProcessor.perform(job)
    end
  end

  describe "perform/1 - error handling" do
    test "cancels for non-existent invoice" do
      Process.put(:test_invoices, %{999 => :not_found})

      job = create_job(%{"invoice_id" => 999})

      assert {:cancel, reason} = InvoiceProcessor.perform(job)
      assert reason =~ "not found"
    end

    test "cancels for invoice in error state" do
      Process.put(:test_invoices, %{
        789 => %{
          id: 789,
          status: "error",
          customer_email: "customer@example.com",
          amount: 5000,
          items: []
        }
      })

      job = create_job(%{"invoice_id" => 789})

      assert {:cancel, reason} = InvoiceProcessor.perform(job)
      assert reason =~ "error state"
    end

    test "retries on PDF generation failure" do
      Process.put(:pdf_behavior, :fail)

      job = create_job(%{"invoice_id" => 123})

      assert {:error, :pdf_generation_failed} = InvoiceProcessor.perform(job)
    end

    test "snoozes when email service is down" do
      Process.put(:email_behavior, :service_down)

      job = create_job(%{"invoice_id" => 123})

      assert {:snooze, seconds} = InvoiceProcessor.perform(job)
      assert seconds > 0
    end

    test "cancels for invalid email address" do
      Process.put(:email_behavior, :invalid_email)

      job = create_job(%{"invoice_id" => 123})

      assert {:cancel, reason} = InvoiceProcessor.perform(job)
      assert reason =~ "Invalid email"
    end
  end

  describe "backoff/1" do
    test "returns increasing backoff times" do
      job1 = create_job(%{"invoice_id" => 1}, attempt: 1)
      job2 = create_job(%{"invoice_id" => 1}, attempt: 2)
      job3 = create_job(%{"invoice_id" => 1}, attempt: 3)

      backoff1 = InvoiceProcessor.backoff(job1)
      backoff2 = InvoiceProcessor.backoff(job2)
      backoff3 = InvoiceProcessor.backoff(job3)

      # Backoff should increase with attempts
      # Allow for jitter by checking minimums
      # 2^1 = 2
      assert backoff1 >= 2
      # 2^2 = 4
      assert backoff2 >= 4
      # 2^3 = 8
      assert backoff3 >= 8

      # Should be exponential growth
      assert backoff2 > backoff1
      assert backoff3 > backoff2
    end

    test "includes jitter" do
      job = create_job(%{"invoice_id" => 1}, attempt: 2)

      # Run multiple times to check for variance (jitter)
      backoffs = for _ <- 1..10, do: InvoiceProcessor.backoff(job)

      # With jitter, we should see some variation
      # At attempt 2: base is 4, with up to 10 jitter = 4-14
      assert Enum.min(backoffs) >= 4
      # 2^2 + max jitter
      assert Enum.max(backoffs) <= 20
    end
  end

  describe "enqueue/1" do
    test "creates a job with correct args" do
      # Note: In real tests with Oban.Testing, you'd use assert_enqueued
      # Here we just verify the function doesn't crash
      assert {:ok, _job} = InvoiceProcessor.enqueue(123)
    end

    test "creates job with invoice_id in args" do
      {:ok, job} = InvoiceProcessor.enqueue(456)

      assert job.args["invoice_id"] == 456
    end
  end

  describe "schedule/2" do
    test "creates a scheduled job" do
      scheduled_time = DateTime.add(DateTime.utc_now(), 3600, :second)

      assert {:ok, job} = InvoiceProcessor.schedule(123, scheduled_time)
      assert job.scheduled_at == scheduled_time
    end

    test "includes invoice_id in args" do
      scheduled_time = DateTime.add(DateTime.utc_now(), 3600, :second)

      {:ok, job} = InvoiceProcessor.schedule(789, scheduled_time)

      assert job.args["invoice_id"] == 789
    end
  end

  describe "worker configuration" do
    test "uses invoices queue" do
      assert InvoiceProcessor.__oban__(:queue) == :invoices
    end

    test "has max 5 attempts" do
      assert InvoiceProcessor.__oban__(:max_attempts) == 5
    end

    test "has uniqueness configured" do
      unique = InvoiceProcessor.__oban__(:unique)
      assert unique[:period] == 300
      assert :invoice_id in unique[:keys]
    end
  end

  describe "simulated operations" do
    test "get_invoice returns invoice by default" do
      assert {:ok, invoice} = InvoiceProcessor.get_invoice(123)
      assert invoice.id == 123
      assert invoice.status == "pending"
    end

    test "get_invoice can be configured for testing" do
      Process.put(:test_invoices, %{
        1 => %{id: 1, status: "sent", customer_email: "a@b.com", amount: 100, items: []}
      })

      assert {:ok, invoice} = InvoiceProcessor.get_invoice(1)
      assert invoice.status == "sent"
    end

    test "generate_pdf succeeds by default" do
      invoice = %{id: 1, status: "pending", customer_email: "a@b.com", amount: 100, items: []}

      assert {:ok, pdf} = InvoiceProcessor.generate_pdf(invoice)
      assert is_binary(pdf)
    end

    test "send_email succeeds by default" do
      invoice = %{id: 1, status: "pending", customer_email: "a@b.com", amount: 100, items: []}

      assert :ok = InvoiceProcessor.send_email(invoice, "pdf content")
    end

    test "mark_sent updates invoice status" do
      invoice = %{id: 1, status: "pending", customer_email: "a@b.com", amount: 100, items: []}

      assert {:ok, updated} = InvoiceProcessor.mark_sent(invoice)
      assert updated.status == "sent"
    end
  end
end

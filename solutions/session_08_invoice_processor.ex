defmodule Session08.InvoiceProcessor do
  @moduledoc """
  Solution for Session 8: Invoice Processor

  An Oban worker for processing invoices asynchronously.
  """

  use Oban.Worker,
    queue: :invoices,
    max_attempts: 5,
    unique: [period: 300, keys: [:invoice_id]]

  def enqueue(invoice_id) do
    %{invoice_id: invoice_id}
    |> new()
    |> Oban.insert()
  end

  def schedule(invoice_id, scheduled_at) do
    %{invoice_id: invoice_id}
    |> new(scheduled_at: scheduled_at)
    |> Oban.insert()
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"invoice_id" => invoice_id}}) do
    with {:ok, invoice} <- get_invoice(invoice_id),
         :ok <- check_status(invoice),
         {:ok, pdf} <- generate_pdf(invoice),
         :ok <- send_email(invoice, pdf),
         {:ok, _updated} <- mark_sent(invoice) do
      :ok
    else
      {:error, :not_found} ->
        {:cancel, "Invoice not found"}

      {:error, :already_sent} ->
        :ok  # Idempotent - already processed

      {:error, :in_error_state} ->
        {:cancel, "Invoice in error state"}

      {:error, :pdf_generation_failed} ->
        {:error, :pdf_generation_failed}

      {:error, :email_service_down} ->
        {:snooze, 60}

      {:error, :invalid_email} ->
        {:cancel, "Invalid email"}
    end
  end

  @impl Oban.Worker
  def backoff(%Oban.Job{attempt: attempt}) do
    # Exponential backoff: 2^attempt + jitter(0..10)
    base = trunc(:math.pow(2, attempt))
    jitter = :rand.uniform(11) - 1  # 0 to 10
    base + jitter
  end

  defp check_status(%{status: "sent"}), do: {:error, :already_sent}
  defp check_status(%{status: "error"}), do: {:error, :in_error_state}
  defp check_status(_invoice), do: :ok

  # Simulated operations (same as exercise module)

  def get_invoice(invoice_id) do
    invoices = Process.get(:test_invoices, %{})

    case Map.get(invoices, invoice_id) do
      nil ->
        {:ok, %{
          id: invoice_id,
          status: "pending",
          customer_email: "customer@example.com",
          amount: 10000,
          items: ["Service Fee"]
        }}

      :not_found ->
        {:error, :not_found}

      invoice ->
        {:ok, invoice}
    end
  end

  def generate_pdf(invoice) do
    case Process.get(:pdf_behavior, :success) do
      :success ->
        {:ok, "PDF content for invoice #{invoice.id}"}

      :fail ->
        {:error, :pdf_generation_failed}
    end
  end

  def send_email(_invoice, _pdf) do
    case Process.get(:email_behavior, :success) do
      :success ->
        :ok

      :service_down ->
        {:error, :email_service_down}

      :invalid_email ->
        {:error, :invalid_email}
    end
  end

  def mark_sent(invoice) do
    {:ok, %{invoice | status: "sent"}}
  end
end

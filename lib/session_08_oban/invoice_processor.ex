defmodule Session08.InvoiceProcessor do
  @moduledoc """
  An Oban worker for processing invoices asynchronously.

  ## Background for OOP Developers

  In Java with Spring, you might use @Async or a message queue:

      @Service
      public class InvoiceService {
          @Async
          public CompletableFuture<Void> processInvoice(Long invoiceId) {
              Invoice invoice = invoiceRepository.findById(invoiceId);
              byte[] pdf = pdfGenerator.generate(invoice);
              emailService.sendInvoice(invoice, pdf);
              invoice.setStatus("SENT");
              invoiceRepository.save(invoice);
              return CompletableFuture.completedFuture(null);
          }
      }

  In Elixir with Oban, we define a worker that:
  - Receives job arguments (invoice_id)
  - Performs the work (generate PDF, send email)
  - Returns a status indicating success or failure
  - Handles retries automatically

  ## Invoice Processing Flow

  1. Invoice is created with status "pending"
  2. Job is enqueued with invoice_id
  3. Worker picks up job:
     a. Fetch invoice
     b. Generate PDF
     c. Send email
     d. Update status to "sent"
  4. If any step fails, job retries (up to max_attempts)

  ## Your Task

  Implement an Oban worker that:
  - Processes invoices by ID
  - Checks idempotency (don't process already-sent invoices)
  - Handles various failure modes appropriately
  - Uses proper retry strategies
  """

  use Oban.Worker,
    queue: :invoices,
    max_attempts: 5,
    unique: [period: 300, keys: [:invoice_id]]

  # For this exercise, we'll simulate the invoice system
  # In a real app, these would be database operations

  @doc """
  Creates a new invoice processing job.

  ## Examples

      iex> Session08.InvoiceProcessor.enqueue(123)
      {:ok, %Oban.Job{}}
  """
  def enqueue(_invoice_id) do
    # TODO: Create and insert an Oban job
    # Hint: %{invoice_id: invoice_id} |> new() |> Oban.insert()
    raise "TODO: Implement enqueue/1"
  end

  @doc """
  Creates a new invoice processing job scheduled for later.

  ## Examples

      iex> Session08.InvoiceProcessor.schedule(123, ~U[2024-01-15 09:00:00Z])
      {:ok, %Oban.Job{}}
  """
  def schedule(_invoice_id, _scheduled_at) do
    # TODO: Create and insert a scheduled Oban job
    # Hint: new(%{invoice_id: id}, scheduled_at: datetime)
    raise "TODO: Implement schedule/2"
  end

  @doc """
  Performs the invoice processing.

  This is called by Oban when the job is ready to run.

  The function should:
  1. Fetch the invoice (simulated with get_invoice/1)
  2. Check if already processed (idempotency)
  3. Generate PDF (simulated with generate_pdf/1)
  4. Send email (simulated with send_email/2)
  5. Mark invoice as sent (simulated with mark_sent/1)

  ## Return Values

  - `:ok` - Job completed successfully
  - `{:error, reason}` - Job failed, will retry
  - `{:cancel, reason}` - Job failed permanently, no retry
  - `{:snooze, seconds}` - Retry after specified seconds

  ## Examples

      iex> Session08.InvoiceProcessor.perform(%Oban.Job{args: %{"invoice_id" => 123}})
      :ok
  """
  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"invoice_id" => _invoice_id}, attempt: _attempt}) do
    # TODO: Implement the invoice processing logic
    #
    # Steps:
    # 1. Fetch invoice with get_invoice/1
    # 2. Check status - if already "sent", return :ok (idempotent)
    # 3. If status is "error", return {:cancel, "Invoice in error state"}
    # 4. Generate PDF with generate_pdf/1
    # 5. Send email with send_email/2
    # 6. Mark as sent with mark_sent/1
    # 7. Return :ok
    #
    # Handle errors:
    # - {:error, :not_found} -> {:cancel, "Invoice not found"}
    # - {:error, :pdf_generation_failed} -> {:error, reason} (retry)
    # - {:error, :email_service_down} -> {:snooze, 60} (try again in 60s)
    # - {:error, :invalid_email} -> {:cancel, "Invalid email"} (don't retry)
    raise "TODO: Implement perform/1"
  end

  @doc """
  Custom backoff strategy.

  For invoice processing, we use exponential backoff with jitter.

  ## Examples

      iex> Session08.InvoiceProcessor.backoff(%Oban.Job{attempt: 1})
      # Returns seconds until next retry
  """
  @impl Oban.Worker
  def backoff(%Oban.Job{attempt: _attempt}) do
    # TODO: Implement exponential backoff with jitter
    # Formula: (2^attempt) + random(0..10)
    # This spreads out retries to avoid thundering herd
    raise "TODO: Implement backoff/1"
  end

  # ============================================================================
  # Simulated Invoice Operations
  # These simulate database and external service calls
  # ============================================================================

  @doc """
  Simulates fetching an invoice from the database.

  Returns:
  - `{:ok, invoice}` - Invoice found
  - `{:error, :not_found}` - Invoice doesn't exist
  """
  def get_invoice(invoice_id) do
    # Simulated invoice data
    # In tests, this can be mocked or configured
    invoices = Process.get(:test_invoices, %{})

    case Map.get(invoices, invoice_id) do
      nil ->
        # Default behavior: return a pending invoice
        {:ok,
         %{
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

  @doc """
  Simulates PDF generation.

  Returns:
  - `{:ok, pdf_binary}` - PDF generated successfully
  - `{:error, :pdf_generation_failed}` - Generation failed
  """
  def generate_pdf(invoice) do
    # Simulated PDF generation
    case Process.get(:pdf_behavior, :success) do
      :success ->
        {:ok, "PDF content for invoice #{invoice.id}"}

      :fail ->
        {:error, :pdf_generation_failed}
    end
  end

  @doc """
  Simulates sending an email.

  Returns:
  - `:ok` - Email sent
  - `{:error, :email_service_down}` - Service unavailable
  - `{:error, :invalid_email}` - Invalid email address
  """
  def send_email(invoice, _pdf) do
    case Process.get(:email_behavior, :success) do
      :success ->
        :ok

      :service_down ->
        {:error, :email_service_down}

      :invalid_email ->
        {:error, :invalid_email}
    end
  end

  @doc """
  Simulates marking an invoice as sent.

  Returns:
  - `{:ok, updated_invoice}` - Invoice updated
  """
  def mark_sent(invoice) do
    {:ok, %{invoice | status: "sent"}}
  end
end

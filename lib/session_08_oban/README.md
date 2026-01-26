# Session 8: Oban - Background Job Processing

## Learning Objectives

By the end of this session, you will:
- Understand when and why to use background jobs
- Implement Oban workers with proper argument handling
- Configure job queues with appropriate concurrency
- Handle job retries and failures gracefully
- Design idempotent jobs for financial systems

## Key Concepts

### Why Background Jobs?

Background jobs handle work that shouldn't block user requests:
- Sending emails/notifications
- Processing uploaded files
- Generating reports
- Syncing with external services
- Batch operations

### OOP Comparison: Message Queues

In Java, you might use RabbitMQ or Kafka:

```java
// Java - Publishing to a queue
@Service
public class InvoiceService {
    @Autowired
    private RabbitTemplate rabbitTemplate;

    public void processInvoice(Invoice invoice) {
        // Save invoice
        invoiceRepository.save(invoice);

        // Queue async processing
        rabbitTemplate.convertAndSend("invoice-queue", invoice.getId());
    }
}

// Consumer
@RabbitListener(queues = "invoice-queue")
public void handleInvoice(String invoiceId) {
    Invoice invoice = invoiceRepository.findById(invoiceId);
    pdfGenerator.generate(invoice);
    emailService.send(invoice);
}
```

In Elixir with Oban, jobs are database-backed and self-contained:

```elixir
defmodule MyApp.Workers.InvoiceProcessor do
  use Oban.Worker, queue: :invoices

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"invoice_id" => invoice_id}}) do
    invoice = Invoices.get!(invoice_id)
    pdf = PDFGenerator.generate(invoice)
    Mailer.send_invoice(invoice, pdf)
    :ok
  end
end

# Enqueueing a job
%{invoice_id: invoice.id}
|> MyApp.Workers.InvoiceProcessor.new()
|> Oban.insert()
```

### Oban Basics

```elixir
# Define a worker
defmodule MyApp.Workers.EmailWorker do
  use Oban.Worker,
    queue: :emails,           # Queue name
    max_attempts: 3,          # Retry up to 3 times
    priority: 1               # Higher priority (0-3, 0 is highest)

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    # args is a map with string keys
    %{"to" => to, "subject" => subject, "body" => body} = args

    case Mailer.send(to, subject, body) do
      :ok -> :ok
      {:error, reason} -> {:error, reason}  # Will retry
    end
  end
end
```

### Return Values

```elixir
@impl Oban.Worker
def perform(job) do
  # Success - job completed
  :ok

  # Success with value (logged but not used)
  {:ok, result}

  # Retry later - will respect max_attempts
  {:error, reason}

  # Cancel - stop immediately, no more retries
  {:cancel, reason}

  # Snooze - retry after specified seconds
  {:snooze, 60}

  # Discard - like cancel but marks as discarded
  {:discard, reason}
end
```

### Queue Configuration

```elixir
# config/config.exs
config :my_app, Oban,
  repo: MyApp.Repo,
  queues: [
    default: 10,        # 10 concurrent workers
    emails: 5,          # 5 concurrent workers
    invoices: 3,        # 3 concurrent workers (resource intensive)
    critical: [limit: 20, paused: false]  # Advanced config
  ]
```

### Scheduling Jobs

```elixir
# Insert immediately
%{user_id: 123}
|> MyWorker.new()
|> Oban.insert()

# Schedule for later
%{report_id: 456}
|> ReportWorker.new(scheduled_at: ~U[2024-01-15 09:00:00Z])
|> Oban.insert()

# Schedule relative to now
%{batch_id: 789}
|> BatchWorker.new(schedule_in: 60)  # 60 seconds from now
|> Oban.insert()

# Insert many at once
jobs = Enum.map(user_ids, fn id ->
  EmailWorker.new(%{user_id: id})
end)
Oban.insert_all(jobs)
```

### Unique Jobs

Prevent duplicate jobs:

```elixir
defmodule MyApp.Workers.UniqueWorker do
  use Oban.Worker,
    queue: :default,
    unique: [
      period: 60,           # Unique for 60 seconds
      states: [:available, :scheduled, :executing],
      keys: [:user_id]      # Only user_id matters for uniqueness
    ]

  @impl Oban.Worker
  def perform(%{args: %{"user_id" => user_id}}) do
    # Only one job per user_id per minute
    process_user(user_id)
  end
end
```

### Handling Failures and Retries

```elixir
defmodule MyApp.Workers.RobustWorker do
  use Oban.Worker,
    queue: :default,
    max_attempts: 5

  @impl Oban.Worker
  def perform(%Oban.Job{attempt: attempt, args: args}) do
    case do_work(args) do
      :ok ->
        :ok

      {:error, :temporary_failure} when attempt < 5 ->
        # Will retry with exponential backoff
        {:error, :temporary_failure}

      {:error, :permanent_failure} ->
        # Don't retry
        {:cancel, "Permanent failure - not retrying"}

      {:error, :rate_limited} ->
        # Retry in 60 seconds
        {:snooze, 60}
    end
  end

  # Custom backoff (optional)
  @impl Oban.Worker
  def backoff(%Oban.Job{attempt: attempt}) do
    # Exponential backoff: 2^attempt seconds
    trunc(:math.pow(2, attempt))
  end
end
```

### Idempotency for Financial Systems

**Critical**: Financial jobs must be idempotent - running twice should have the same effect as running once.

```elixir
defmodule MyApp.Workers.PaymentProcessor do
  use Oban.Worker, queue: :payments, max_attempts: 3

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"payment_id" => payment_id}}) do
    payment = Payments.get!(payment_id)

    # Check idempotency key - was this already processed?
    case payment.status do
      :completed ->
        # Already done, return success
        :ok

      :processing ->
        # Another worker is handling it
        {:snooze, 5}

      :pending ->
        # Safe to process
        with {:ok, _} <- Payments.mark_processing(payment),
             {:ok, result} <- Gateway.charge(payment),
             {:ok, _} <- Payments.mark_completed(payment, result) do
          :ok
        else
          {:error, :already_charged} ->
            # Gateway says already charged - idempotent success
            Payments.mark_completed(payment)
            :ok

          {:error, reason} ->
            Payments.mark_failed(payment, reason)
            {:error, reason}
        end
    end
  end
end
```

### Testing Oban Workers

```elixir
# config/test.exs
config :my_app, Oban, testing: :inline

# In tests
defmodule MyApp.Workers.EmailWorkerTest do
  use MyApp.DataCase

  alias MyApp.Workers.EmailWorker

  test "sends email successfully" do
    # With inline testing, jobs run immediately
    assert :ok = perform_job(EmailWorker, %{
      "to" => "user@example.com",
      "subject" => "Test",
      "body" => "Hello"
    })
  end

  test "retries on temporary failure" do
    # Test the return value
    assert {:error, _} = perform_job(EmailWorker, %{
      "to" => "invalid",
      "subject" => "Test",
      "body" => "Hello"
    })
  end
end
```

## Exercises

### Exercise 1: Invoice Processor

Build an Oban worker for processing invoices asynchronously.

Open `lib/session_08_oban/invoice_processor.ex` and implement the worker.

```bash
mix test test/session_08_oban/invoice_processor_test.exs --include pending
```

## Hints

<details>
<summary>Hint 1: Worker definition</summary>
```elixir
defmodule MyApp.Workers.MyWorker do
  use Oban.Worker,
    queue: :my_queue,
    max_attempts: 3

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    # Your logic here
    :ok
  end
end
```
</details>

<details>
<summary>Hint 2: Accessing job metadata</summary>
The `%Oban.Job{}` struct contains useful metadata:
```elixir
def perform(%Oban.Job{
  args: args,           # The job arguments
  attempt: attempt,     # Current attempt number
  max_attempts: max,    # Maximum attempts
  inserted_at: inserted # When job was created
}) do
  # Use these for logging, decisions, etc.
end
```
</details>

<details>
<summary>Hint 3: Idempotency pattern</summary>
Always check if work was already done:
```elixir
def perform(%{args: %{"id" => id}}) do
  record = Repo.get!(Record, id)

  case record.status do
    :completed -> :ok  # Already done
    :pending -> do_work(record)
  end
end
```
</details>

<details>
<summary>Hint 4: Testing with Oban.Testing</summary>
```elixir
use Oban.Testing, repo: MyApp.Repo

# Assert a job was enqueued
assert_enqueued worker: MyWorker, args: %{id: 123}

# Perform a job directly
perform_job(MyWorker, %{"id" => "123"})
```
</details>

## Common Mistakes

1. **Non-idempotent jobs** - If a job runs twice, it should produce the same result. Always check before performing side effects.

2. **Large args** - Job args are stored in the database. Keep them small (IDs, not full objects).

3. **Not handling all error cases** - Unhandled exceptions cause retries. Be explicit about what should retry.

4. **Wrong queue concurrency** - Too many concurrent workers can overwhelm external services.

5. **Missing unique constraints** - Without uniqueness, duplicate jobs can pile up.

## Workshop Discussion Points

1. When should you use a background job vs. processing synchronously?
2. How do you ensure exactly-once processing for financial transactions?
3. What's the right retry strategy for external API calls?
4. How do you monitor and alert on failing jobs?

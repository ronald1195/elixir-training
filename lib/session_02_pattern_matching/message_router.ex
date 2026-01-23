defmodule Session02.MessageRouter do
  @moduledoc """
  Route webhook and Kafka messages to appropriate handlers based on their type.

  ## Background

  In an event-driven architecture, you receive messages from various sources:
  - Kafka topics with different event types
  - Webhooks from external services
  - Internal system events

  Each message type needs to be routed to the appropriate handler.
  Pattern matching makes this routing clean and maintainable.

  ## Message Formats

  Kafka-style events:
  ```
  %{
    "topic" => "payments",
    "type" => "payment.created",
    "payload" => %{...},
    "metadata" => %{"timestamp" => ..., "correlation_id" => ...}
  }
  ```

  Webhook events:
  ```
  %{
    "event" => "invoice.paid",
    "data" => %{...},
    "webhook_id" => "wh_123"
  }
  ```

  ## Your Task

  Implement routing functions using pattern matching to direct messages
  to the right handlers.
  """

  @doc """
  Route a Kafka-style event to the appropriate handler.

  Event types and their handlers:
  - "payment.created" -> returns `{:payment, :created, payload}`
  - "payment.completed" -> returns `{:payment, :completed, payload}`
  - "payment.failed" -> returns `{:payment, :failed, payload}`
  - "account.opened" -> returns `{:account, :opened, payload}`
  - "account.closed" -> returns `{:account, :closed, payload}`
  - "account.updated" -> returns `{:account, :updated, payload}`
  - Unknown type -> returns `{:unknown, type, payload}`

  Also extract the correlation_id from metadata if present.

  ## Examples

      iex> event = %{"type" => "payment.created", "payload" => %{"amount" => 100}, "metadata" => %{"correlation_id" => "abc"}}
      iex> Session02.MessageRouter.route_event(event)
      {:payment, :created, %{"amount" => 100}, "abc"}

      iex> event = %{"type" => "account.opened", "payload" => %{"id" => "ACC-1"}, "metadata" => %{}}
      iex> Session02.MessageRouter.route_event(event)
      {:account, :opened, %{"id" => "ACC-1"}, nil}
  """
  def route_event(_event) do
    # TODO: Implement using pattern matching
    # Hint: Match on the "type" field to determine the handler
    # Hint: Use Map.get/3 for optional fields like correlation_id
    raise "TODO: Implement route_event/1"
  end

  @doc """
  Route a webhook event to the appropriate handler.

  Webhook events and handlers:
  - "invoice.paid" -> `{:invoice, :paid, data}`
  - "invoice.created" -> `{:invoice, :created, data}`
  - "invoice.overdue" -> `{:invoice, :overdue, data}`
  - "customer.created" -> `{:customer, :created, data}`
  - "customer.updated" -> `{:customer, :updated, data}`
  - Unknown -> `{:unknown, event_type, data}`

  ## Examples

      iex> webhook = %{"event" => "invoice.paid", "data" => %{"invoice_id" => "INV-1"}}
      iex> Session02.MessageRouter.route_webhook(webhook)
      {:invoice, :paid, %{"invoice_id" => "INV-1"}}
  """
  def route_webhook(_webhook) do
    # TODO: Implement using pattern matching
    raise "TODO: Implement route_webhook/1"
  end

  @doc """
  Determine if an event should be processed or ignored.

  Rules:
  - Events with `"test" => true` in metadata should be ignored in production
  - Events with `"duplicate" => true` should be ignored
  - Events older than a given threshold should be ignored
  - Otherwise, process the event

  Takes an event and an environment (:production or :development).

  Returns:
  - `{:process, event}` - event should be processed
  - `{:ignore, reason}` - event should be ignored with reason

  ## Examples

      iex> event = %{"type" => "payment.created", "metadata" => %{"test" => true}}
      iex> Session02.MessageRouter.should_process?(event, :production)
      {:ignore, :test_event}

      iex> event = %{"type" => "payment.created", "metadata" => %{"test" => true}}
      iex> Session02.MessageRouter.should_process?(event, :development)
      {:process, event}

      iex> event = %{"type" => "payment.created", "metadata" => %{"duplicate" => true}}
      iex> Session02.MessageRouter.should_process?(event, :production)
      {:ignore, :duplicate}
  """
  def should_process?(_event, _env) do
    # TODO: Implement using pattern matching and guards
    # Hint: Match on specific metadata patterns
    raise "TODO: Implement should_process?/2"
  end

  @doc """
  Extract all account IDs mentioned in an event.

  Events may reference accounts in different ways:
  - `"account_id"` field in payload
  - `"from_account"` and `"to_account"` for transfers
  - `"affected_accounts"` list
  - Nested in `"data" => %{"account" => %{"id" => ...}}`

  Return a list of unique account IDs found.

  ## Examples

      iex> event = %{"payload" => %{"account_id" => "ACC-1"}}
      iex> Session02.MessageRouter.extract_account_ids(event)
      ["ACC-1"]

      iex> event = %{"payload" => %{"from_account" => "ACC-1", "to_account" => "ACC-2"}}
      iex> Session02.MessageRouter.extract_account_ids(event)
      ["ACC-1", "ACC-2"]

      iex> event = %{"payload" => %{"affected_accounts" => ["ACC-1", "ACC-2", "ACC-3"]}}
      iex> Session02.MessageRouter.extract_account_ids(event)
      ["ACC-1", "ACC-2", "ACC-3"]
  """
  def extract_account_ids(_event) do
    # TODO: Implement using pattern matching
    # Hint: You may need multiple function clauses or use a helper
    # Hint: Use Enum.uniq/1 to ensure uniqueness
    raise "TODO: Implement extract_account_ids/1"
  end

  @doc """
  Group a list of events by their domain (payment, account, invoice, etc.).

  Returns a map where keys are domain atoms and values are lists of events.

  ## Examples

      iex> events = [
      ...>   %{"type" => "payment.created", "payload" => %{}},
      ...>   %{"type" => "account.opened", "payload" => %{}},
      ...>   %{"type" => "payment.failed", "payload" => %{}}
      ...> ]
      iex> Session02.MessageRouter.group_by_domain(events)
      %{
        payment: [%{"type" => "payment.created", "payload" => %{}}, %{"type" => "payment.failed", "payload" => %{}}],
        account: [%{"type" => "account.opened", "payload" => %{}}]
      }
  """
  def group_by_domain(_events) do
    # TODO: Implement using Enum.group_by with a function that extracts the domain
    # Hint: Split the type on "." and take the first part
    raise "TODO: Implement group_by_domain/1"
  end
end

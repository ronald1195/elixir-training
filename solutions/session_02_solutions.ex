# SOLUTION FILE - Do not distribute to participants

defmodule Session02.PaymentProcessor.Solution do
  @moduledoc """
  Reference implementation for PaymentProcessor.
  """

  # Process - multiple function clauses for each transaction type
  def process(%{type: :credit, amount: amount, account_id: id}) do
    {:ok, :credited, id, amount}
  end

  def process(%{type: :debit, amount: amount, account_id: id}) do
    {:ok, :debited, id, amount}
  end

  def process(%{type: :transfer, amount: amount, from_account: from, to_account: to}) do
    {:ok, :transferred, from, to, amount}
  end

  def process(%{type: :refund, amount: amount, account_id: id, original_transaction_id: original}) do
    {:ok, :refunded, id, amount, original}
  end

  def process(_) do
    {:error, :invalid_transaction}
  end

  # Validate - using guards for amount validation
  def validate(%{type: :transfer, amount: amount, from_account: from, to_account: to} = txn)
      when amount > 0 and from != to and from != nil and from != "" and to != nil and to != "" do
    {:ok, txn}
  end

  def validate(%{type: :transfer, from_account: from, to_account: to})
      when from == to do
    {:error, :same_account_transfer}
  end

  def validate(%{type: :transfer}) do
    {:error, :missing_account}
  end

  def validate(%{amount: amount}) when amount <= 0 do
    {:error, :invalid_amount}
  end

  def validate(%{account_id: nil}) do
    {:error, :missing_account}
  end

  def validate(%{account_id: ""}) do
    {:error, :missing_account}
  end

  def validate(%{amount: amount, account_id: _} = txn) when amount > 0 do
    {:ok, txn}
  end

  # Balance delta - using pin operator
  def balance_delta(account_id, %{type: :credit, account_id: ^account_id, amount: amount}) do
    amount
  end

  def balance_delta(account_id, %{type: :debit, account_id: ^account_id, amount: amount}) do
    -amount
  end

  def balance_delta(account_id, %{type: :refund, account_id: ^account_id, amount: amount}) do
    amount
  end

  def balance_delta(account_id, %{type: :transfer, from_account: ^account_id, amount: amount}) do
    -amount
  end

  def balance_delta(account_id, %{type: :transfer, to_account: ^account_id, amount: amount}) do
    amount
  end

  def balance_delta(_account_id, _transaction) do
    0
  end

  # Categorize - simple pattern matching on type
  def categorize(%{type: :credit}), do: :incoming
  def categorize(%{type: :refund}), do: :incoming
  def categorize(%{type: :debit}), do: :outgoing
  def categorize(%{type: :transfer}), do: :internal
  def categorize(_), do: :unknown
end

defmodule Session02.ResponseParser.Solution do
  @moduledoc """
  Reference implementation for ResponseParser.
  """

  # Credit check parsing
  def parse_credit_check({:ok, %{"approved" => true, "credit_limit" => limit, "score" => score}}) do
    {:approved, %{limit: limit, score: score}}
  end

  def parse_credit_check({:ok, %{"approved" => false, "denial_reason" => reason}}) do
    {:denied, reason}
  end

  def parse_credit_check({:error, %{"code" => code, "message" => message}}) do
    {:error, {code, message}}
  end

  def parse_credit_check({:error, :timeout}) do
    {:error, :timeout}
  end

  def parse_credit_check(_) do
    {:error, :unknown_response}
  end

  # Payment response parsing
  def parse_payment_response({:ok, %{"status" => "success", "transaction_id" => id, "amount" => amount}}) do
    {:success, %{transaction_id: id, amount: amount}}
  end

  def parse_payment_response({:ok, %{"status" => "pending", "transaction_id" => id}}) do
    {:pending, id}
  end

  def parse_payment_response({:ok, %{"status" => "declined", "reason" => reason}}) do
    {:declined, reason}
  end

  def parse_payment_response({:error, reason}) do
    {:error, reason}
  end

  # Extract nested account info
  def extract_account_info({:ok, %{"data" => %{"account" => %{"id" => id, "holder" => %{"name" => name}, "balance" => balance}}}}) do
    {:ok, %{id: id, name: name, balance: balance}}
  end

  def extract_account_info({:error, reason}) do
    {:error, reason}
  end

  # Normalize errors
  def normalize_error({:error, reason, message}) do
    {:error, reason, message}
  end

  def normalize_error({:error, reason}) when is_atom(reason) do
    {:error, reason, nil}
  end

  def normalize_error({:error, message}) when is_binary(message) do
    {:error, :unknown, message}
  end

  def normalize_error({:error, %{"code" => code, "message" => message}}) do
    {:error, code, message}
  end

  def normalize_error({:error, %{"error" => message}}) do
    {:error, :unknown, message}
  end
end

defmodule Session02.MessageRouter.Solution do
  @moduledoc """
  Reference implementation for MessageRouter.
  """

  # Route events
  def route_event(%{"type" => "payment.created", "payload" => payload, "metadata" => meta}) do
    {:payment, :created, payload, Map.get(meta, "correlation_id")}
  end

  def route_event(%{"type" => "payment.completed", "payload" => payload, "metadata" => meta}) do
    {:payment, :completed, payload, Map.get(meta, "correlation_id")}
  end

  def route_event(%{"type" => "payment.failed", "payload" => payload, "metadata" => meta}) do
    {:payment, :failed, payload, Map.get(meta, "correlation_id")}
  end

  def route_event(%{"type" => "account.opened", "payload" => payload, "metadata" => meta}) do
    {:account, :opened, payload, Map.get(meta, "correlation_id")}
  end

  def route_event(%{"type" => "account.closed", "payload" => payload, "metadata" => meta}) do
    {:account, :closed, payload, Map.get(meta, "correlation_id")}
  end

  def route_event(%{"type" => "account.updated", "payload" => payload, "metadata" => meta}) do
    {:account, :updated, payload, Map.get(meta, "correlation_id")}
  end

  def route_event(%{"type" => type, "payload" => payload, "metadata" => meta}) do
    {:unknown, type, payload, Map.get(meta, "correlation_id")}
  end

  # Route webhooks
  def route_webhook(%{"event" => "invoice.paid", "data" => data}) do
    {:invoice, :paid, data}
  end

  def route_webhook(%{"event" => "invoice.created", "data" => data}) do
    {:invoice, :created, data}
  end

  def route_webhook(%{"event" => "invoice.overdue", "data" => data}) do
    {:invoice, :overdue, data}
  end

  def route_webhook(%{"event" => "customer.created", "data" => data}) do
    {:customer, :created, data}
  end

  def route_webhook(%{"event" => "customer.updated", "data" => data}) do
    {:customer, :updated, data}
  end

  def route_webhook(%{"event" => event, "data" => data}) do
    {:unknown, event, data}
  end

  # Should process?
  def should_process?(%{"metadata" => %{"duplicate" => true}}, _env) do
    {:ignore, :duplicate}
  end

  def should_process?(%{"metadata" => %{"test" => true}} = _event, :production) do
    {:ignore, :test_event}
  end

  def should_process?(event, _env) do
    {:process, event}
  end

  # Extract account IDs
  def extract_account_ids(%{"payload" => payload}) do
    []
    |> maybe_add_account(payload, "account_id")
    |> maybe_add_account(payload, "from_account")
    |> maybe_add_account(payload, "to_account")
    |> maybe_add_accounts(payload, "affected_accounts")
    |> maybe_add_nested_account(payload)
    |> Enum.uniq()
  end

  def extract_account_ids(_), do: []

  defp maybe_add_account(acc, payload, key) do
    case Map.get(payload, key) do
      nil -> acc
      id -> [id | acc]
    end
  end

  defp maybe_add_accounts(acc, payload, key) do
    case Map.get(payload, key) do
      nil -> acc
      list when is_list(list) -> list ++ acc
    end
  end

  defp maybe_add_nested_account(acc, %{"data" => %{"account" => %{"id" => id}}}) do
    [id | acc]
  end

  defp maybe_add_nested_account(acc, _), do: acc

  # Group by domain
  def group_by_domain(events) do
    Enum.group_by(events, fn %{"type" => type} ->
      type
      |> String.split(".")
      |> hd()
      |> String.to_atom()
    end)
  end
end

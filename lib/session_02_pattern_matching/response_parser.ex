defmodule Session02.ResponseParser do
  @moduledoc """
  Parse various API response formats into normalized structures.

  ## Background

  When integrating with external APIs (credit bureaus, payment processors, etc.),
  you receive responses in various formats. This module normalizes them.

  ## Common Response Patterns

  External APIs often return data in these formats:

  1. Success with data:
     `{:ok, %{"data" => %{...}}}`

  2. Success with status field:
     `{:ok, %{"status" => "success", "result" => %{...}}}`

  3. Error with code and message:
     `{:error, %{"code" => "E001", "message" => "Invalid account"}}`

  4. Error with just a reason atom:
     `{:error, :timeout}`

  ## Your Task

  Implement functions to normalize these different formats into a consistent
  internal structure using pattern matching.
  """

  @doc """
  Parse a credit check response from an external bureau.

  Input formats:
  1. Approved: `{:ok, %{"approved" => true, "credit_limit" => limit, "score" => score}}`
  2. Denied: `{:ok, %{"approved" => false, "denial_reason" => reason}}`
  3. Error: `{:error, %{"code" => code, "message" => message}}`
  4. Timeout: `{:error, :timeout}`
  5. Unknown: anything else

  Output:
  - `{:approved, %{limit: limit, score: score}}`
  - `{:denied, reason}`
  - `{:error, {code, message}}`
  - `{:error, :timeout}`
  - `{:error, :unknown_response}`

  ## Examples

      iex> Session02.ResponseParser.parse_credit_check({:ok, %{"approved" => true, "credit_limit" => 50000, "score" => 720}})
      {:approved, %{limit: 50000, score: 720}}

      iex> Session02.ResponseParser.parse_credit_check({:ok, %{"approved" => false, "denial_reason" => "insufficient_history"}})
      {:denied, "insufficient_history"}

      iex> Session02.ResponseParser.parse_credit_check({:error, %{"code" => "E001", "message" => "Invalid SSN"}})
      {:error, {"E001", "Invalid SSN"}}
  """
  def parse_credit_check(_response) do
    # TODO: Implement using pattern matching
    # Hint: Note that external APIs use string keys ("approved"), not atom keys (:approved)
    raise "TODO: Implement parse_credit_check/1"
  end

  @doc """
  Parse a payment gateway response.

  Input formats:
  1. Success: `{:ok, %{"status" => "success", "transaction_id" => id, "amount" => amount}}`
  2. Pending: `{:ok, %{"status" => "pending", "transaction_id" => id}}`
  3. Declined: `{:ok, %{"status" => "declined", "reason" => reason}}`
  4. Error: `{:error, reason}` where reason is an atom or map

  Output:
  - `{:success, %{transaction_id: id, amount: amount}}`
  - `{:pending, transaction_id}`
  - `{:declined, reason}`
  - `{:error, reason}`

  ## Examples

      iex> Session02.ResponseParser.parse_payment_response({:ok, %{"status" => "success", "transaction_id" => "TXN-123", "amount" => 5000}})
      {:success, %{transaction_id: "TXN-123", amount: 5000}}

      iex> Session02.ResponseParser.parse_payment_response({:ok, %{"status" => "pending", "transaction_id" => "TXN-456"}})
      {:pending, "TXN-456"}
  """
  def parse_payment_response(_response) do
    # TODO: Implement using pattern matching on the "status" field
    raise "TODO: Implement parse_payment_response/1"
  end

  @doc """
  Extract specific fields from a nested API response.

  Given a response like:
  ```
  {:ok, %{
    "data" => %{
      "account" => %{
        "id" => "ACC-123",
        "holder" => %{
          "name" => "Acme Corp",
          "email" => "contact@acme.com"
        },
        "balance" => 50000
      }
    }
  }}
  ```

  Extract and return: `{:ok, %{id: id, name: name, balance: balance}}`

  For errors, return: `{:error, reason}`

  ## Examples

      iex> response = {:ok, %{"data" => %{"account" => %{"id" => "ACC-123", "holder" => %{"name" => "Acme"}, "balance" => 50000}}}}
      iex> Session02.ResponseParser.extract_account_info(response)
      {:ok, %{id: "ACC-123", name: "Acme", balance: 50000}}

      iex> Session02.ResponseParser.extract_account_info({:error, :not_found})
      {:error, :not_found}
  """
  def extract_account_info(_response) do
    # TODO: Implement using deep pattern matching
    # Hint: You can match nested maps in one pattern:
    #   %{"data" => %{"account" => %{"id" => id}}}
    raise "TODO: Implement extract_account_info/1"
  end

  @doc """
  Normalize different error formats into a consistent structure.

  Input formats:
  1. `{:error, :atom_reason}` -> `{:error, :atom_reason, nil}`
  2. `{:error, "string message"}` -> `{:error, :unknown, "string message"}`
  3. `{:error, %{"code" => code, "message" => msg}}` -> `{:error, code, msg}`
  4. `{:error, %{"error" => msg}}` -> `{:error, :unknown, msg}`
  5. `{:error, code, message}` (already normalized) -> pass through

  ## Examples

      iex> Session02.ResponseParser.normalize_error({:error, :timeout})
      {:error, :timeout, nil}

      iex> Session02.ResponseParser.normalize_error({:error, "Something went wrong"})
      {:error, :unknown, "Something went wrong"}

      iex> Session02.ResponseParser.normalize_error({:error, %{"code" => "E001", "message" => "Invalid"}})
      {:error, "E001", "Invalid"}
  """
  def normalize_error(_error) do
    # TODO: Implement using pattern matching
    # Hint: Use `is_atom/1` and `is_binary/1` guards to distinguish formats
    raise "TODO: Implement normalize_error/1"
  end
end

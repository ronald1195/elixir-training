defmodule Session11.CreditBureauClient do
  @moduledoc """
  Solution for Session 11: Credit Bureau Client
  """

  @base_url "https://api.creditbureau.example.com"

  def check_credit(ssn) do
    case validate_ssn(ssn) do
      :ok -> do_check_credit(ssn)
      {:error, _} = error -> error
    end
  end

  defp validate_ssn(ssn) do
    if Regex.match?(~r/^\d{3}-\d{2}-\d{4}$/, ssn) do
      :ok
    else
      {:error, :invalid_ssn}
    end
  end

  defp do_check_credit(ssn) do
    # Simulated response for training
    {:ok, %{score: 750, rating: "excellent", ssn: ssn}}
  end

  def get_report(ssn, opts \\ []) do
    _auth = Keyword.get(opts, :auth_token)

    case validate_ssn(ssn) do
      :ok -> {:ok, %{ssn: ssn, accounts: [], inquiries: []}}
      error -> error
    end
  end

  def verify_identity(identity_info) do
    required = [:name, :ssn, :dob, :address]

    if Enum.all?(required, &Map.has_key?(identity_info, &1)) do
      {:ok, %{verified: true, confidence: 0.95}}
    else
      {:error, :missing_required_fields}
    end
  end

  def request_with_circuit_breaker(method, path, opts \\ []) do
    case :fuse.ask(:credit_bureau, :sync) do
      :ok ->
        case make_request(method, path, opts) do
          {:ok, _} = success -> success
          {:error, _} = error ->
            :fuse.melt(:credit_bureau)
            error
        end

      :blown ->
        {:error, :circuit_open}
    end
  end

  defp make_request(_method, _path, _opts) do
    # Simulated request
    {:ok, %{status: 200, body: %{}}}
  end

  def parse_response(%{status: status, body: body}) when status in 200..299 do
    {:ok, atomize_keys(body)}
  end

  def parse_response(%{status: status, body: body}) do
    {:error, %{status: status, message: body["error"] || "Unknown error"}}
  end

  defp atomize_keys(map) when is_map(map) do
    Map.new(map, fn {k, v} -> {String.to_atom(k), v} end)
  end

  def backoff_delay(attempt) do
    trunc(:math.pow(2, attempt - 1) * 1000)
  end
end

defmodule Session11.CreditBureauClient do
  @moduledoc """
  A robust HTTP client for credit bureau API integration.

  ## Features
  - Automatic retries with exponential backoff
  - Circuit breaker for fault tolerance
  - Response parsing and error handling
  - Request/response logging

  ## Your Task
  Implement a credit bureau client with proper error handling and resilience.
  """

  @base_url "https://api.creditbureau.example.com"
  @timeout 30_000

  @doc """
  Checks the credit score for a given SSN.

  Returns:
  - `{:ok, %{score: integer, rating: string}}` on success
  - `{:error, reason}` on failure
  """
  def check_credit(_ssn) do
    # TODO: Make HTTP request to /credit-check endpoint
    # Handle success (200), client errors (4xx), server errors (5xx)
    raise "TODO: Implement check_credit/1"
  end

  @doc """
  Gets detailed credit report.
  """
  def get_report(_ssn, _opts \\ []) do
    # TODO: Make request with authentication
    raise "TODO: Implement get_report/2"
  end

  @doc """
  Verifies identity information.
  """
  def verify_identity(_identity_info) do
    # TODO: POST request with identity data
    raise "TODO: Implement verify_identity/1"
  end

  @doc """
  Makes a request with circuit breaker protection.
  """
  def request_with_circuit_breaker(_method, _path, _opts \\ []) do
    # TODO: Check circuit breaker, make request, handle failures
    raise "TODO: Implement request_with_circuit_breaker/3"
  end

  @doc """
  Parses the API response into a structured format.
  """
  def parse_response(_response) do
    # TODO: Parse JSON response, handle errors
    raise "TODO: Implement parse_response/1"
  end

  @doc """
  Calculates exponential backoff delay.
  """
  def backoff_delay(_attempt) do
    # TODO: Return delay in milliseconds
    raise "TODO: Implement backoff_delay/1"
  end
end

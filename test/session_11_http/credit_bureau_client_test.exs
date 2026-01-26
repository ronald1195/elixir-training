defmodule Session11.CreditBureauClientTest do
  use ExUnit.Case, async: true
  @moduletag :pending

  alias Session11.CreditBureauClient

  describe "check_credit/1" do
    test "returns credit score on success" do
      {:ok, result} = CreditBureauClient.check_credit("123-45-6789")
      assert Map.has_key?(result, :score)
      assert Map.has_key?(result, :rating)
    end

    test "returns error for invalid SSN" do
      {:error, reason} = CreditBureauClient.check_credit("invalid")
      assert reason == :invalid_ssn
    end
  end

  describe "backoff_delay/1" do
    test "returns exponential delays" do
      assert CreditBureauClient.backoff_delay(1) == 1000
      assert CreditBureauClient.backoff_delay(2) == 2000
      assert CreditBureauClient.backoff_delay(3) == 4000
    end
  end

  describe "parse_response/1" do
    test "parses successful response" do
      response = %{status: 200, body: %{"score" => 750, "rating" => "excellent"}}
      {:ok, parsed} = CreditBureauClient.parse_response(response)
      assert parsed.score == 750
    end

    test "returns error for failed response" do
      response = %{status: 500, body: %{"error" => "Internal error"}}
      {:error, _} = CreditBureauClient.parse_response(response)
    end
  end
end

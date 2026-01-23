defmodule Session02.ResponseParserTest do
  use ExUnit.Case, async: true

  alias Session02.ResponseParser

  describe "parse_credit_check/1" do
    test "parses approved response" do
      response = {:ok, %{"approved" => true, "credit_limit" => 50000, "score" => 720}}

      assert ResponseParser.parse_credit_check(response) ==
               {:approved, %{limit: 50000, score: 720}}
    end

    test "parses denied response" do
      response = {:ok, %{"approved" => false, "denial_reason" => "insufficient_history"}}

      assert ResponseParser.parse_credit_check(response) == {:denied, "insufficient_history"}
    end

    test "parses error with code and message" do
      response = {:error, %{"code" => "E001", "message" => "Invalid SSN"}}

      assert ResponseParser.parse_credit_check(response) == {:error, {"E001", "Invalid SSN"}}
    end

    test "parses timeout error" do
      response = {:error, :timeout}

      assert ResponseParser.parse_credit_check(response) == {:error, :timeout}
    end

    test "handles unknown response format" do
      response = {:ok, %{"something" => "unexpected"}}

      assert ResponseParser.parse_credit_check(response) == {:error, :unknown_response}
    end

    test "handles completely malformed response" do
      response = "not a tuple"

      assert ResponseParser.parse_credit_check(response) == {:error, :unknown_response}
    end
  end

  describe "parse_payment_response/1" do
    test "parses success response" do
      response = {:ok, %{"status" => "success", "transaction_id" => "TXN-123", "amount" => 5000}}

      assert ResponseParser.parse_payment_response(response) ==
               {:success, %{transaction_id: "TXN-123", amount: 5000}}
    end

    test "parses pending response" do
      response = {:ok, %{"status" => "pending", "transaction_id" => "TXN-456"}}

      assert ResponseParser.parse_payment_response(response) == {:pending, "TXN-456"}
    end

    test "parses declined response" do
      response = {:ok, %{"status" => "declined", "reason" => "insufficient_funds"}}

      assert ResponseParser.parse_payment_response(response) == {:declined, "insufficient_funds"}
    end

    test "parses error tuple with atom" do
      response = {:error, :connection_failed}

      assert ResponseParser.parse_payment_response(response) == {:error, :connection_failed}
    end

    test "parses error tuple with map" do
      response = {:error, %{"code" => "500", "message" => "Server error"}}

      assert ResponseParser.parse_payment_response(response) ==
               {:error, %{"code" => "500", "message" => "Server error"}}
    end
  end

  describe "extract_account_info/1" do
    test "extracts nested account info" do
      response =
        {:ok,
         %{
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

      assert ResponseParser.extract_account_info(response) ==
               {:ok, %{id: "ACC-123", name: "Acme Corp", balance: 50000}}
    end

    test "passes through error" do
      response = {:error, :not_found}

      assert ResponseParser.extract_account_info(response) == {:error, :not_found}
    end

    test "handles error with message" do
      response = {:error, "Account not found"}

      assert ResponseParser.extract_account_info(response) == {:error, "Account not found"}
    end
  end

  describe "normalize_error/1" do
    test "normalizes atom error" do
      assert ResponseParser.normalize_error({:error, :timeout}) == {:error, :timeout, nil}
    end

    test "normalizes string error" do
      assert ResponseParser.normalize_error({:error, "Something went wrong"}) ==
               {:error, :unknown, "Something went wrong"}
    end

    test "normalizes map error with code and message" do
      assert ResponseParser.normalize_error({:error, %{"code" => "E001", "message" => "Invalid"}}) ==
               {:error, "E001", "Invalid"}
    end

    test "normalizes map error with just error key" do
      assert ResponseParser.normalize_error({:error, %{"error" => "Bad request"}}) ==
               {:error, :unknown, "Bad request"}
    end

    test "passes through already normalized error" do
      assert ResponseParser.normalize_error({:error, :not_found, "Resource missing"}) ==
               {:error, :not_found, "Resource missing"}
    end
  end
end

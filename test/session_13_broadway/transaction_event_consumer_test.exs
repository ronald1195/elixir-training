defmodule Session13.TransactionEventConsumerTest do
  use ExUnit.Case, async: true
  @moduletag :pending

  alias Session13.TransactionEventConsumer

  describe "parse_event/1" do
    test "parses valid JSON event" do
      raw = ~s({"type": "transaction.created", "data": {"id": "123", "amount": 1000}})
      {:ok, event} = TransactionEventConsumer.parse_event(raw)
      assert event.type == "transaction.created"
      assert event.data.id == "123"
    end

    test "returns error for invalid JSON" do
      {:error, _} = TransactionEventConsumer.parse_event("invalid json")
    end
  end

  describe "validate_event/1" do
    test "validates event with required fields" do
      event = %{type: "transaction.created", data: %{id: "123", amount: 1000}}
      assert :ok = TransactionEventConsumer.validate_event(event)
    end

    test "returns error for missing type" do
      event = %{data: %{id: "123"}}
      {:error, _} = TransactionEventConsumer.validate_event(event)
    end
  end

  describe "route_event/1" do
    test "routes transaction.created to transactions batcher" do
      event = %{type: "transaction.created"}
      assert :transactions = TransactionEventConsumer.route_event(event)
    end

    test "routes transaction.failed to alerts batcher" do
      event = %{type: "transaction.failed"}
      assert :alerts = TransactionEventConsumer.route_event(event)
    end
  end
end

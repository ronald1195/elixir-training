defmodule Session17.NotificationChannelTest do
  use ExUnit.Case, async: true
  @moduletag :pending

  alias Session17.NotificationChannel

  describe "subscribe/1 and broadcast_transaction/3" do
    test "receives broadcasts after subscribing" do
      user_id = "user-#{System.unique_integer([:positive])}"

      :ok = NotificationChannel.subscribe(user_id)

      transaction = %{id: "txn-123", amount: 1000, status: "completed"}
      :ok = NotificationChannel.broadcast_transaction(user_id, :completed, transaction)

      assert_receive {:transaction, :completed, ^transaction}, 1000
    end

    test "does not receive broadcasts for other users" do
      user_id = "user-#{System.unique_integer([:positive])}"
      other_user = "user-#{System.unique_integer([:positive])}"

      :ok = NotificationChannel.subscribe(user_id)

      transaction = %{id: "txn-456", amount: 2000}
      :ok = NotificationChannel.broadcast_transaction(other_user, :created, transaction)

      refute_receive {:transaction, _, _}, 100
    end
  end

  describe "unsubscribe/1" do
    test "stops receiving broadcasts after unsubscribe" do
      user_id = "user-#{System.unique_integer([:positive])}"

      :ok = NotificationChannel.subscribe(user_id)
      :ok = NotificationChannel.unsubscribe(user_id)

      transaction = %{id: "txn-789", amount: 500}
      :ok = NotificationChannel.broadcast_transaction(user_id, :created, transaction)

      refute_receive {:transaction, _, _}, 100
    end
  end

  describe "verify_webhook_signature/3" do
    test "verifies valid signature" do
      payload = ~s({"type": "payment.completed", "data": {"id": "123"}})
      secret = "webhook_secret_key"
      signature = :crypto.mac(:hmac, :sha256, secret, payload) |> Base.encode16(case: :lower)

      assert {:ok, parsed} =
               NotificationChannel.verify_webhook_signature(payload, signature, secret)

      assert parsed["type"] == "payment.completed"
    end

    test "rejects invalid signature" do
      payload = ~s({"type": "payment.completed"})
      secret = "webhook_secret_key"
      invalid_signature = "invalid"

      assert {:error, :invalid_signature} =
               NotificationChannel.verify_webhook_signature(payload, invalid_signature, secret)
    end
  end

  describe "handle_webhook/3" do
    test "processes valid webhook and broadcasts" do
      user_id = "user-#{System.unique_integer([:positive])}"
      :ok = NotificationChannel.subscribe(user_id)

      payload =
        Jason.encode!(%{
          type: "transaction.completed",
          data: %{id: "txn-123", user_id: user_id, amount: 1000}
        })

      secret = "webhook_secret"
      signature = :crypto.mac(:hmac, :sha256, secret, payload) |> Base.encode16(case: :lower)

      assert :ok = NotificationChannel.handle_webhook(payload, signature, secret)

      assert_receive {:transaction, :completed, _}, 1000
    end
  end

  describe "route_event/1" do
    test "routes transaction.created events" do
      event = %{"type" => "transaction.created", "data" => %{}}
      assert {:transaction, :created} = NotificationChannel.route_event(event)
    end

    test "routes transaction.completed events" do
      event = %{"type" => "transaction.completed", "data" => %{}}
      assert {:transaction, :completed} = NotificationChannel.route_event(event)
    end

    test "routes transaction.failed events" do
      event = %{"type" => "transaction.failed", "data" => %{}}
      assert {:transaction, :failed} = NotificationChannel.route_event(event)
    end
  end
end

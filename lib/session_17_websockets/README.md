# Session 17: WebSockets & Real-Time Features

## Learning Objectives

By the end of this session, you will:
- Understand Phoenix Channels and PubSub
- Implement real-time notifications
- Handle webhook callbacks with HMAC verification
- Build a transaction notification system

## Key Concepts

### Phoenix PubSub

```elixir
# Broadcasting
Phoenix.PubSub.broadcast(MyApp.PubSub, "transactions:user-123", {:new_transaction, txn})

# Subscribing
Phoenix.PubSub.subscribe(MyApp.PubSub, "transactions:user-123")

# Receiving (in GenServer)
def handle_info({:new_transaction, txn}, state) do
  # Handle the broadcast
  {:noreply, state}
end
```

### Webhook Verification

```elixir
def verify_webhook(payload, signature, secret) do
  expected = :crypto.mac(:hmac, :sha256, secret, payload) |> Base.encode16(case: :lower)

  if Plug.Crypto.secure_compare(expected, signature) do
    {:ok, Jason.decode!(payload)}
  else
    {:error, :invalid_signature}
  end
end
```

## Exercises

### Exercise 1: Notification Channel

Implement real-time transaction notifications using PubSub.

Open `lib/session_17_websockets/notification_channel.ex`.

```bash
mix test test/session_17_websockets/ --include pending
```

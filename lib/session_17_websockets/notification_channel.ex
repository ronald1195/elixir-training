defmodule Session17.NotificationChannel do
  @moduledoc """
  Real-time notification system using Phoenix PubSub.

  ## Features
  - Subscribe to transaction notifications
  - Broadcast new transactions
  - Handle webhook callbacks
  - HMAC signature verification

  ## Your Task
  Implement a notification system for real-time transaction updates.
  """

  @pubsub ElixirTraining.PubSub

  @doc """
  Subscribes to notifications for a user.

  The caller process will receive messages like:
  - {:transaction, :created, transaction}
  - {:transaction, :completed, transaction}
  - {:transaction, :failed, transaction}
  """
  def subscribe(_user_id) do
    # TODO: Subscribe to user-specific topic
    # Hint: Phoenix.PubSub.subscribe(@pubsub, topic)
    raise "TODO: Implement subscribe/1"
  end

  @doc """
  Unsubscribes from notifications.
  """
  def unsubscribe(_user_id) do
    # TODO: Unsubscribe from topic
    raise "TODO: Implement unsubscribe/1"
  end

  @doc """
  Broadcasts a transaction event to subscribers.
  """
  def broadcast_transaction(_user_id, _event_type, _transaction) do
    # TODO: Broadcast to user topic
    # Hint: Phoenix.PubSub.broadcast(@pubsub, topic, message)
    raise "TODO: Implement broadcast_transaction/3"
  end

  @doc """
  Broadcasts to all subscribers of an account.
  """
  def broadcast_to_account(_account_id, _event) do
    # TODO: Broadcast to account topic
    raise "TODO: Implement broadcast_to_account/2"
  end

  @doc """
  Verifies a webhook signature using HMAC-SHA256.

  Returns {:ok, parsed_payload} or {:error, :invalid_signature}
  """
  def verify_webhook_signature(_payload, _signature, _secret) do
    # TODO: Compute HMAC and compare with signature
    raise "TODO: Implement verify_webhook_signature/3"
  end

  @doc """
  Handles an incoming webhook.

  1. Verify signature
  2. Parse payload
  3. Route to appropriate handler
  4. Broadcast notification
  """
  def handle_webhook(_payload, _signature, _secret) do
    # TODO: Full webhook handling flow
    raise "TODO: Implement handle_webhook/3"
  end

  @doc """
  Routes a webhook event to the appropriate handler.
  """
  def route_event(_event) do
    # TODO: Pattern match on event type and route
    raise "TODO: Implement route_event/1"
  end

  # Private helpers

  defp topic_for_user(user_id), do: "notifications:user:#{user_id}"
  defp topic_for_account(account_id), do: "notifications:account:#{account_id}"
end

defmodule Session17.NotificationHandler do
  @moduledoc """
  GenServer that handles incoming notifications.
  """

  use GenServer

  def start_link(opts) do
    user_id = Keyword.fetch!(opts, :user_id)
    GenServer.start_link(__MODULE__, user_id)
  end

  @impl true
  def init(user_id) do
    # TODO: Subscribe to notifications
    {:ok, %{user_id: user_id, notifications: []}}
  end

  @impl true
  def handle_info({:transaction, _event, _txn} = msg, state) do
    # TODO: Store notification, maybe trigger callback
    {:noreply, %{state | notifications: [msg | state.notifications]}}
  end

  def get_notifications(pid) do
    GenServer.call(pid, :get_notifications)
  end

  @impl true
  def handle_call(:get_notifications, _from, state) do
    {:reply, state.notifications, state}
  end
end

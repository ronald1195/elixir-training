defmodule Session17.NotificationChannel do
  @moduledoc """
  Solution for Session 17: Notification Channel
  """

  @pubsub ElixirTraining.PubSub

  def subscribe(user_id) do
    Phoenix.PubSub.subscribe(@pubsub, topic_for_user(user_id))
  end

  def unsubscribe(user_id) do
    Phoenix.PubSub.unsubscribe(@pubsub, topic_for_user(user_id))
  end

  def broadcast_transaction(user_id, event_type, transaction) do
    Phoenix.PubSub.broadcast(@pubsub, topic_for_user(user_id), {:transaction, event_type, transaction})
  end

  def broadcast_to_account(account_id, event) do
    Phoenix.PubSub.broadcast(@pubsub, topic_for_account(account_id), event)
  end

  def verify_webhook_signature(payload, signature, secret) do
    expected = :crypto.mac(:hmac, :sha256, secret, payload) |> Base.encode16(case: :lower)

    if Plug.Crypto.secure_compare(expected, String.downcase(signature)) do
      {:ok, Jason.decode!(payload)}
    else
      {:error, :invalid_signature}
    end
  end

  def handle_webhook(payload, signature, secret) do
    with {:ok, parsed} <- verify_webhook_signature(payload, signature, secret),
         {type, event_type} <- route_event(parsed) do
      user_id = get_in(parsed, ["data", "user_id"])

      if user_id do
        broadcast_transaction(user_id, event_type, parsed["data"])
      end

      :ok
    end
  end

  def route_event(%{"type" => "transaction.created"}), do: {:transaction, :created}
  def route_event(%{"type" => "transaction.completed"}), do: {:transaction, :completed}
  def route_event(%{"type" => "transaction.failed"}), do: {:transaction, :failed}
  def route_event(%{"type" => "transaction.refunded"}), do: {:transaction, :refunded}
  def route_event(_), do: {:unknown, :unknown}

  defp topic_for_user(user_id), do: "notifications:user:#{user_id}"
  defp topic_for_account(account_id), do: "notifications:account:#{account_id}"
end

defmodule Session17.NotificationHandler do
  use GenServer

  def start_link(opts) do
    user_id = Keyword.fetch!(opts, :user_id)
    GenServer.start_link(__MODULE__, user_id)
  end

  @impl true
  def init(user_id) do
    Session17.NotificationChannel.subscribe(user_id)
    {:ok, %{user_id: user_id, notifications: []}}
  end

  @impl true
  def handle_info({:transaction, _event, _txn} = msg, state) do
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

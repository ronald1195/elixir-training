defmodule Session13.TransactionEventConsumer do
  @moduledoc """
  Solution for Session 13: Transaction Event Consumer
  """

  use Broadway
  alias Broadway.Message

  def start_link(opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {Session13.TestProducer, opts}
      ],
      processors: [
        default: [concurrency: 10]
      ],
      batchers: [
        transactions: [concurrency: 5, batch_size: 100],
        alerts: [concurrency: 2, batch_size: 10]
      ]
    )
  end

  @impl true
  def handle_message(_processor, message, _context) do
    message
    |> Message.update_data(fn data ->
      with {:ok, event} <- parse_event(data),
           :ok <- validate_event(event) do
        event
      else
        {:error, reason} -> {:error, reason}
      end
    end)
    |> Message.put_batcher(route_event(message.data))
  end

  @impl true
  def handle_batch(:transactions, messages, _batch_info, _context) do
    # Bulk insert transactions
    _events = Enum.map(messages, & &1.data)
    messages
  end

  def handle_batch(:alerts, messages, _batch_info, _context) do
    # Send alerts for failed transactions
    _events = Enum.map(messages, & &1.data)
    messages
  end

  def parse_event(raw_data) when is_binary(raw_data) do
    case Jason.decode(raw_data) do
      {:ok, data} ->
        event = %{
          type: data["type"],
          data: atomize_keys(data["data"] || %{})
        }
        {:ok, event}

      {:error, _} ->
        {:error, :invalid_json}
    end
  end

  def parse_event(%{} = event), do: {:ok, event}

  defp atomize_keys(map) when is_map(map) do
    Map.new(map, fn {k, v} -> {String.to_atom(k), v} end)
  end

  def validate_event(%{type: type, data: data}) when is_binary(type) and is_map(data) do
    :ok
  end

  def validate_event(_), do: {:error, :invalid_event}

  def route_event(%{type: "transaction.failed"}), do: :alerts
  def route_event(%{type: "transaction." <> _}), do: :transactions
  def route_event(_), do: :default

  @impl true
  def handle_failed(messages, _context) do
    Enum.each(messages, fn %{data: data} ->
      # Log or send to dead letter queue
      IO.inspect(data, label: "Failed message")
    end)

    messages
  end
end

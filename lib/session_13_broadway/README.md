# Session 13: Broadway & Message Processing

## Learning Objectives

By the end of this session, you will:
- Understand Broadway's architecture for message processing
- Implement producers, processors, and batchers
- Handle acknowledgments and failures properly
- Design idempotent message consumers

## Key Concepts

### Broadway Pipeline

```elixir
defmodule MyApp.TransactionPipeline do
  use Broadway

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [module: {MyProducer, []}],
      processors: [default: [concurrency: 10]],
      batchers: [
        default: [concurrency: 5, batch_size: 100]
      ]
    )
  end

  @impl true
  def handle_message(_, message, _) do
    message
    |> Message.update_data(&process/1)
  end

  @impl true
  def handle_batch(_, messages, _, _) do
    # Batch processing
    messages
  end
end
```

## Exercises

### Exercise 1: Transaction Event Consumer

Build a Broadway pipeline for processing transaction events.

Open `lib/session_13_broadway/transaction_event_consumer.ex`.

```bash
mix test test/session_13_broadway/ --include pending
```

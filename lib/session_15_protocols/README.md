# Session 15: Protocols, Behaviours & Polymorphism

## Learning Objectives

By the end of this session, you will:
- Understand the difference between protocols and behaviours
- Implement polymorphism using protocols
- Define contracts with behaviours
- Build extensible payment gateway abstractions

## Key Concepts

### Behaviours - Compile-time Contracts

```elixir
defmodule PaymentGateway do
  @callback process_payment(map()) :: {:ok, map()} | {:error, term()}
  @callback refund_payment(String.t(), integer()) :: {:ok, map()} | {:error, term()}
end

defmodule Stripe do
  @behaviour PaymentGateway

  @impl PaymentGateway
  def process_payment(params), do: # ...

  @impl PaymentGateway
  def refund_payment(id, amount), do: # ...
end
```

### Protocols - Runtime Polymorphism

```elixir
defprotocol Formattable do
  def format(data)
end

defimpl Formattable, for: Integer do
  def format(cents), do: "$#{cents / 100}"
end

defimpl Formattable, for: Map do
  def format(%{amount: amount, currency: currency}) do
    "#{currency} #{amount / 100}"
  end
end
```

## Exercises

### Exercise 1: Payment Gateway Behaviour

Define a payment gateway behaviour and implement multiple providers.

### Exercise 2: Payment Formatter Protocol

Create a protocol for formatting different payment types.

Open `lib/session_15_protocols/`.

```bash
mix test test/session_15_protocols/ --include pending
```

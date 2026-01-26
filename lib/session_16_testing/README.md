# Session 16: Testing in Elixir

## Learning Objectives

By the end of this session, you will:
- Write comprehensive ExUnit tests
- Use Mox for mocking external dependencies
- Use ExMachina for test factories
- Test GenServers and async code
- Apply testing patterns for financial systems

## Key Concepts

### ExUnit Basics

```elixir
defmodule MyApp.PaymentTest do
  use ExUnit.Case, async: true

  describe "process/1" do
    setup do
      {:ok, payment: %{amount: 1000, currency: "USD"}}
    end

    test "succeeds with valid payment", %{payment: payment} do
      assert {:ok, result} = Payments.process(payment)
      assert result.status == "completed"
    end
  end
end
```

### Mox for Dependency Injection

```elixir
# test/support/mocks.ex
Mox.defmock(MockGateway, for: PaymentGateway)

# In tests
test "handles gateway errors" do
  expect(MockGateway, :process, fn _ ->
    {:error, :declined}
  end)

  assert {:error, :payment_failed} = Payments.charge(amount, MockGateway)
end
```

### ExMachina Factories

```elixir
defmodule MyApp.Factory do
  use ExMachina.Ecto, repo: MyApp.Repo

  def payment_factory do
    %Payment{
      amount: 1000,
      currency: "USD",
      status: "pending"
    }
  end
end
```

## Exercises

### Exercise 1: Testing Strategies

Implement comprehensive tests for a payment processing module.

Open `lib/session_16_testing/`.

```bash
mix test test/session_16_testing/ --include pending
```

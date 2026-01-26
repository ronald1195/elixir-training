# Session 11: HTTP Clients & External Integrations

## Learning Objectives

By the end of this session, you will:
- Build robust HTTP clients using Req
- Implement retry logic and circuit breakers
- Handle various response formats (JSON, XML)
- Design resilient external service integrations
- Apply patterns for financial API integrations

## Key Concepts

### Using Req for HTTP Requests

```elixir
# Simple GET request
{:ok, response} = Req.get("https://api.example.com/users")

# With options
{:ok, response} = Req.get("https://api.example.com/users",
  headers: [{"authorization", "Bearer #{token}"}],
  params: [page: 1, limit: 10],
  receive_timeout: 30_000
)

# POST with JSON body
{:ok, response} = Req.post("https://api.example.com/payments",
  json: %{amount: 1000, currency: "USD"}
)
```

### Retry Logic

```elixir
Req.get(url,
  retry: :transient,  # Retry on 5xx and network errors
  retry_delay: fn attempt -> attempt * 1000 end,
  max_retries: 3
)
```

### Circuit Breakers with Fuse

```elixir
defmodule CreditBureauClient do
  def check_credit(ssn) do
    case :fuse.ask(:credit_bureau, :sync) do
      :ok -> do_check(ssn)
      :blown -> {:error, :circuit_open}
    end
  end

  defp do_check(ssn) do
    case Req.get(url, params: [ssn: ssn]) do
      {:ok, %{status: 200, body: body}} ->
        {:ok, body}
      {:ok, %{status: status}} ->
        :fuse.melt(:credit_bureau)
        {:error, {:http_error, status}}
      {:error, reason} ->
        :fuse.melt(:credit_bureau)
        {:error, reason}
    end
  end
end
```

## Exercises

### Exercise 1: Credit Bureau Client

Build a robust HTTP client for credit bureau API integration.

Open `lib/session_11_http/credit_bureau_client.ex`.

```bash
mix test test/session_11_http/ --include pending
```

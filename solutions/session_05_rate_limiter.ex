defmodule Session05.RateLimiter do
  @moduledoc """
  Solution for Session 5: Rate Limiter

  An in-memory rate limiter using Elixir processes.
  """

  @default_window_ms 1000

  def start_link(opts) do
    limit = Keyword.fetch!(opts, :limit)
    window_ms = Keyword.get(opts, :window_ms, @default_window_ms)

    state = %{
      limit: limit,
      count: 0,
      window_ms: window_ms
    }

    pid = spawn_link(fn ->
      schedule_reset(window_ms)
      loop(state)
    end)

    {:ok, pid}
  end

  def check_request(pid) do
    ref = make_ref()
    send(pid, {:check_request, self(), ref})

    receive do
      {:response, ^ref, result} -> result
    after
      5000 -> {:error, :timeout}
    end
  end

  def get_count(pid) do
    ref = make_ref()
    send(pid, {:get_count, self(), ref})

    receive do
      {:response, ^ref, count} -> count
    after
      5000 -> {:error, :timeout}
    end
  end

  def get_remaining(pid) do
    ref = make_ref()
    send(pid, {:get_remaining, self(), ref})

    receive do
      {:response, ^ref, remaining} -> remaining
    after
      5000 -> {:error, :timeout}
    end
  end

  def stop(pid) do
    send(pid, :stop)
    :ok
  end

  def reset(pid) do
    ref = make_ref()
    send(pid, {:reset, self(), ref})

    receive do
      {:response, ^ref, :ok} -> :ok
    after
      5000 -> {:error, :timeout}
    end
  end

  # Private functions

  defp schedule_reset(window_ms) do
    Process.send_after(self(), :tick, window_ms)
  end

  defp loop(state) do
    receive do
      {:check_request, caller, ref} ->
        {result, new_state} = do_check_request(state)
        send(caller, {:response, ref, result})
        loop(new_state)

      {:get_count, caller, ref} ->
        send(caller, {:response, ref, state.count})
        loop(state)

      {:get_remaining, caller, ref} ->
        remaining = max(state.limit - state.count, 0)
        send(caller, {:response, ref, remaining})
        loop(state)

      {:reset, caller, ref} ->
        send(caller, {:response, ref, :ok})
        loop(%{state | count: 0})

      :tick ->
        schedule_reset(state.window_ms)
        loop(%{state | count: 0})

      :stop ->
        :ok
    end
  end

  defp do_check_request(%{count: count, limit: limit} = state) when count < limit do
    new_state = %{state | count: count + 1}
    remaining = limit - count - 1
    {{:ok, remaining}, new_state}
  end

  defp do_check_request(state) do
    {{:error, :rate_limited}, state}
  end
end

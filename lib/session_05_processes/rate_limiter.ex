defmodule Session05.RateLimiter do
  @moduledoc """
  An in-memory rate limiter using Elixir processes.

  ## Background for OOP Developers

  In Java/C#, you might use something like:

      class RateLimiter {
          private final int limit;
          private int count = 0;
          private final Object lock = new Object();

          public boolean tryAcquire() {
              synchronized(lock) {
                  if (count < limit) {
                      count++;
                      return true;
                  }
                  return false;
              }
          }
      }

  This requires careful synchronization to avoid race conditions.

  In Elixir, we use a process to encapsulate state. The process handles one
  message at a time, so there's no need for locks:

      # Each client gets their own rate limiter process
      pid = RateLimiter.start_link(limit: 10, window_ms: 1000)
      {:ok, 9} = RateLimiter.check_request(pid)
      {:ok, 8} = RateLimiter.check_request(pid)
      # ... after 1000ms, counter resets

  ## How It Works

  1. Start a process for each client/API key
  2. The process tracks request count and time window
  3. When a request comes in, check if under limit
  4. Periodically reset the counter (sliding or fixed window)

  ## Your Task

  Implement a rate limiter process that:
  - Allows N requests per time window
  - Returns remaining request count
  - Resets after the window expires
  """

  @doc """
  Starts a new rate limiter process.

  Options:
  - `:limit` - Maximum number of requests per window (required)
  - `:window_ms` - Window duration in milliseconds (default: 1000)

  Returns the PID of the rate limiter process.

  ## Examples

      iex> {:ok, pid} = Session05.RateLimiter.start_link(limit: 5, window_ms: 1000)
      iex> is_pid(pid)
      true
  """
  def start_link(_opts) do
    # TODO: Parse options and spawn a process running the receive loop
    # Initial state should include: limit, count (starts at 0), window_ms
    # Hint: Use spawn_link/1 to create the process
    # Hint: Schedule the first reset using Process.send_after/3
    raise "TODO: Implement start_link/1"
  end

  @doc """
  Checks if a request is allowed and decrements the remaining count.

  Returns:
  - `{:ok, remaining}` - Request allowed, returns remaining requests in window
  - `{:error, :rate_limited}` - Request denied, limit exceeded

  ## Examples

      iex> {:ok, pid} = Session05.RateLimiter.start_link(limit: 2, window_ms: 60000)
      iex> Session05.RateLimiter.check_request(pid)
      {:ok, 1}
      iex> Session05.RateLimiter.check_request(pid)
      {:ok, 0}
      iex> Session05.RateLimiter.check_request(pid)
      {:error, :rate_limited}
  """
  def check_request(_pid) do
    # TODO: Send a check_request message to the rate limiter process
    # Wait for the response with a timeout
    # Hint: Include self() in the message so the process can reply
    raise "TODO: Implement check_request/1"
  end

  @doc """
  Returns the current count of requests made in the current window.

  ## Examples

      iex> {:ok, pid} = Session05.RateLimiter.start_link(limit: 5, window_ms: 60000)
      iex> Session05.RateLimiter.get_count(pid)
      0
      iex> Session05.RateLimiter.check_request(pid)
      iex> Session05.RateLimiter.get_count(pid)
      1
  """
  def get_count(_pid) do
    # TODO: Send a get_count message and return the current count
    raise "TODO: Implement get_count/1"
  end

  @doc """
  Returns the remaining requests allowed in the current window.

  ## Examples

      iex> {:ok, pid} = Session05.RateLimiter.start_link(limit: 5, window_ms: 60000)
      iex> Session05.RateLimiter.get_remaining(pid)
      5
      iex> Session05.RateLimiter.check_request(pid)
      iex> Session05.RateLimiter.get_remaining(pid)
      4
  """
  def get_remaining(_pid) do
    # TODO: Send a get_remaining message and return remaining count
    raise "TODO: Implement get_remaining/1"
  end

  @doc """
  Stops the rate limiter process.

  ## Examples

      iex> {:ok, pid} = Session05.RateLimiter.start_link(limit: 5)
      iex> Session05.RateLimiter.stop(pid)
      :ok
      iex> Process.alive?(pid)
      false
  """
  def stop(_pid) do
    # TODO: Send a stop message to terminate the process gracefully
    raise "TODO: Implement stop/1"
  end

  @doc """
  Manually resets the rate limiter counter.

  Useful for testing or administrative actions.

  ## Examples

      iex> {:ok, pid} = Session05.RateLimiter.start_link(limit: 2, window_ms: 60000)
      iex> Session05.RateLimiter.check_request(pid)
      iex> Session05.RateLimiter.check_request(pid)
      iex> Session05.RateLimiter.check_request(pid)
      {:error, :rate_limited}
      iex> Session05.RateLimiter.reset(pid)
      :ok
      iex> Session05.RateLimiter.check_request(pid)
      {:ok, 1}
  """
  def reset(_pid) do
    # TODO: Send a reset message to clear the counter
    raise "TODO: Implement reset/1"
  end

  # ============================================================================
  # Private Functions - The Receive Loop
  # ============================================================================

  # TODO: Implement the main receive loop
  # This function should:
  # 1. receive messages and handle each type
  # 2. Call itself recursively with updated state
  # 3. Handle: check_request, get_count, get_remaining, reset, stop, :tick (auto-reset)
  #
  # State should be a map with: %{limit: integer, count: integer, window_ms: integer}
  #
  # Example structure:
  #
  # defp loop(state) do
  #   receive do
  #     {:check_request, caller} ->
  #       # Check if under limit, update count, send response
  #       loop(new_state)
  #
  #     {:get_count, caller} ->
  #       # Send current count back to caller
  #       loop(state)
  #
  #     :tick ->
  #       # Reset counter, schedule next tick
  #       loop(reset_state)
  #
  #     :stop ->
  #       :ok  # Don't recurse - process terminates
  #   end
  # end
end

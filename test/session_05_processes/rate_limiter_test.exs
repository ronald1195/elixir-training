defmodule Session05.RateLimiterTest do
  use ExUnit.Case, async: true
  @moduletag :pending

  alias Session05.RateLimiter

  describe "start_link/1" do
    test "starts a rate limiter process" do
      assert {:ok, pid} = RateLimiter.start_link(limit: 5, window_ms: 1000)
      assert is_pid(pid)
      assert Process.alive?(pid)
      RateLimiter.stop(pid)
    end

    test "requires limit option" do
      assert_raise KeyError, fn ->
        RateLimiter.start_link(window_ms: 1000)
      end
    end

    test "uses default window_ms of 1000 if not specified" do
      assert {:ok, pid} = RateLimiter.start_link(limit: 5)
      assert Process.alive?(pid)
      RateLimiter.stop(pid)
    end
  end

  describe "check_request/1" do
    test "allows requests under the limit" do
      {:ok, pid} = RateLimiter.start_link(limit: 3, window_ms: 60_000)

      assert {:ok, 2} = RateLimiter.check_request(pid)
      assert {:ok, 1} = RateLimiter.check_request(pid)
      assert {:ok, 0} = RateLimiter.check_request(pid)

      RateLimiter.stop(pid)
    end

    test "rejects requests over the limit" do
      {:ok, pid} = RateLimiter.start_link(limit: 2, window_ms: 60_000)

      assert {:ok, 1} = RateLimiter.check_request(pid)
      assert {:ok, 0} = RateLimiter.check_request(pid)
      assert {:error, :rate_limited} = RateLimiter.check_request(pid)
      assert {:error, :rate_limited} = RateLimiter.check_request(pid)

      RateLimiter.stop(pid)
    end

    test "returns correct remaining count" do
      {:ok, pid} = RateLimiter.start_link(limit: 5, window_ms: 60_000)

      assert {:ok, 4} = RateLimiter.check_request(pid)
      assert {:ok, 3} = RateLimiter.check_request(pid)
      assert {:ok, 2} = RateLimiter.check_request(pid)

      RateLimiter.stop(pid)
    end

    test "handles limit of 1" do
      {:ok, pid} = RateLimiter.start_link(limit: 1, window_ms: 60_000)

      assert {:ok, 0} = RateLimiter.check_request(pid)
      assert {:error, :rate_limited} = RateLimiter.check_request(pid)

      RateLimiter.stop(pid)
    end
  end

  describe "get_count/1" do
    test "returns 0 initially" do
      {:ok, pid} = RateLimiter.start_link(limit: 5, window_ms: 60_000)

      assert RateLimiter.get_count(pid) == 0

      RateLimiter.stop(pid)
    end

    test "returns correct count after requests" do
      {:ok, pid} = RateLimiter.start_link(limit: 5, window_ms: 60_000)

      RateLimiter.check_request(pid)
      assert RateLimiter.get_count(pid) == 1

      RateLimiter.check_request(pid)
      assert RateLimiter.get_count(pid) == 2

      RateLimiter.stop(pid)
    end

    test "count does not exceed limit" do
      {:ok, pid} = RateLimiter.start_link(limit: 2, window_ms: 60_000)

      RateLimiter.check_request(pid)
      RateLimiter.check_request(pid)
      RateLimiter.check_request(pid)
      RateLimiter.check_request(pid)

      # Count should still be 2, rejected requests don't increment
      assert RateLimiter.get_count(pid) == 2

      RateLimiter.stop(pid)
    end
  end

  describe "get_remaining/1" do
    test "returns full limit initially" do
      {:ok, pid} = RateLimiter.start_link(limit: 5, window_ms: 60_000)

      assert RateLimiter.get_remaining(pid) == 5

      RateLimiter.stop(pid)
    end

    test "decreases after requests" do
      {:ok, pid} = RateLimiter.start_link(limit: 5, window_ms: 60_000)

      RateLimiter.check_request(pid)
      assert RateLimiter.get_remaining(pid) == 4

      RateLimiter.check_request(pid)
      assert RateLimiter.get_remaining(pid) == 3

      RateLimiter.stop(pid)
    end

    test "returns 0 when limit reached" do
      {:ok, pid} = RateLimiter.start_link(limit: 2, window_ms: 60_000)

      RateLimiter.check_request(pid)
      RateLimiter.check_request(pid)

      assert RateLimiter.get_remaining(pid) == 0

      RateLimiter.stop(pid)
    end
  end

  describe "reset/1" do
    test "resets the counter to 0" do
      {:ok, pid} = RateLimiter.start_link(limit: 5, window_ms: 60_000)

      RateLimiter.check_request(pid)
      RateLimiter.check_request(pid)
      assert RateLimiter.get_count(pid) == 2

      RateLimiter.reset(pid)
      assert RateLimiter.get_count(pid) == 0

      RateLimiter.stop(pid)
    end

    test "allows new requests after reset" do
      {:ok, pid} = RateLimiter.start_link(limit: 2, window_ms: 60_000)

      RateLimiter.check_request(pid)
      RateLimiter.check_request(pid)
      assert {:error, :rate_limited} = RateLimiter.check_request(pid)

      RateLimiter.reset(pid)
      assert {:ok, 1} = RateLimiter.check_request(pid)

      RateLimiter.stop(pid)
    end

    test "returns :ok" do
      {:ok, pid} = RateLimiter.start_link(limit: 5, window_ms: 60_000)

      assert RateLimiter.reset(pid) == :ok

      RateLimiter.stop(pid)
    end
  end

  describe "stop/1" do
    test "terminates the process" do
      {:ok, pid} = RateLimiter.start_link(limit: 5, window_ms: 60_000)
      assert Process.alive?(pid)

      RateLimiter.stop(pid)
      # Give it a moment to terminate
      Process.sleep(10)
      refute Process.alive?(pid)
    end

    test "returns :ok" do
      {:ok, pid} = RateLimiter.start_link(limit: 5, window_ms: 60_000)

      assert RateLimiter.stop(pid) == :ok
    end
  end

  describe "automatic window reset" do
    test "resets counter after window expires" do
      {:ok, pid} = RateLimiter.start_link(limit: 2, window_ms: 50)

      RateLimiter.check_request(pid)
      RateLimiter.check_request(pid)
      assert {:error, :rate_limited} = RateLimiter.check_request(pid)

      # Wait for window to reset
      Process.sleep(100)

      # Should be able to make requests again
      assert {:ok, 1} = RateLimiter.check_request(pid)

      RateLimiter.stop(pid)
    end

    test "resets count after window even without requests" do
      {:ok, pid} = RateLimiter.start_link(limit: 5, window_ms: 50)

      RateLimiter.check_request(pid)
      RateLimiter.check_request(pid)
      assert RateLimiter.get_count(pid) == 2

      # Wait for reset
      Process.sleep(100)

      assert RateLimiter.get_count(pid) == 0

      RateLimiter.stop(pid)
    end
  end

  describe "concurrent usage" do
    test "handles multiple concurrent requests" do
      {:ok, pid} = RateLimiter.start_link(limit: 100, window_ms: 60_000)

      # Spawn 50 tasks that each make 2 requests
      tasks =
        for _ <- 1..50 do
          Task.async(fn ->
            RateLimiter.check_request(pid)
            RateLimiter.check_request(pid)
          end)
        end

      Task.await_many(tasks)

      # All 100 requests should have been counted
      assert RateLimiter.get_count(pid) == 100

      RateLimiter.stop(pid)
    end

    test "correctly rate limits under concurrent load" do
      {:ok, pid} = RateLimiter.start_link(limit: 10, window_ms: 60_000)

      # Spawn 20 tasks that each try to make a request
      tasks =
        for _ <- 1..20 do
          Task.async(fn ->
            RateLimiter.check_request(pid)
          end)
        end

      results = Task.await_many(tasks)

      # Exactly 10 should succeed, 10 should fail
      successes = Enum.count(results, &match?({:ok, _}, &1))
      failures = Enum.count(results, &match?({:error, :rate_limited}, &1))

      assert successes == 10
      assert failures == 10

      RateLimiter.stop(pid)
    end
  end
end

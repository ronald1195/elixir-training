defmodule Session06.CreditLimitCacheTest do
  use ExUnit.Case, async: true
  @moduletag :pending

  alias Session06.CreditLimitCache

  describe "start_link/1" do
    test "starts the cache process" do
      assert {:ok, pid} = CreditLimitCache.start_link()
      assert is_pid(pid)
      assert Process.alive?(pid)
    end

    test "accepts ttl_ms option" do
      assert {:ok, pid} = CreditLimitCache.start_link(ttl_ms: 5000)
      assert Process.alive?(pid)
    end

    test "accepts name option" do
      assert {:ok, _pid} = CreditLimitCache.start_link(name: :test_cache)
      # Can use the name to interact
      CreditLimitCache.put(:test_cache, "ACC-001", 1000)
      assert {:ok, 1000} = CreditLimitCache.get(:test_cache, "ACC-001")
    end
  end

  describe "get/2" do
    test "returns :miss for unknown keys" do
      {:ok, pid} = CreditLimitCache.start_link()
      assert CreditLimitCache.get(pid, "unknown") == :miss
    end

    test "returns {:ok, value} for existing keys" do
      {:ok, pid} = CreditLimitCache.start_link()
      CreditLimitCache.put(pid, "ACC-001", 5000)
      assert {:ok, 5000} = CreditLimitCache.get(pid, "ACC-001")
    end

    test "returns :miss for expired entries" do
      {:ok, pid} = CreditLimitCache.start_link(ttl_ms: 50)
      CreditLimitCache.put(pid, "ACC-001", 5000)
      assert {:ok, 5000} = CreditLimitCache.get(pid, "ACC-001")

      # Wait for expiration
      Process.sleep(100)

      assert CreditLimitCache.get(pid, "ACC-001") == :miss
    end
  end

  describe "put/3" do
    test "stores a credit limit" do
      {:ok, pid} = CreditLimitCache.start_link()
      assert :ok = CreditLimitCache.put(pid, "ACC-001", 5000)
      assert {:ok, 5000} = CreditLimitCache.get(pid, "ACC-001")
    end

    test "overwrites existing entries" do
      {:ok, pid} = CreditLimitCache.start_link()
      CreditLimitCache.put(pid, "ACC-001", 5000)
      CreditLimitCache.put(pid, "ACC-001", 10000)
      assert {:ok, 10000} = CreditLimitCache.get(pid, "ACC-001")
    end

    test "handles multiple accounts" do
      {:ok, pid} = CreditLimitCache.start_link()
      CreditLimitCache.put(pid, "ACC-001", 5000)
      CreditLimitCache.put(pid, "ACC-002", 10000)
      CreditLimitCache.put(pid, "ACC-003", 15000)

      assert {:ok, 5000} = CreditLimitCache.get(pid, "ACC-001")
      assert {:ok, 10000} = CreditLimitCache.get(pid, "ACC-002")
      assert {:ok, 15000} = CreditLimitCache.get(pid, "ACC-003")
    end
  end

  describe "put/4 with custom TTL" do
    test "uses custom TTL" do
      {:ok, pid} = CreditLimitCache.start_link(ttl_ms: 60_000)

      # This entry has short TTL
      CreditLimitCache.put(pid, "ACC-001", 5000, ttl_ms: 50)

      assert {:ok, 5000} = CreditLimitCache.get(pid, "ACC-001")

      Process.sleep(100)

      assert CreditLimitCache.get(pid, "ACC-001") == :miss
    end

    test "entries with different TTLs expire independently" do
      {:ok, pid} = CreditLimitCache.start_link(ttl_ms: 60_000)

      CreditLimitCache.put(pid, "ACC-001", 5000, ttl_ms: 50)
      CreditLimitCache.put(pid, "ACC-002", 10000, ttl_ms: 200)

      Process.sleep(100)

      # First should be expired, second should still be valid
      assert CreditLimitCache.get(pid, "ACC-001") == :miss
      assert {:ok, 10000} = CreditLimitCache.get(pid, "ACC-002")
    end
  end

  describe "delete/2" do
    test "removes an entry" do
      {:ok, pid} = CreditLimitCache.start_link()
      CreditLimitCache.put(pid, "ACC-001", 5000)
      assert {:ok, 5000} = CreditLimitCache.get(pid, "ACC-001")

      assert :ok = CreditLimitCache.delete(pid, "ACC-001")
      assert CreditLimitCache.get(pid, "ACC-001") == :miss
    end

    test "returns :ok for non-existent keys" do
      {:ok, pid} = CreditLimitCache.start_link()
      assert :ok = CreditLimitCache.delete(pid, "unknown")
    end

    test "only removes the specified entry" do
      {:ok, pid} = CreditLimitCache.start_link()
      CreditLimitCache.put(pid, "ACC-001", 5000)
      CreditLimitCache.put(pid, "ACC-002", 10000)

      CreditLimitCache.delete(pid, "ACC-001")

      assert CreditLimitCache.get(pid, "ACC-001") == :miss
      assert {:ok, 10000} = CreditLimitCache.get(pid, "ACC-002")
    end
  end

  describe "stats/1" do
    test "tracks hits" do
      {:ok, pid} = CreditLimitCache.start_link()
      CreditLimitCache.put(pid, "ACC-001", 5000)

      CreditLimitCache.get(pid, "ACC-001")
      CreditLimitCache.get(pid, "ACC-001")

      stats = CreditLimitCache.stats(pid)
      assert stats.hits == 2
    end

    test "tracks misses" do
      {:ok, pid} = CreditLimitCache.start_link()

      CreditLimitCache.get(pid, "unknown-1")
      CreditLimitCache.get(pid, "unknown-2")
      CreditLimitCache.get(pid, "unknown-3")

      stats = CreditLimitCache.stats(pid)
      assert stats.misses == 3
    end

    test "tracks sets" do
      {:ok, pid} = CreditLimitCache.start_link()

      CreditLimitCache.put(pid, "ACC-001", 5000)
      CreditLimitCache.put(pid, "ACC-002", 10000)
      # Update
      CreditLimitCache.put(pid, "ACC-001", 7500)

      stats = CreditLimitCache.stats(pid)
      assert stats.sets == 3
    end

    test "tracks current size" do
      {:ok, pid} = CreditLimitCache.start_link()

      CreditLimitCache.put(pid, "ACC-001", 5000)
      CreditLimitCache.put(pid, "ACC-002", 10000)

      stats = CreditLimitCache.stats(pid)
      assert stats.size == 2

      CreditLimitCache.delete(pid, "ACC-001")

      stats = CreditLimitCache.stats(pid)
      assert stats.size == 1
    end

    test "starts with zero stats" do
      {:ok, pid} = CreditLimitCache.start_link()

      stats = CreditLimitCache.stats(pid)
      assert stats == %{hits: 0, misses: 0, sets: 0, size: 0}
    end
  end

  describe "clear/1" do
    test "removes all entries" do
      {:ok, pid} = CreditLimitCache.start_link()

      CreditLimitCache.put(pid, "ACC-001", 5000)
      CreditLimitCache.put(pid, "ACC-002", 10000)
      CreditLimitCache.put(pid, "ACC-003", 15000)

      assert :ok = CreditLimitCache.clear(pid)

      assert CreditLimitCache.get(pid, "ACC-001") == :miss
      assert CreditLimitCache.get(pid, "ACC-002") == :miss
      assert CreditLimitCache.get(pid, "ACC-003") == :miss
    end

    test "resets size to 0" do
      {:ok, pid} = CreditLimitCache.start_link()

      CreditLimitCache.put(pid, "ACC-001", 5000)
      CreditLimitCache.put(pid, "ACC-002", 10000)

      CreditLimitCache.clear(pid)

      stats = CreditLimitCache.stats(pid)
      assert stats.size == 0
    end
  end

  describe "entries/1" do
    test "returns all current entries" do
      {:ok, pid} = CreditLimitCache.start_link()

      CreditLimitCache.put(pid, "ACC-001", 5000)
      CreditLimitCache.put(pid, "ACC-002", 10000)

      entries = CreditLimitCache.entries(pid)
      assert entries == %{"ACC-001" => 5000, "ACC-002" => 10000}
    end

    test "returns empty map when empty" do
      {:ok, pid} = CreditLimitCache.start_link()
      assert CreditLimitCache.entries(pid) == %{}
    end

    test "excludes expired entries" do
      {:ok, pid} = CreditLimitCache.start_link(ttl_ms: 50)

      CreditLimitCache.put(pid, "ACC-001", 5000)

      Process.sleep(100)

      # Should not include expired entry
      assert CreditLimitCache.entries(pid) == %{}
    end
  end

  describe "automatic cleanup" do
    test "removes expired entries periodically" do
      {:ok, pid} =
        CreditLimitCache.start_link(
          ttl_ms: 30,
          cleanup_interval_ms: 50
        )

      CreditLimitCache.put(pid, "ACC-001", 5000)
      CreditLimitCache.put(pid, "ACC-002", 10000)

      # Entries should exist initially
      stats = CreditLimitCache.stats(pid)
      assert stats.size == 2

      # Wait for TTL and cleanup
      Process.sleep(100)

      # Entries should be cleaned up
      stats = CreditLimitCache.stats(pid)
      assert stats.size == 0
    end
  end
end

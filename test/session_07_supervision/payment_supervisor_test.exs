defmodule Session07.PaymentSupervisorTest do
  use ExUnit.Case, async: false
  @moduletag :pending

  alias Session07.PaymentSupervisor

  setup do
    # Ensure supervisor is stopped before each test
    case Process.whereis(PaymentSupervisor) do
      nil -> :ok
      pid -> Supervisor.stop(pid)
    end

    :ok
  end

  describe "start_link/1" do
    test "starts the supervisor" do
      assert {:ok, pid} = PaymentSupervisor.start_link([])
      assert is_pid(pid)
      assert Process.alive?(pid)
    end

    test "starts all children" do
      {:ok, _pid} = PaymentSupervisor.start_link([])

      children = PaymentSupervisor.children_info()
      assert length(children) == 4
    end

    test "registers with module name" do
      {:ok, pid} = PaymentSupervisor.start_link([])
      assert Process.whereis(PaymentSupervisor) == pid
    end
  end

  describe "children_info/0" do
    test "returns information about all children" do
      {:ok, _pid} = PaymentSupervisor.start_link([])

      children = PaymentSupervisor.children_info()

      # Should have 4 children: cache, rate_limiter, payment_processor, notifier
      assert length(children) == 4

      # Each child should be a tuple with {id, pid, type, modules}
      child_ids = Enum.map(children, fn {id, _pid, _type, _modules} -> id end)
      assert :cache in child_ids or Session07.Cache in child_ids
    end

    test "all children are workers" do
      {:ok, _pid} = PaymentSupervisor.start_link([])

      children = PaymentSupervisor.children_info()

      Enum.each(children, fn {_id, _pid, type, _modules} ->
        assert type == :worker
      end)
    end
  end

  describe "count_children/0" do
    test "counts active children" do
      {:ok, _pid} = PaymentSupervisor.start_link([])

      counts = PaymentSupervisor.count_children()

      assert counts.active == 4
      assert counts.specs == 4
      assert counts.workers == 4
      assert counts.supervisors == 0
    end
  end

  describe "get_child_pid/1" do
    test "returns the PID of a child by ID" do
      {:ok, _pid} = PaymentSupervisor.start_link([])

      cache_pid = PaymentSupervisor.get_child_pid(:cache)
      assert is_pid(cache_pid)
      assert Process.alive?(cache_pid)
    end

    test "returns nil for unknown child" do
      {:ok, _pid} = PaymentSupervisor.start_link([])

      assert PaymentSupervisor.get_child_pid(:unknown) == nil
    end
  end

  describe "restart_child/1" do
    test "restarts a child and returns new PID" do
      {:ok, _pid} = PaymentSupervisor.start_link([])

      old_pid = PaymentSupervisor.get_child_pid(:cache)
      assert {:ok, new_pid} = PaymentSupervisor.restart_child(:cache)

      assert is_pid(new_pid)
      assert old_pid != new_pid
      assert Process.alive?(new_pid)
    end

    test "restarted child is functional" do
      {:ok, _pid} = PaymentSupervisor.start_link([])

      # Use the cache
      Session07.Cache.put(:test_key, "value")
      assert Session07.Cache.get(:test_key) == "value"

      # Restart it
      {:ok, _new_pid} = PaymentSupervisor.restart_child(:cache)

      # State should be reset (fresh start)
      assert Session07.Cache.get(:test_key) == nil
    end
  end

  describe "automatic restart on crash" do
    test "restarts a crashed child" do
      {:ok, _pid} = PaymentSupervisor.start_link([])

      old_pid = PaymentSupervisor.get_child_pid(:cache)
      Process.exit(old_pid, :kill)

      # Give supervisor time to restart
      Process.sleep(50)

      new_pid = PaymentSupervisor.get_child_pid(:cache)
      assert is_pid(new_pid)
      assert new_pid != old_pid
      assert Process.alive?(new_pid)
    end

    test "child count remains the same after crash" do
      {:ok, _pid} = PaymentSupervisor.start_link([])

      assert PaymentSupervisor.count_children().active == 4

      # Kill a child
      cache_pid = PaymentSupervisor.get_child_pid(:cache)
      Process.exit(cache_pid, :kill)

      Process.sleep(50)

      # Should still have 4 active children
      assert PaymentSupervisor.count_children().active == 4
    end
  end

  describe "restart strategy" do
    test "uses rest_for_one or one_for_one strategy" do
      # This test verifies that the supervisor restarts dependent children
      # when using rest_for_one, or just the crashed child with one_for_one
      {:ok, _pid} = PaymentSupervisor.start_link([])

      # Get all PIDs
      cache_pid = PaymentSupervisor.get_child_pid(:cache)
      processor_pid = PaymentSupervisor.get_child_pid(:payment_processor)

      # Kill the cache (early in the start order)
      Process.exit(cache_pid, :kill)
      Process.sleep(50)

      # Cache should be restarted
      new_cache_pid = PaymentSupervisor.get_child_pid(:cache)
      assert new_cache_pid != cache_pid

      # The strategy determines if processor also restarts
      # Either way, processor should be alive
      new_processor_pid = PaymentSupervisor.get_child_pid(:payment_processor)
      assert Process.alive?(new_processor_pid)
    end
  end

  describe "children are started in correct order" do
    test "cache is available when processor starts" do
      {:ok, _pid} = PaymentSupervisor.start_link([])

      # If children start in wrong order, this might fail
      # because processor would try to use cache before it's ready
      cache_pid = PaymentSupervisor.get_child_pid(:cache)
      processor_pid = PaymentSupervisor.get_child_pid(:payment_processor)

      assert Process.alive?(cache_pid)
      assert Process.alive?(processor_pid)
    end
  end

  describe "children are functional" do
    test "cache can store and retrieve values" do
      {:ok, _pid} = PaymentSupervisor.start_link([])

      assert :ok = Session07.Cache.put(:key, "value")
      assert Session07.Cache.get(:key) == "value"
    end

    test "rate limiter can check requests" do
      {:ok, _pid} = PaymentSupervisor.start_link([])

      assert {:ok, _remaining} = Session07.RateLimiter.check("client-1")
    end

    test "payment processor can process payments" do
      {:ok, _pid} = PaymentSupervisor.start_link([])

      assert {:ok, 1} = Session07.PaymentProcessor.process(%{amount: 100})
      assert {:ok, 2} = Session07.PaymentProcessor.process(%{amount: 200})
    end

    test "notifier can send notifications" do
      {:ok, _pid} = PaymentSupervisor.start_link([])

      assert {:ok, 1} = Session07.Notifier.notify("Payment received")
    end
  end
end

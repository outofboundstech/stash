defmodule Stack.RegistryTest do
  use ExUnit.Case, async: true

  setup context do
    {:ok, registry} = Stash.Registry.start_link(context.test)
    {:ok, registry: registry}
  end

  test "spawns buckets", %{registry: registry} do
    assert Stash.Registry.lookup(registry, "shopping") == :error

    {:ok, pid} = Stash.Registry.create(registry, "shopping")
    assert {:ok, bucket} = Stash.Registry.lookup(registry, "shopping")
    assert bucket == pid

    {:ok, check} = Stash.Registry.create(registry, "shopping")
    assert check == pid

    assert Stash.Bucket.put(bucket, "milk", 1) == nil
    assert Stash.Bucket.get(bucket, "milk") == 1
  end

  test "removes bucket on exit", %{registry: registry} do
    Stash.Registry.create(registry, "shopping")
    {:ok, bucket} = Stash.Registry.lookup(registry, "shopping")
    Agent.stop(bucket)
    assert Stash.Registry.lookup(registry, "shopping") == :error
  end

  test "removes bucket on crash", %{registry: registry} do
    Stash.Registry.create(registry, "shopping")
    {:ok, bucket} = Stash.Registry.lookup(registry, "shopping")

    # Stop the bucket with a non-normal reason
    Process.exit(bucket, :shutdown)

    # Wait until the bucket is dead
    ref = Process.monitor(bucket)
    assert_receive {:DOWN, ^ref, _, _, _}

    assert Stash.Registry.lookup(registry, "shopping") == :error
  end
end

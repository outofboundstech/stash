defmodule Stash.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = Stash.Bucket.start_link
    {:ok, bucket: bucket}
  end

  test "stores values by key", %{bucket: bucket} do
    assert Stash.Bucket.get(bucket, "milk") == nil

    Stash.Bucket.set(bucket, "milk", 3)
    assert Stash.Bucket.get(bucket, "milk") == 3
    assert Stash.Bucket.put(bucket, "milk", 2) == 3
    assert Stash.Bucket.delete(bucket, "milk") == 2
    assert Stash.Bucket.get(bucket, "milk") == nil

    assert Stash.Bucket.get(bucket, "eggs") == nil
    assert Stash.Bucket.put(bucket, "eggs", 9) == nil
    assert Stash.Bucket.delete(bucket, "eggs") == 9
  end
end

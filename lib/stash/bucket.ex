defmodule Stash.Bucket do
  @doc """
  Starts a new bucket
  """
  def start_link do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Gets a value from the `bucket` bu `key`.
  """
  def get(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
  end

  @doc """
  Sets the `value` for the given `key` in the `bucket`.
  """
  def set(bucket, key, value) do
    # Consider returning the original (replaced) value if it existed, i.e.
    # {:ok, "original"} or {:ok, nil}
    Agent.update(bucket, &Map.put(&1, key, value))
  end

  @doc """
  Puts the `value` for the given `key` in the `bucket`.

  Returns the current value of `key`, if `key` exists.
  """
  def put(bucket, key, value) do
    # Consider returning the original (replaced) value if it existed, i.e.
    # {:ok, "original"} or {:ok, nil}
    Agent.get_and_update(bucket, &Map.get_and_update(&1, key, fn current -> {current, value} end))
  end

  @doc """
  Deletes `key` from `bucket`.

  Returns the current value of `key`, if `key` exists.
  """
  def delete(bucket, key) do
    Agent.get_and_update(bucket, &Map.pop(&1, key))
  end

end

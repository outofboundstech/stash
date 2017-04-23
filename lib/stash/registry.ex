defmodule Stash.Registry do
  use GenServer

  @server Application.get_env(:stash, :registry_name)

  ## Client API

  def stop, do: stop(@server)
  def start_link, do: start_link(@server)
  def lookup(name), do: lookup(@server, name)
  def create(name), do: create(@server, name)

  @doc """
  Stops the registry.
  """
  def stop(server) do
    GenServer.stop(server)
  end

  @doc """
  Starts the registry.
  """
  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @doc """
  Ensures there is a  bucket associated with the given `name` in `server`.
  """
  def create(server, name) do
    # GenServer.cast(server, {:create, name})
    GenServer.call(server, {:create, name})
  end

  ## Server Callbacks

  def init(:ok) do
    names = %{}
    refs = %{}
    {:ok, {names, refs}}
  end

  def handle_call({:lookup, name}, _from, {names, _} = state) do
    {:reply, Map.fetch(names, name), state}
  end

  def handle_call({:create, name}, _from, {names, refs}) do
    case Map.get(names, name) do
      nil ->
        {:ok, pid} = Stash.Bucket.Supervisor.start_bucket
        ref = Process.monitor(pid)
        refs = Map.put(refs, ref, name)
        names = Map.put(names, name, pid)
        {:reply, {:ok, pid}, {names, refs}}

      bucket ->
        {:reply, {:ok, bucket}, {names, refs}}
    end
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)
    {:noreply, {names, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

end

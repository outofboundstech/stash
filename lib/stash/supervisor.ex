defmodule Stash.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(Stash.Registry, []),
      supervisor(Stash.Bucket.Supervisor, [])
    ]

    supervise(children, strategy: :rest_for_one)
  end
end

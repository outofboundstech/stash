defmodule Stash do
  use Application

  def start(_type, _args) do
    Stash.Supervisor.start_link
  end
end

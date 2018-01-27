defmodule Lobby.LobbySupervisor do
  use Supervisor
  alias Lobby.Lobby

  def start_link(_options) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end
  def create_lobby(name) do
    Supervisor.start_link(__MODULE__, name)    
  end
  def join_lobby(owner, name) do
    Lobby.join(pid_from_owner(owner), name)
  end
  def join_lobby(name) do
    [first | _lobbies] =
      Supervisor.which_children(__MODULE__)
    join_lobby(owner.owner, name)
  end
  def init(:ok) do
    Supervisor.init([Lobby], strategy: :simple_one_for_one)
  end
  defp pid_from_owner(owner) do
    owner
    |> Lobby.via_tuple()
    |> Genserver.whereis()
  end

end
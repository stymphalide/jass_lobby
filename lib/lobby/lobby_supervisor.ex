defmodule Lobby.LobbySupervisor do
  use Supervisor
  alias Lobby.Lobby

  def start_link(_options) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end
  def join(name) do
    case Supervisor.which_children(__MODULE__) do
      [] ->
        create_lobby(name)
      [{_id, lobby, _type, _modules} | _lobbies] ->
        join_lobby(lobby, name)
    end
      
  end
  def join(owner, name) when is_binary(owner) do
    Lobby.join(pid_from_owner(owner), name)
  end

  def init(:ok) do
    Supervisor.init([Lobby], strategy: :simple_one_for_one)
  end

  defp join_lobby(lobby, name) do
    case Lobby.join(lobby, name) do
      {:ok, updated_lobby} ->
        updated_lobby
      msg ->
        msg
    end
    
  end
  defp create_lobby(name) do
    Supervisor.start_child(__MODULE__, [name])    
  end
  
  defp pid_from_owner(owner) do
    owner
    |> Lobby.via_tuple()
    |> GenServer.whereis()
  end

end
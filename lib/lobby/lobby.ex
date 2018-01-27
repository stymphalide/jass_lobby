defmodule Lobby.Lobby do
  defstruct [:max_size, :owner, :players, :status]
  use GenServer, start: {__MODULE__, :start_link, []}, restart: :transient

  def via_tuple(name) do
    {:via, Registry, {Registry.Lobby, name}}
  end

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end
  def join(lobby, name) do
    GenServer.call(lobby, {:join, name})
  end

  def init(name) do
    send(self(), {:create_lobby, name})
    {:ok, name}
  end
  def handle_info({:create_lobby, name}) do
    lobby = create_lobby(name)
    {:noreply, lobby}
  end
  def handle_call({:join, name}, _from, lobby) do
    case join_lobby(lobby, name) do
      {:ok, updated_lobby} ->
        {:reply, "joined successfully", updated_lobby}
      :error ->
        {:reply, "Lobby is full!"}
    end
  end

  defp create_lobby(name) do
    %Lobby{max_size: 4, owner: name, players: [name]. status: :open}
  end
  defp join_lobby(%Lobby{status: :open} = lobby, name) do
    lobby = 
      %Lobby{lobby | players [name | lobby.players]}
      |> get_status()
    {:ok, lobby}
  end
  defp join_lobby(%Lobby{status: :closed} = lobby, _name) do
    :error
  end
  defp get_status(%Lobby{max_size: max_size, players: names} = lobby) when length(names) == max_size do
    %Lobby{lobby | status: :closed}
  end
  defp get_status(%Lobby{} = lobby) do
    lobby
  end
end
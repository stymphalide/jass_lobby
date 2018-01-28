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
  def handle_info({:create_lobby, name}, _state_data) do
    lobby = 
      case :ets.lookup(:lobby, name) do
        [] ->
          create_lobby(name)
        [{_key, new_lobby}] -> 
          new_lobby
      end
    :ets.insert(:lobby, {name, lobby})
    {:noreply, lobby}
  end
  def handle_call({:join, name}, _from, lobby) do
    case join_lobby(lobby, name) do
      :error ->
        {:reply, :error, lobby}
      {:ok, %__MODULE__{status: :closed} = new_lobby} ->
        :ets.delete(:lobby, new_lobby.owner)
        {:stop, :shutdown, {:closed, new_lobby.players}, new_lobby}
      {:ok, new_lobby} ->
        :ets.insert(:lobby, {new_lobby.owner, new_lobby})
        {:reply, {:open, new_lobby.players}, new_lobby}
    end
  end

  defp create_lobby(name) do
    %__MODULE__{max_size: 4, owner: name, players: [name], status: :open}
  end
  defp join_lobby(%__MODULE__{status: :open} = lobby, name) do
    lobby = 
      %__MODULE__{lobby | players: [name | lobby.players]}
      |> get_status()
    {:ok, lobby}
  end
  defp join_lobby(%__MODULE__{status: :closed}, _name) do
    :error
  end
  defp get_status(%__MODULE__{max_size: max_size, players: names} = lobby) when length(names) == max_size do
    %__MODULE__{lobby | status: :closed}
  end
  defp get_status(%__MODULE__{} = lobby) do
    lobby
  end
end
#  Listener GenServer

defmodule Listener do
  use GenServer

  #  CLIENT SIDE
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def update(listener_pid, args) do
    GenServer.call(listener_pid, {:update, args}, :infinity)
  end

  def get(listener_pid) do
    GenServer.call(listener_pid, {:get})
  end

  #  SERVER SIDE
  def init(:ok), do: {:ok, []}

  def handle_call({:get}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:update, args}, _from, state) do
    [num, fang_list] = args
    state = Map.put(state, num, fang_list)
    {:reply, state, state}
  end
end
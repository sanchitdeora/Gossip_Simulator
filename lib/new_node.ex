defmodule NewNode do
  use GenServer

  #  CLIENT SIDE
  def start_link(args, opts) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  def update(listener, args) do
    GenServer.call(listener, {:update, args}, :infinity)
  end

  def get(listener_pid) do
    GenServer.call(listener_pid, {:get})
  end

  #  SERVER SIDE
  def init(:gossip) do
    {:ok, %{:neighbors => [], :count => 0, :msg => ""}}
  end

  def handle_call({:get}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:update, args}, _from, state) do

  end
end

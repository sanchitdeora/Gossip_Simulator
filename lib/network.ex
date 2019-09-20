defmodule Network do
  use GenServer

  #  CLIENT SIDE
  def start_link(args, opts) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  def setNeighbors(server, args) do
    GenServer.cast(server, {:setNeighbors, args})
  end

  def getNeighbors(server) do
    GenServer.call(server, {:get})
  end

  def gossip(server, args) do
    GenServer.cast(server, {:gossip, args})
  end

  #  SERVER SIDE
  def init(:gossip) do
    {:ok, %{:neighbors => [], :count => 0, :msg => ""}}
  end

  def handle_call({:get}, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:setNeighbors, args}, state) do
    state = Map.replace!(state, :neighbors, args)
    IO.inspect(state)
    {:noreply, state}
  end

  def handle_cast({:gossip, args}, state) do
    {firstNode, message} = args
    IO.inspect(firstNode)

    count = Map.get(state, :count)
    count = count + 1
    state = Map.replace!(state, :count, count)
    IO.inspect(count)

    if count < 10 do

      neighbors = Map.get(state, :neighbors)
      IO.inspect(neighbors)

      nextNeighbor = Enum.random(neighbors)
      IO.inspect(nextNeighbor, label: "Next Neighbor")

      Network.gossip(nextNeighbor, {nextNeighbor, "MESSAGE"})
    end

    {:noreply, state}
  end
end

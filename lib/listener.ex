# Keeps tracks of all the Node Neighbors and Dead Nodes in the network

defmodule Listener do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def setNeighbors(server, args) do
    GenServer.cast(server, {:setNeighbors, args})
  end

  def updateNeighbors(server, args) do
    GenServer.cast(server, {:updateNeighbors, args})
  end

  def deleteCurrentNode(server, nodeName) do
    GenServer.cast(server, {:deleteCurrentNode, nodeName})
  end

  def gossipCompleted(server, nodeName) do
    GenServer.cast(server, {:gossipCompleted, nodeName})
  end

  def getState(server) do
    GenServer.call(server, {:getState}, :infinity)
  end

  def getDeadNodes(server) do
    # nodeName is passed
    GenServer.call(server, {:getDeadNodes}, :infinity)
  end

  def init(:ok) do
    {:ok, %{:deadNodes => [], :neighbors => %{}}}
  end

  def handle_cast({:setNeighbors, args}, state) do
    {nodeName, neighbors} = args
    neighborsList = Map.fetch!(state, :neighbors)
    neighborsList = Map.put(neighborsList, nodeName, neighbors)
    state = Map.replace!(state, :neighbors, neighborsList)
    {:noreply, state}
  end

  def handle_cast({:updateNeighbors, args}, state) do
    {nodeName, neighbors} = args
    neighborsList = Map.fetch!(state, :neighbors)
    currentNeighbors = Map.fetch!(neighborsList, nodeName)
    neighbors = currentNeighbors ++ neighbors
    neighborsList = Map.put(neighborsList, nodeName, neighbors)
    state = Map.replace!(state, :neighbors, neighborsList)
    {:noreply, state}
  end

  # termination for GOSSIP
  def handle_cast({:gossipCompleted, nodeName}, state) do
    neighborsList = Map.fetch!(state, :neighbors)
    deadNodes = Map.fetch!(state, :deadNodes)
    deadNodes = [nodeName | deadNodes]
    deadNodes = Enum.uniq(deadNodes)
    neighborsCount = Enum.count(Map.keys(neighborsList))

    if Enum.count(deadNodes) == neighborsCount - 1 do
      send(Main, {:done})
    end

    state = Map.replace!(state, :deadNodes, deadNodes)
    {:noreply, state}
  end

  # termination for PushSum
  def handle_cast({:deleteCurrentNode, nodeName}, state) do
    deadNodes = Map.fetch!(state, :deadNodes)
    if nodeName not in deadNodes do
      deadNodes = [nodeName | deadNodes]
      state = Map.replace!(state, :deadNodes, deadNodes)
      neighborsList = Map.fetch!(state, :neighbors)
      neighborsCount = Enum.count(Map.keys(neighborsList))

      if Enum.count(deadNodes) == neighborsCount do

        send(Main, {:done})
      end

      {:noreply, state}
    else
      {:noreply, state}
    end
  end

  def handle_call({:getDeadNodes}, _from, state) do
    {:reply, state[:deadNodes], state}
  end

  def handle_call({:getState}, _from, state) do
    {:reply, state, state}
  end
end

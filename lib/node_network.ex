defmodule NodeNetwork do
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

  def removeNeighbor(server, node_name) do
    GenServer.cast(server, {:removeNeighbor, node_name})
  end

  def getCount(server) do
    GenServer.call(server, {:getCount})
  end

  def gossip(server, args) do
    GenServer.cast(server, {:gossip, args})
  end

  #  SERVER SIDE
  def init(:gossip) do
    {:ok, %{:neighbors => [], :count => 0, :message => ""}}
  end

  def handle_call({:getCount}, _from, state) do
    count = Map.fetch!(state, :count)
    {:reply, count, state}
  end

  def handle_call({:get}, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:setNeighbors, args}, state) do
    state = Map.replace!(state, :neighbors, args)
    IO.inspect(state)
    {:noreply, state}
  end

  def handle_cast({:removeNeighbor, node_name}, state) do
    neighbors = Map.fetch!(state, :neighbors)
    neighbors = List.delete(neighbors, node_name)
    state = Map.replace!(state, :neighbors, neighbors)
    {:noreply, state}
  end

  def handle_cast({:gossip, args}, state) do
    {server, algorithm, message} = args
#    IO.inspect(server)

    count = Map.get(state, :count)
#    count = count + 1
#    state = Map.replace!(state, :count, count)
    IO.inspect([server | count])
    neighbors = Map.get(state, :neighbors)
#    IO.inspect(neighbors)

    if count < 10 do

      if neighbors == [] do
        IO.puts("No neighbors to reach")
        Listener.delete_me(MyListener, server)
        StartNetwork.start(algorithm)
        {:noreply, state}
      else

        nextNeighbor = Enum.random(neighbors)
        IO.inspect([server | nextNeighbor], label: "Next Neighbor")
        NodeNetwork.gossip(nextNeighbor, {nextNeighbor, algorithm, "MESSAGE"})

#        if count < 5 do
          NodeNetwork.gossip(server, {server, algorithm, "MESSAGE"})
#          else
#          IO.inspect(server, label: "Count > 5")
#        end

        state = Map.replace!(state, :message, message)
        {:noreply, Map.replace!(state, :count, count + 1)}
      end
    else
       IO.puts("I'm done #{server} || #{count}")
      # delete current node from all the neighbors list
      Enum.each(Map.get(state, :neighbors), fn neighbor_node ->
        NodeNetwork.removeNeighbor(neighbor_node, server)
      end)
       Listener.gossip_done(MyListener, server)
      {:noreply, state}
    end
  end
end


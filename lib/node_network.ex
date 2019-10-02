defmodule NodeNetwork do
  use GenServer

  #  CLIENT SIDE
  def start_link(args, opts) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  def updateNeighbors(server, args) do
    GenServer.cast(server, {:updateNeighbors, [server | args]})
  end

  def setNeighbors(server, args) do
    GenServer.cast(server, {:setNeighbors, [server | args]})
  end

  def getNeighbors(server) do
    GenServer.call(server, {:getNeighbors})
  end

  def getState(server) do
    GenServer.call(server, {:getState})
  end
  def die(server) do
    GenServer.cast(server, {:die, server})
  end
  def removeNeighbor(server, args) do
    GenServer.cast(server, {:removeNeighbor, [server | args]})
  end

  def getCount(server) do
    GenServer.call(server, {:getCount})
  end

  def gossip(server, args) do
    GenServer.cast(server, {:gossip, args})
  end

  def pushsum(server, args) do
    GenServer.cast(server, {:pushsum, args})
  end

  #  SERVER SIDE
  def init({:gossip, i}) do
    {:ok, %{:neighbors => [], :count => 0, :message => ""}}
  end

  def init({:pushsum, i}) do
    {:ok, %{:neighbors => [], :s => i, :w => 1, :queue => :queue.new()}}
  end

  def handle_call({:getCount}, _from, state) do
    count = Map.fetch!(state, :count)
    {:reply, count, state}
  end

  def handle_call({:getState}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:getNeighbors}, _from, state) do
    neighbors = Map.fetch!(state, :neighbors)
    {:reply, neighbors, state}
  end

  def handle_cast({:setNeighbors, args}, state) do
    [server | args] = args
    state = Map.replace!(state, :neighbors, args)
#    IO.inspect(state, label: "#{server}")
    {:noreply, state}
  end

  def handle_cast({:updateNeighbors, args}, state) do
    [server | nodeName] = args
    neighbors = Map.fetch!(state, :neighbors)
    neighbors = neighbors ++ [nodeName]
#    IO.inspect(neighbors, label: "#{server}")
    state = Map.replace!(state, :neighbors, neighbors)
    {:noreply, state}
  end

  def handle_cast({:removeNeighbor, args}, state) do
    [server | nodeName] = args
#    IO.inspect(nodeName, label: "INSIDE REMOVE NEIGHBOR for #{server} sent by ")
    neighbors = Map.fetch!(state, :neighbors)
    neighbors = List.delete(neighbors, nodeName)
    state = Map.replace!(state, :neighbors, neighbors)
#    IO.inspect([neighbors], label: "NEIGHBOR #{nodeName} REMOVED from #{server}")
    {:noreply, state}
  end

  def handle_cast({:die, server}, state) do
    neighbors = Map.fetch!(state, :neighbors)
    Enum.each(neighbors, fn neighbor ->
      NodeNetwork.removeNeighbor(neighbor, server)
    end)
    Listener.deleteCurrentNode(MyListener, server)
    {:noreply, state}
  end


  def handle_cast({:gossip, args}, state) do
    {server, algorithm, message} = args
#    IO.inspect(server)

    count = Map.get(state, :count)
#    count = count + 1
#    state = Map.replace!(state, :count, count)

    neighbors = Map.get(state, :neighbors)
#    IO.inspect(neighbors)
#    IO.inspect([count | [neighbors]], label: "#{server}")

    if count < 10 do

      if neighbors == [] do
#        IO.puts("No neighbors to reach")
        Listener.deleteCurrentNode(MyListener, server)
        StartNetwork.start(algorithm)
        {:noreply, state}
      else

        nextNeighbor = Enum.random(neighbors)
#        IO.inspect([server | nextNeighbor], label: "Next Neighbor")
        NodeNetwork.gossip(nextNeighbor, {nextNeighbor, algorithm, "MESSAGE"})

        if count < 5 do
#          state = Map.replace!(state, :count, (count - 1))
          NodeNetwork.gossip(server, {server, algorithm, "MESSAGE"})
#          {:noreply, state}
#          IO.inspect(server, label: "Count > 5")
        end

        state = Map.replace!(state, :message, message)
        {:noreply, Map.replace!(state, :count, count + 1)}
      end
    else
#      IO.inspect([count | [neighbors]], label: "I'm done #{server}")

      # delete current node from all the neighbors list
      Enum.each(Map.get(state, :neighbors), fn neighbor_node ->
#        IO.inspect([neighbor_node], label: "INSIDE ENUM.each for #{server}, Current Neighbor being")
        NodeNetwork.removeNeighbor(neighbor_node, server)
        NodeNetwork.removeNeighbor(server, neighbor_node)
      end)
#        state = Map.replace!(state, :neighbors, [])
       Listener.gossipCompleted(MyListener, server)

      if neighbors == [] do
#        IO.inspect(Map.get(state, :neighbors),label: "No neighbors to reach for #{server}!!!!!!!!!!!!!!!!!!!!!!!")
        Listener.deleteCurrentNode(MyListener, server)
        StartNetwork.start(algorithm)
        {:noreply, state}
      end

      {:noreply, state}
    end
  end

  def handle_cast({:pushsum, args}, state) do
    {server, new_s, new_w} = args
    neighbors = Map.get(state, :neighbors)
    # create a function for this repetitive thing
    s = Map.fetch!(state, :s)
    w = Map.fetch!(state, :w)

    # ratio from previous iteration
    old_ratio = s / w

    state = Map.replace!(state, :s, s + new_s)
    state = Map.replace!(state, :w, w + new_w)

    # storing half the updated s and w : Need to send and retain the same
    s_t = Map.fetch!(state, :s) / 2
    w_t = Map.fetch!(state, :w) / 2

    # creating queue to store the s/w
    queue = Map.fetch!(state, :queue)
    ratio = s_t / w_t
    ratio_diff = abs(ratio - old_ratio)

    # when the current node has no neighbors to communicate
    if neighbors == [] do
#      IO.inspect(Map.get(state, :neighbors),label: "No neighbors to reach for #{server}!!!!!!!!!!!!!!!!!!!!!!!")
      Listener.deleteCurrentNode(MyListener, server)
      StartNetwork.start(:pushsum)
      {:noreply, state}
    else
      if :queue.len(queue) == 3 do

        queue_list = :queue.to_list(queue)

        boolean_list =
          Enum.map(queue_list, fn i ->
            i <= 0.0000000001
          end)

        if boolean_list == [true, true, true] do
#          IO.inspect([s/w], label: "I'm done #{server}")
          # terminate

          next_neighbor = Enum.random(Map.get(state, :neighbors))
          NodeNetwork.pushsum(next_neighbor, {next_neighbor, s_t, w_t})
#          IO.inspect([[[next_neighbor]| [Map.fetch!(state, :s) / Map.fetch!(state, :w)]] | [Map.fetch!(state, :s) | Map.fetch!(state, :w)]] ,label: "ENDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD #{server}")
          Listener.deleteCurrentNode(MyListener, server)
          state = Map.replace!(state, :s, s_t)
          state = Map.replace!(state, :w, w_t)

#           delete current node from all the neighbors list
          Enum.each(neighbors, fn neighbor_node ->
            NodeNetwork.removeNeighbor(neighbor_node, server)
          end)

#           IO.inspect "I'm terminating"
          {:noreply, state}
        else
          state = Map.replace!(state, :s, s_t)
          state = Map.replace!(state, :w, w_t)
          next_neighbor = Enum.random(Map.get(state, :neighbors))
          {_, queue} = :queue.out(queue)
          queue = :queue.in(ratio_diff, queue)
          state = Map.replace!(state, :queue, queue)
          NodeNetwork.pushsum(next_neighbor, {next_neighbor, s_t, w_t})
#          IO.inspect([[[next_neighbor]| [Map.fetch!(state, :s) / Map.fetch!(state, :w)]] | [Map.fetch!(state, :s) | Map.fetch!(state, :w)]] ,label: "#{server}")
          {:noreply, state}
        end
      else
        state = Map.replace!(state, :s, s_t)
        state = Map.replace!(state, :w, w_t)
        next_neighbor = Enum.random(Map.get(state, :neighbors))
#        IO.inspect([next_neighbor| [Map.fetch!(state, :s) | Map.fetch!(state, :w)]] ,label: "#{server}")
        queue = :queue.in(ratio_diff, queue)
        state = Map.replace!(state, :queue, queue)
        NodeNetwork.pushsum(next_neighbor, {next_neighbor, s_t, w_t})
        {:noreply, state}
      end
    end
  end
end
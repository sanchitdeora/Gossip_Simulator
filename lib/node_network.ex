# Keeps track of the information for the Current Node

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

  def fail(server) do
    GenServer.cast(server, {:fail, server})
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
    {:noreply, state}
  end

  def handle_cast({:updateNeighbors, args}, state) do
    [server | nodeName] = args
    neighbors = Map.fetch!(state, :neighbors)
    neighbors = neighbors ++ [nodeName]
    state = Map.replace!(state, :neighbors, neighbors)
    {:noreply, state}
  end

  def handle_cast({:removeNeighbor, args}, state) do
    [server | nodeName] = args
    neighbors = Map.fetch!(state, :neighbors)
    neighbors = List.delete(neighbors, nodeName)
    state = Map.replace!(state, :neighbors, neighbors)
    {:noreply, state}
  end

  #
  def handle_cast({:fail, server}, state) do
    neighbors = Map.fetch!(state, :neighbors)
    Enum.each(neighbors, fn neighbor ->
      NodeNetwork.removeNeighbor(neighbor, server)
    end)
    Listener.deleteCurrentNode(MyListener, server)
    {:noreply, state}
  end

  # Gossip Initiated
  def handle_cast({:gossip, args}, state) do
    {server, algorithm, message} = args

    count = Map.get(state, :count)
    neighbors = Map.get(state, :neighbors)

    if count < 10 do

      # when the current node has no neighbors to communicate
      if neighbors == [] do
#        IO.puts("No neighbors to reach")
        Listener.deleteCurrentNode(MyListener, server)
        StartNetwork.start(algorithm)
        {:noreply, state}
      else

        # Selects Next neighbor at Random
        nextNeighbor = Enum.random(neighbors)
        NodeNetwork.gossip(nextNeighbor, {nextNeighbor, algorithm, "MESSAGE"})

        if count < 5 do
          NodeNetwork.gossip(server, {server, algorithm, "MESSAGE"})
        end

        state = Map.replace!(state, :message, message)
        {:noreply, Map.replace!(state, :count, count + 1)}
      end
    else

      # Delete current node from all the neighbors list
      Enum.each(Map.get(state, :neighbors), fn neighbor_node ->
        NodeNetwork.removeNeighbor(neighbor_node, server)
        NodeNetwork.removeNeighbor(server, neighbor_node)
      end)
      Listener.gossipCompleted(MyListener, server)

      if neighbors == [] do
        Listener.deleteCurrentNode(MyListener, server)
        StartNetwork.start(algorithm)
        {:noreply, state}
      end

      {:noreply, state}
    end
  end

  # Push-Sum Initiated
  def handle_cast({:pushsum, args}, state) do
    {server, new_s, new_w} = args
    neighbors = Map.get(state, :neighbors)
    s = Map.fetch!(state, :s)
    w = Map.fetch!(state, :w)

    old_ratio = s / w

    state = Map.replace!(state, :s, s + new_s)
    state = Map.replace!(state, :w, w + new_w)

    # storing half of the updated s and w
    s_t = Map.fetch!(state, :s) / 2
    w_t = Map.fetch!(state, :w) / 2

    # creating queue to store the s/w
    queue = Map.fetch!(state, :queue)
    ratio = s_t / w_t
    ratio_diff = abs(ratio - old_ratio)

    # when the current node has no neighbors to communicate
    if neighbors == [] do

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

        # terminates the node if true
        if boolean_list == [true, true, true] do

          next_neighbor = Enum.random(Map.get(state, :neighbors))
          NodeNetwork.pushsum(next_neighbor, {next_neighbor, s_t, w_t})
          Listener.deleteCurrentNode(MyListener, server)
          state = Map.replace!(state, :s, s_t)
          state = Map.replace!(state, :w, w_t)

          # delete current node from all the neighbors list
          Enum.each(neighbors, fn neighbor_node ->
            NodeNetwork.removeNeighbor(neighbor_node, server)
          end)
          {:noreply, state}

        else
          state = Map.replace!(state, :s, s_t)
          state = Map.replace!(state, :w, w_t)
          next_neighbor = Enum.random(Map.get(state, :neighbors))
          {_, queue} = :queue.out(queue)
          queue = :queue.in(ratio_diff, queue)
          state = Map.replace!(state, :queue, queue)
          NodeNetwork.pushsum(next_neighbor, {next_neighbor, s_t, w_t})
          {:noreply, state}
        end
      else
        state = Map.replace!(state, :s, s_t)
        state = Map.replace!(state, :w, w_t)
        next_neighbor = Enum.random(Map.get(state, :neighbors))
        queue = :queue.in(ratio_diff, queue)
        state = Map.replace!(state, :queue, queue)
        NodeNetwork.pushsum(next_neighbor, {next_neighbor, s_t, w_t})
        {:noreply, state}
      end

    end

  end

end
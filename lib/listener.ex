defmodule Listener do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def set_neighbors(server, args) do
    GenServer.cast(server, {:set_neighbors, args})
  end

  def update_neighbors(server, args) do
    GenServer.cast(server, {:update_neighbors, args})
  end

  def delete_me(server, node_name) do
    # node_name is passed
    GenServer.cast(server, {:delete_me, node_name})
  end

  def gossip_done(server, node_name) do
    # node_name is passed
    GenServer.cast(server, {:gossip_done, node_name})
  end

  def get_state(server) do
    GenServer.call(server, {:get_state}, :infinity)
  end

  def get_dead_nodes(server) do
    # node_name is passed
    GenServer.call(server, {:get_dead_nodes}, :infinity)
  end

  def init(:ok) do
    {:ok, %{:dead_nodes => [], :neighbors => %{}}}
  end

  def handle_cast({:set_neighbors, args}, state) do
    {node_name, node_neighbors} = args
    neighbors_list = Map.fetch!(state, :neighbors)
    neighbors_list = Map.put(neighbors_list, node_name, node_neighbors)
    state = Map.replace!(state, :neighbors, neighbors_list)
    {:noreply, state}
  end

  def handle_cast({:update_neighbors, args}, state) do
    {node_name, node_neighbors} = args
    neighbors_list = Map.fetch!(state, :neighbors)
    current_neighbors = Map.fetch!(neighbors_list, node_name)
    node_neighbors = current_neighbors ++ node_neighbors
    neighbors_list = Map.put(neighbors_list, node_name, node_neighbors)
    state = Map.replace!(state, :neighbors, neighbors_list)
    {:noreply, state}
  end

  # termination for GOSSIP
  def handle_cast({:gossip_done, node_name}, state) do
    neighbors_list = Map.fetch!(state, :neighbors)
    dead_nodes = Map.fetch!(state, :dead_nodes)
    dead_nodes = [node_name | dead_nodes]
    dead_nodes = Enum.uniq(dead_nodes)
#    IO.inspect(dead_nodes, label: "DEAD")
    neighbors_list_count = Enum.count(Map.keys(neighbors_list))
    # terminating when all the nodes are dead
    #    IO.inspect([[node_name | neighbors_list] | neighbors_list_count])
    if Enum.count(dead_nodes) == (neighbors_list_count - 1) do

#      IO.puts("ALL FINISHED!!")
      a = Map.keys(neighbors_list) -- dead_nodes |> List.first
      count = NodeNetwork.getCount(a)
      if(count > 5) do
        send(Main, {:done})
      else
        send(Main, {:incomplete})
      end

    end

    state = Map.replace!(state, :dead_nodes, dead_nodes)
    {:noreply, state}
  end

  # termination for PushSum
  def handle_cast({:delete_me, node_name}, state) do
    dead_nodes = Map.fetch!(state, :dead_nodes)
    # adding node name to dead nodes list
    if node_name not in dead_nodes do
      dead_nodes = [node_name | dead_nodes]
      state = Map.replace!(state, :dead_nodes, dead_nodes)
      neighbors_list = Map.fetch!(state, :neighbors)
      neighbors_list_count = Enum.count(Map.keys(neighbors_list))


      # terminating when all the nodes have terminated
      if Enum.count(dead_nodes) == neighbors_list_count do
        # Enum.each(dead_nodes, fn node ->
        #   state = NwNode.get_state(node)
        #   s = Map.fetch!(state, :s)
        #   w = Map.fetch!(state, :w)
        #   IO.inspect(s / w)
        # end)
        # IO.puts("All done!!")
        send(Main, {:done})
      end

      {:noreply, state}
    else
      {:noreply, state}
    end
  end

  def handle_call({:get_dead_nodes}, _from, state) do
    {:reply, state[:dead_nodes], state}
  end

  def handle_call({:get_state}, _from, state) do
    {:reply, state, state}
  end
end

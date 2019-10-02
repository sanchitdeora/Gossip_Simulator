defmodule God do
    use GenServer

    def start_link(opts) do
        GenServer.start_link(__MODULE__, :ok, opts)
    end

    def init(:ok) do
        {:ok, []}
    end

    def kill_nodes(server) do
        GenServer.cast(server, {:kill_nodes})
    end

    def handle_cast({:kill_nodes}, state) do
        :timer.sleep(:rand.uniform(500))
        IO.puts "Killing spree!!"
        data = Listener.get_state(MyListener)

#        IO.inspect(data, label: "God Kill Nodes")

        all_nodes = Map.keys(data[:neighbors])
#        IO.inspect(Enum.count(all_nodes), label: "allNodes")
        kill_ratio = 0.2
        num_nodes_to_kill = length(all_nodes) * kill_ratio |> trunc
        nodes_to_kill = Enum.map(0..num_nodes_to_kill-1, fn i->
            Enum.random(all_nodes)
        end)
        IO.inspect([nodes_to_kill], label: "Length #{Enum.count(nodes_to_kill)}, Nodes to kill")
        Enum.each(nodes_to_kill, fn node ->
            NodeNetwork.die(node)
        end)
        {:noreply, state}
    end
end
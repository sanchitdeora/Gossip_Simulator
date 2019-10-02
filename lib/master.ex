defmodule Master do
    use GenServer

    def start_link(opts) do
        GenServer.start_link(__MODULE__, :ok, opts)
    end

    def init(:ok) do
        {:ok, []}
    end

    def failNodes(server) do
        GenServer.cast(server, {:failNodes})
    end

    def handle_cast({:failNodes}, state) do
        :timer.sleep(:rand.uniform(500))
        IO.puts("Start Failing Nodes !!!")
        networkInfo = Listener.getState(MyListener)

#        IO.inspect(data, label: "Master Fail Nodes")

        allNodes = Map.keys(networkInfo[:neighbors])
        failFactor = 0.5

        toBeFailed = length(allNodes) * failFactor |> trunc
        failingNodes = Enum.map(0..toBeFailed-1, fn _i->
            Enum.random(allNodes)
        end)
        Enum.each(failingNodes, fn node ->
            NodeNetwork.die(node)
        end)
        {:noreply, state}
    end
end
# Master Actor

defmodule Master do
    use GenServer

    # CLIENT SIDE
    def start_link(opts) do
        GenServer.start_link(__MODULE__, :ok, opts)
    end

    def failNodes(server) do
        GenServer.cast(server, {:failNodes})
    end

    # SERVER SIDE
    def init(:ok) do
        {:ok, []}
    end

    def handle_cast({:failNodes}, state) do

        # Master sleeps for 0 - 1000ms after initiation, before it starts to fail nodes
        :timer.sleep(:rand.uniform(1000))
        IO.puts("Start Failing Nodes !!!")

        # Get the Network information from the Listener
        networkInfo = Listener.getState(MyListener)

#        IO.inspect(data, label: "Master Fail Nodes")

        allNodes = Map.keys(networkInfo[:neighbors])

        # failFactor decides the number of nodes to be failed in the network
        failFactor = 0.5
        toBeFailed = length(allNodes) * failFactor |> trunc

        # Nodes chosen to be failed at random
        failingNodes = Enum.map(0..toBeFailed-1, fn _i->
            Enum.random(allNodes)
        end)

        # Starting to fail nodes chosen
        Enum.each(failingNodes, fn node ->
            NodeNetwork.fail(node)
        end)
        {:noreply, state}
    end
end
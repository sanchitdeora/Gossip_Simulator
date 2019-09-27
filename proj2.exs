defmodule Proj2 do

  Process.register self(), Main

  numNodes = 5
  topology = :rand2D
  algorithm = :pushsum

#  {:ok, listener} = Listener.start_link([])

  Topology.createNetwork(numNodes, topology, algorithm)
#  supervisorId = SuperV
  StartNetwork.start(algorithm)

  receive do
    {:done} ->
        {_, t} = :erlang.statistics(:wall_clock)
        IO.puts "Time taken to complete #{algorithm} is #{t} milliseconds"
        IO.puts "Main is done"

        childNodes = Supervisor.which_children(SuperV)
        childNames =
          Enum.map(childNodes, fn currentNode ->
            {currentName, _, _, _} = currentNode
            currentName
#            count = NodeNetwork.getCount(currentName)
            neighbors = NodeNetwork.getNeighbors(currentName)
            state = NodeNetwork.getState(currentName)
            IO.inspect(currentName, label: "state")
            s = Map.fetch!(state, :s)
            w = Map.fetch!(state, :w)
            queue = Map.fetch!(state, :queue)
            IO.inspect([[neighbors] | (s/w)], label: "END #{currentName}")
          end)

    {:incomplete} -> IO.puts "Main is incomplete"
  end

end
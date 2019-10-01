defmodule Proj2 do

  Process.register self(), Main

  numNodes = 17
  topology = :randhoneycomb
  algorithm = :pushsum

#  {:ok, listener} = Listener.start_link([])

  Topology.createNetwork(numNodes, topology, algorithm)
  StartNetwork.start(algorithm)

  receive do
    {:done} ->
        {_, t} = :erlang.statistics(:wall_clock)
        IO.puts "Time taken to complete #{algorithm} is #{t} milliseconds"
        IO.puts "Main is done"

        childNodes = Supervisor.which_children(SuperV)

        Enum.map(childNodes, fn currentNode ->
          {currentName, _, _, _} = currentNode
          currentName

          neighbors = NodeNetwork.getNeighbors(currentName)

          case algorithm do
            :gossip ->
                count = NodeNetwork.getCount(currentName)
                IO.inspect([[neighbors] | count], label: "END #{currentName}")

            :pushsum ->
              state = NodeNetwork.getState(currentName)
#                IO.inspect(currentName, label: "state")
              s = Map.fetch!(state, :s)
              w = Map.fetch!(state, :w)
              queue = Map.fetch!(state, :queue)
              IO.inspect([[neighbors] | (s/w)], label: "END #{currentName}")

          end
        end)

    {:incomplete} -> IO.puts "Main is incomplete"
  end

end
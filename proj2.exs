defmodule Proj2 do

  Process.register self(), Main

  numNodes = 2000
  topology = :full
  algorithm = :gossip

#  {:ok, listener} = Listener.start_link([])
#  {:ok, god_pid} = God.start_link(name: God)

  Topology.createNetwork(numNodes, topology, algorithm)
  {_, t1} = :erlang.statistics(:wall_clock)
#  God.kill_nodes(god_pid)
    StartNetwork.start(algorithm)

  receive do
    {:done} ->
#
#
#        childNodes = Supervisor.which_children(SuperV)
#
#        Enum.map(childNodes, fn currentNode ->
#          {currentName, _, _, _} = currentNode
#          currentName
#
#          neighbors = NodeNetwork.getNeighbors(currentName)
#
#
#          case algorithm do
#            :gossip ->
#                count = NodeNetwork.getCount(currentName)
#                IO.inspect([[neighbors] | count], label: "END #{currentName}")
#
#            :pushsum ->
#              state = NodeNetwork.getState(currentName)
#                IO.inspect(state, label: "#{currentName}")
#              s = Map.fetch!(state, :s)
#              w = Map.fetch!(state, :w)
#              _queue = Map.fetch!(state, :queue)
#              IO.inspect([[neighbors] | (s/w)], label: "END #{currentName}")
#
#          end
#        end)
        {_, t2} = :erlang.statistics(:wall_clock)
        IO.puts "Time taken to complete #{algorithm} is #{t2 - t1} milliseconds"
        IO.puts "Main is done"

    {:incomplete} -> IO.puts "Main is incomplete"
  end

end
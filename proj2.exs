defmodule Proj2 do

  Process.register self(), Main

#  numNodes = 2000
#  topology = :full
#  algorithm = :pushsum
  [numNodes, topology, algorithm] = System.argv

  {numNodes, _} = Integer.parse(numNodes)
  topology = String.to_atom(topology)
  algorithm = String.to_atom(algorithm)

#  {:ok, master_pid} = Master.start_link(name: MyMaster)

  Topology.createNetwork(numNodes, topology, algorithm)
  {_, _t1} = :erlang.statistics(:wall_clock)
#  IO.puts "Time taken to complete #{algorithm} is #{t1} milliseconds"
#    Master.failNodes(master_pid)
    StartNetwork.start(algorithm)

  receive do
    {:done} ->

#        childNodes = Supervisor.which_children(SuperV)
#
#        Enum.map(childNodes, fn currentNode ->
#          {currentName, _, _, _} = currentNode
#          currentName
#
#          neighbors = NodeNetwork.getNeighbors(currentName)
#
#          case algorithm do
#            :pushsum ->
#              state = NodeNetwork.getState(currentName)
#              s = Map.fetch!(state, :s)
#              w = Map.fetch!(state, :w)
#              IO.inspect((s/w)], label: "Value of s/w for #{currentName}")
#
#          end
#        end)
        {_, t2} = :erlang.statistics(:wall_clock)
        IO.puts "Time taken to complete #{algorithm} is #{t2} milliseconds"
        IO.puts "Main is done"

    {:incomplete} -> IO.puts "Main is incomplete"
  end

end
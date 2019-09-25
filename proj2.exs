defmodule Proj2 do

  Process.register self(), Main
  numNodes = 5
  topology = :full
  algorithm = :gossip

#  {:ok, listener} = Listener.start_link([])

  Topology.createNetwork(numNodes, topology, algorithm)
#  supervisorId = SuperV
  StartNetwork.start(algorithm)

  receive do
    {:done} -> IO.puts "Main is done"
    {:incomplete} -> IO.puts "Main is incomplete"
  end

end
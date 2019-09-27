defmodule Proj2 do

  Process.register self(), Main
  numNodes = 5
  topology = :line
  algorithm = :gossip

#  {:ok, listener} = Listener.start_link([])

  Topology.createNetwork(numNodes, topology, algorithm)
#  supervisorId = SuperV
  StartNetwork.start(algorithm)

  receive do
    {:done} ->
        {_, t} = :erlang.statistics(:wall_clock)
        IO.puts "Time taken to complete #{algorithm} is #{t} milliseconds"
        IO.puts "Main is done"
    {:incomplete} -> IO.puts "Main is incomplete"
  end

end
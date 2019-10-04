defmodule Proj2 do

  Process.register self(), Main

  [numNodes, topology, algorithm] = System.argv

  {numNodes, _} = Integer.parse(numNodes)
  topology = String.to_atom(topology)
  algorithm = String.to_atom(algorithm)

  # Creates the Network according to the topology
  Topology.createNetwork(numNodes, topology, algorithm)
  {_, _t1} = :erlang.statistics(:wall_clock)

  # Start the algorithm for the given topology
  StartNetwork.start(algorithm)

  # Once the algorithm is complete, returns here
  receive do
    {:done} ->

        {_, t2} = :erlang.statistics(:wall_clock)
        IO.puts "Time taken to complete #{algorithm} is #{t2} milliseconds"
        IO.puts "Main is done"
  end

end
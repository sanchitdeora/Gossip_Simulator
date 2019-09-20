defmodule Proj2 do

  numNodes = 5
  topology = :full
  algorithm = :gossip

#  {:ok, listener} = Listener.start_link([])

  case {topology} do
    {:full} ->
      IO.puts("Setting up #{topology} network")
      supervisorId = Full.initiate(numNodes, algorithm)
      IO.inspect(supervisorId)
      IO.puts("Starting up #{topology} network")
      Full.startNetwork(supervisorId, algorithm)
#      IO.puts("Finishing up #{topology} network")
  end

  receive do
    {:done} ->
  end

end
defmodule StartNetwork do
  def start(algorithm) do



    childNodes = Supervisor.which_children(SuperV)
    childNames =
      Enum.map(childNodes, fn currentNode ->
        {currentName, _, _, _} = currentNode
        currentName
      end)

    deadNodes = Listener.getDeadNodes(MyListener)
    alive_nodes = childNames -- deadNodes
#    IO.inspect([alive_nodes], label: "ALIVE NODES:")

    if length(alive_nodes) > 1 do
      firstNode = Enum.random(childNames)

      case algorithm do

        :gossip -> NodeNetwork.gossip(firstNode, {firstNode, algorithm, "MESSAGE"})

        :pushsum -> NodeNetwork.pushsum(firstNode, {firstNode, 0, 0})
      end
    else
#      IO.puts("!!!!!!!!!!!!!!!!!!!! GOT DONE HEREE !!!!!!!!!!!!!!!!")
      send Main, {:done}
    end


  end
end

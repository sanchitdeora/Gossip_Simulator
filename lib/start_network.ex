defmodule StartNetwork do

  # Starts the network
  def start(algorithm) do

    childNodes = Supervisor.which_children(SuperV)
    childNames =
      Enum.map(childNodes, fn currentNode ->
        {currentName, _, _, _} = currentNode
        currentName
      end)

    # Check the number of dead and alive nodes
    deadNodes = Listener.getDeadNodes(MyListener)
    aliveNodes = childNames -- deadNodes

    # If there are more than 1 node alive, starts the network
    if length(aliveNodes) > 1 do
      firstNode = Enum.random(childNames)

      case algorithm do
        :gossip -> NodeNetwork.gossip(firstNode, {firstNode, algorithm, "MESSAGE"})

        :pushsum -> NodeNetwork.pushsum(firstNode, {firstNode, 0, 0})
      end

    else
      send Main, {:done}
    end


  end
end

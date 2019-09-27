defmodule StartNetwork do
  def start(algorithm) do
    childNodes = Supervisor.which_children(SuperV)
    childNames =
      Enum.map(childNodes, fn currentNode ->
        {currentName, _, _, _} = currentNode
        currentName
      end)

    firstNode = Enum.random(childNames)

    NodeNetwork.gossip(firstNode, {firstNode, algorithm, "MESSAGE"})
  end
end

defmodule HoneycombNetwork do

  def create(childNames, randomNeighborBool) do

    numNodes = length(childNames)

    # Create the required number of nodes and get the list of all nodes
    childList = createStructure(childNames, 0, 0)

    IO.inspect(childList, label: "HEY")

    addHoneyCombNeighbor(childList)

    if (randomNeighborBool) do
      addRandomNeighbor(childNames)
    end

    Enum.map(childNames, fn child ->
      state = NodeNetwork.getState(child)
      neighbors = Map.fetch!(state, :neighbors)
#      IO.inspect(neighbors, label: "state12345")
      Listener.set_neighbors(MyListener, {child, neighbors})
      IO.inspect(neighbors, label: "state of #{child}")
    end)

  end

  def createStructure(childNames, i, line) when i >= length(childNames) do
    []
  end

  def createStructure(childNames, i, line) do

    structure =
      if (rem(line, 2) != 0) do
        [[[],[Enum.at(childNames, i)],[Enum.at(childNames, i + 1)],[],[],[Enum.at(childNames, i + 2)],[Enum.at(childNames, i + 3)],[]]]
      else
        [[[Enum.at(childNames, i)],[],[],[Enum.at(childNames, i + 1)],[Enum.at(childNames, i + 2)],[],[],[Enum.at(childNames, i + 3)]]]
      end

    structure ++ createStructure(childNames, i + 4, line + 1)

  end

  def addHoneyCombNeighbor(childList) do

    len = Enum.count(childList)-1

    for iter <- 0..len do

      currList = Enum.at(childList, iter)
      nextList = Enum.at(childList, rem(iter+1, len+1))

      if (Enum.count(Enum.at(currList,0)) != 0) do
        #first and last
#        GenServer.call(getNodeVal(cur_node_list,0), {:addNeighbor, [getNodeVal(cur_node_list,7)]})
#        GenServer.call(getNodeVal(cur_node_list,7), {:addNeighbor, [getNodeVal(cur_node_list,0)]})

        currElem1 = Enum.fetch!(Enum.fetch!(currList, 0), 0)
        currElem2 = Enum.fetch!(Enum.fetch!(currList, 7), 0)

        NodeNetwork.updateNeighbors(Enum.fetch!(Enum.fetch!(currList, 0), 0), Enum.fetch!(Enum.fetch!(currList, 7), 0))
        NodeNetwork.updateNeighbors(Enum.fetch!(Enum.fetch!(currList, 7), 0), Enum.fetch!(Enum.fetch!(currList, 0), 0))

        NodeNetwork.updateNeighbors(Enum.fetch!(Enum.fetch!(currList, 3), 0), Enum.fetch!(Enum.fetch!(currList, 4), 0))
        NodeNetwork.updateNeighbors(Enum.fetch!(Enum.fetch!(currList, 4), 0), Enum.fetch!(Enum.fetch!(currList, 3), 0))

        NodeNetwork.updateNeighbors(Enum.fetch!(Enum.fetch!(currList, 0), 0), Enum.fetch!(Enum.fetch!(nextList, 1), 0))
        NodeNetwork.updateNeighbors(Enum.fetch!(Enum.fetch!(nextList, 1), 0), Enum.fetch!(Enum.fetch!(currList, 0), 0))

        NodeNetwork.updateNeighbors(Enum.fetch!(Enum.fetch!(currList, 3), 0), Enum.fetch!(Enum.fetch!(nextList, 2), 0))
        NodeNetwork.updateNeighbors(Enum.fetch!(Enum.fetch!(nextList, 2), 0), Enum.fetch!(Enum.fetch!(currList, 3), 0))

        NodeNetwork.updateNeighbors(Enum.fetch!(Enum.fetch!(currList, 4), 0), Enum.fetch!(Enum.fetch!(nextList, 5), 0))
        NodeNetwork.updateNeighbors(Enum.fetch!(Enum.fetch!(nextList, 5), 0), Enum.fetch!(Enum.fetch!(currList, 4), 0))

        NodeNetwork.updateNeighbors(Enum.fetch!(Enum.fetch!(currList, 7), 0), Enum.fetch!(Enum.fetch!(nextList, 6), 0))
        NodeNetwork.updateNeighbors(Enum.fetch!(Enum.fetch!(nextList, 6), 0), Enum.fetch!(Enum.fetch!(currList, 7), 0))

#
#        state = NodeNetwork.getState(currElem2)
#        IO.inspect([currElem2 | Map.fetch!(state, :neighbors)], label: "state2")

#        Listener.set_neighbors(MyListener, {current, [prev] ++ [next]})

      else

        NodeNetwork.updateNeighbors(Enum.fetch!(Enum.fetch!(currList, 1), 0), Enum.fetch!(Enum.fetch!(currList, 2), 0))
        NodeNetwork.updateNeighbors(Enum.fetch!(Enum.fetch!(currList, 2), 0), Enum.fetch!(Enum.fetch!(currList, 1), 0))

        NodeNetwork.updateNeighbors(Enum.fetch!(Enum.fetch!(currList, 5), 0), Enum.fetch!(Enum.fetch!(currList, 6), 0))
        NodeNetwork.updateNeighbors(Enum.fetch!(Enum.fetch!(currList, 6), 0), Enum.fetch!(Enum.fetch!(currList, 5), 0))

        NodeNetwork.updateNeighbors(Enum.fetch!(Enum.fetch!(currList, 1), 0), Enum.fetch!(Enum.fetch!(nextList, 0), 0))
        NodeNetwork.updateNeighbors(Enum.fetch!(Enum.fetch!(nextList, 0), 0), Enum.fetch!(Enum.fetch!(currList, 1), 0))

        NodeNetwork.updateNeighbors(Enum.fetch!(Enum.fetch!(currList, 2), 0), Enum.fetch!(Enum.fetch!(nextList, 3), 0))
        NodeNetwork.updateNeighbors(Enum.fetch!(Enum.fetch!(nextList, 3), 0), Enum.fetch!(Enum.fetch!(currList, 2), 0))

        NodeNetwork.updateNeighbors(Enum.fetch!(Enum.fetch!(currList, 5), 0), Enum.fetch!(Enum.fetch!(nextList, 4), 0))
        NodeNetwork.updateNeighbors(Enum.fetch!(Enum.fetch!(nextList, 4), 0), Enum.fetch!(Enum.fetch!(currList, 5), 0))

        NodeNetwork.updateNeighbors(Enum.fetch!(Enum.fetch!(currList, 6), 0), Enum.fetch!(Enum.fetch!(nextList, 7), 0))
        NodeNetwork.updateNeighbors(Enum.fetch!(Enum.fetch!(nextList, 7), 0), Enum.fetch!(Enum.fetch!(currList, 6), 0))

      end
    end
  end

  def addRandomNeighbor(randomList) when length(randomList) <= 1 do
    []
  end

  def addRandomNeighbor(randomList) do
#    IO.puts("hello")
    child = Enum.fetch!(randomList, 0)
    state = NodeNetwork.getState(child)
    neighbors = Map.fetch!(state, :neighbors)
    IO.inspect(neighbors, label: "#{child}")
    otherNodes = randomList -- neighbors
    otherNodes = otherNodes -- [child]
    IO.inspect(otherNodes, label: "other nodes of #{child}")
    randomNeighbor = Enum.random(otherNodes)
    IO.inspect(randomNeighbor, label: "#{child}")
    NodeNetwork.updateNeighbors(child, [randomNeighbor])
    NodeNetwork.updateNeighbors(randomNeighbor, [child])
    randomList = randomList -- [child]
    randomList = randomList -- [randomNeighbor]

    addRandomNeighbor(randomList)

  end

end

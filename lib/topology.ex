defmodule Topology do

  # Start creating network here
  def createNetwork(numNodes, topology, algorithm) do

    case topology do
      :full ->  childNames = createChild(numNodes, algorithm)
                fullNetwork(childNames)

      :line ->  childNames = createChild(numNodes, algorithm)
                lineNetwork(childNames)

      :rand2D -> childNames = createChild(numNodes, algorithm)
                 rand2DNetwork(childNames)

      :torus3D -> max = findMax(numNodes)
                  newNumNodes = calculateNodes(max, numNodes)

                  childNames = createChild(newNumNodes, algorithm)
                  Torus3DNetwork.create(childNames, max)

      :honeycomb -> newNumNodes =
                      if rem(numNodes, 16) != 0 do
                        numNodes - rem(numNodes, 16) + 16
                      else
                        numNodes
                      end
                    childNames = createChild(newNumNodes, algorithm)
                    HoneycombNetwork.create(childNames, false)

      :randhoneycomb -> newNumNodes =
                          if rem(numNodes, 16) != 0 do
                            numNodes - rem(numNodes, 16) + 16
                          else
                            numNodes
                          end
                        childNames = createChild(newNumNodes, algorithm)
                        HoneycombNetwork.create(childNames, true)
    end

  end

  # Creates children for the Supervisor
  defp createChild(numNodes, algorithm) do

    children =
      Enum.map(0..(numNodes - 1), fn i ->
        nodeName = ("N" <> Integer.to_string(i)) |> String.to_atom

        %{
          id: nodeName,
          start: {NodeNetwork, :start_link, [{algorithm, i}, [name: nodeName]]}
        }
      end)

    {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)
    Process.register pid, SuperV
    {:ok, _listener} = Listener.start_link(name: MyListener)

    childNodes = Supervisor.which_children(pid)
#    IO.inspect(childNodes)

    childNames =
      Enum.map(childNodes, fn currNode ->
        {currName, _, _, _} = currNode
        currName
      end)

#    IO.inspect(childNames)
      childNames
  end

  # Creates full network topology
  defp fullNetwork(childNames) do

    # Every node is linked to the other nodes in the network
    Enum.map(childNames, fn currName ->
      NodeNetwork.setNeighbors(currName, List.delete(childNames, currName))
      Listener.setNeighbors(MyListener, {currName, List.delete(childNames, currName)})
    end)

  end

  # Creates line network topology
  defp lineNetwork(childNames) do

    # Neighbors of first node is set
    first = Enum.fetch!(childNames, 0)
    NodeNetwork.setNeighbors(first, [Enum.fetch!(childNames, 1)])
    Listener.setNeighbors(MyListener, {first, [Enum.fetch!(childNames, 1)]})

    # Neighbors of the nodes lying in the middle are set
    Enum.map(1..length(childNames) - 2, fn i ->
      prev = Enum.fetch!(childNames, (i - 1))
      next = Enum.fetch!(childNames, (i + 1))
      current = Enum.fetch!(childNames, i)
      NodeNetwork.setNeighbors(current, [prev] ++ [next])
      Listener.setNeighbors(MyListener, {current, [prev] ++ [next]})
    end)

    # Neighbors of last node is set
    last = Enum.fetch!(childNames, (length(childNames)-1))
    NodeNetwork.setNeighbors(last, [Enum.fetch!(childNames, (length(childNames)-2))])
    Listener.setNeighbors(MyListener, {last, [Enum.fetch!(childNames, (length(childNames)-2))]})

  end

  # Creates random2D grid topology
  defp rand2DNetwork(childNames) do

    # Generates random x, y position for each node
    positions = Enum.map(childNames, fn currChild ->
      x = Float.round(:rand.uniform(), 2)
      y = Float.round(:rand.uniform(), 2)
      {currChild, {x, y}}
    end)

#    IO.inspect(positions)

    # Each neighbor is assigned to the remaining nodes in the network, if the Euclidean distance is less than 0.1
    Enum.map(positions, fn currChild ->
      neighbors = rand2DNeighbors(currChild, positions) |> Enum.filter(& !is_nil(&1))
#      IO.inspect(neighbors)
      {current, _} = currChild
      NodeNetwork.setNeighbors(current, neighbors)
      Listener.setNeighbors(MyListener, {current, neighbors})
    end)

  end

  # Checks the condition and generates a list for neighbors of the input node
  defp rand2DNeighbors(current, positions) do

    {_node1, {x1, y1}} = current

    neighbors = Enum.map(List.delete(positions, current), fn next ->
      {node2, {x2, y2}} = next
      distance = :math.pow((x2 - x1),2) + :math.pow((y2 - y1),2) |> :math.sqrt()
      if distance < 0.1 do
        node2
      end
    end)

  end

  # Used to find max for 3D Torus
  defp findMax(n) when (n < 27) do
    2
  end
  defp findMax(n) when (n < 64 and n >= 27) do
    3
  end

  # Checks for the lowest required nodes in the network
  defp findMax(n) do
    maxList = Enum.map(6..3, fn x ->
      {calculateNodes(x, n), x}
    end)
    maxList = Enum.sort(maxList)
    {_, max} = List.first(maxList)
    max
  end

  # Calculates the number of nodes required for given max in 3D Torus
  defp calculateNodes(max, n) do
    each_n = (n / max) |> :math.ceil() |> trunc
    sq_root = :math.sqrt(each_n)
    each_n = (:math.ceil(sq_root) * :math.ceil(sq_root)) |> trunc
    n = each_n * max
    n
  end
end
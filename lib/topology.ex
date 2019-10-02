defmodule Topology do

  def createNetwork(numNodes, topology, algorithm) do

    case topology do
      :full ->  childNames = createChild(numNodes, algorithm)
                fullNetwork(childNames)

      :line ->  childNames = createChild(numNodes, algorithm)
                lineNetwork(childNames)

      :rand2D -> childNames = createChild(numNodes, algorithm)
                 rand2DNetwork(childNames)

      :torus3D -> max = findMax(numNodes)
#                  IO.inspect(max, label: "max")
                  newNumNodes = calculateNodes(max, numNodes)
#                  IO.inspect(newNumNodes, label: "#{max}")

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

  def createChild(numNodes, algorithm) do

    children =
      Enum.map(0..(numNodes - 1), fn i ->
        nodeName = ("N" <> Integer.to_string(i)) |> String.to_atom

        %{
          id: nodeName,
          start: {NodeNetwork, :start_link, [{algorithm, i}, [name: nodeName]]}
        }
      end)
#    IO.inspect(children)


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

  def fullNetwork(childNames) do

    Enum.map(childNames, fn currName ->
      NodeNetwork.setNeighbors(currName, List.delete(childNames, currName))
      Listener.setNeighbors(MyListener, {currName, List.delete(childNames, currName)})
    end)

  end

  def lineNetwork(childNames) do
#    IO.inspect(length(childNames))
    first = Enum.fetch!(childNames, 0)
    NodeNetwork.setNeighbors(first, [Enum.fetch!(childNames, 1)])
    Listener.setNeighbors(MyListener, {first, [Enum.fetch!(childNames, 1)]})

    Enum.map(1..length(childNames) - 2, fn i ->
      prev = Enum.fetch!(childNames, (i - 1))
      next = Enum.fetch!(childNames, (i + 1))
      current = Enum.fetch!(childNames, i)
      NodeNetwork.setNeighbors(current, [prev] ++ [next])
      Listener.setNeighbors(MyListener, {current, [prev] ++ [next]})
    end)

    last = Enum.fetch!(childNames, (length(childNames)-1))
    NodeNetwork.setNeighbors(last, [Enum.fetch!(childNames, (length(childNames)-2))])
    Listener.setNeighbors(MyListener, {last, [Enum.fetch!(childNames, (length(childNames)-2))]})

  end

  def rand2DNetwork(childNames) do
    positions = Enum.map(childNames, fn currChild ->
      x = Float.round(:rand.uniform(), 2)
      y = Float.round(:rand.uniform(), 2)
      {currChild, {x, y}}
    end)
#    IO.inspect(positions)
    Enum.map(positions, fn currChild ->
      neighbors = rand2DNeighbors(currChild, positions) |> Enum.filter(& !is_nil(&1))
#      IO.inspect(neighbors)
      {current, _} = currChild
      NodeNetwork.setNeighbors(current, neighbors)
      Listener.setNeighbors(MyListener, {current, neighbors})
    end)
  end

  defp rand2DNeighbors(current, positions) do

    {_node1, {x1, y1}} = current
#    IO.inspect(current, label: "Main")
    _neighbors = Enum.map(List.delete(positions, current), fn next ->
      {node2, {x2, y2}} = next
#      IO.inspect(next, label: "Inside")
      distance = :math.pow((x2 - x1),2) + :math.pow((y2 - y1),2) |> :math.sqrt()
#      IO.inspect(distance)
      if distance < 0.6 do
        node2
      end
    end)
  end

  def findMax(n) when (n < 27) do
    2
  end
  def findMax(n) when (n < 64 and n >= 27) do
    3
  end

  def findMax(n) do
    maxList = Enum.map(6..3, fn x ->
      {calculateNodes(x, n), x}
    end)
    maxList = Enum.sort(maxList)
    {_, max} = List.first(maxList)
    max
  end

  def calculateNodes(max, n) do
#    IO.inspect(max, label: "#{n}")
    each_n = (n / max) |> :math.ceil() |> trunc
    sq_root = :math.sqrt(each_n)
    each_n = (:math.ceil(sq_root) * :math.ceil(sq_root)) |> trunc
    n = each_n * max
    n
  end
end
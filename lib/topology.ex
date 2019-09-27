defmodule Topology do

  def createNetwork(numNodes, topology, algorithm) do
    children =
      Enum.map(0..(numNodes - 1), fn i ->
        nodeName = ("N" <> Integer.to_string(i)) |> String.to_atom

        %{
          id: nodeName,
          start: {NodeNetwork, :start_link, [algorithm, [name: nodeName]]}
        }
      end)
    IO.inspect(children)
    createChild(children , topology)

  end

  def createChild(children, topology) do
    {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)
    Process.register pid, SuperV
    {:ok, listener} = Listener.start_link(name: MyListener)

    childNodes = Supervisor.which_children(pid)
#    IO.inspect(childNodes)

    childNames =
      Enum.map(childNodes, fn currNode ->
        {currName, _, _, _} = currNode
        currName
      end)

    IO.inspect(childNames)

    case topology do
      :full -> fullNetwork(childNames)

      :line -> lineNetwork(childNames)

      :rand2D -> rand2DNetwork(childNames)
    end
  end

  def fullNetwork(childNames) do

    Enum.map(childNames, fn currName ->
      NodeNetwork.setNeighbors(currName, List.delete(childNames, currName))
      Listener.set_neighbors(MyListener, {currName, List.delete(childNames, currName)})
    end)

  end

  def lineNetwork(childNames) do
#    IO.inspect(length(childNames))
    first = Enum.fetch!(childNames, 0)
    NodeNetwork.setNeighbors(first, [Enum.fetch!(childNames, 1)])
    Listener.set_neighbors(MyListener, {first, [Enum.fetch!(childNames, 1)]})

    Enum.map(1..length(childNames) - 2, fn i ->
      prev = Enum.fetch!(childNames, (i - 1))
      next = Enum.fetch!(childNames, (i + 1))
      current = Enum.fetch!(childNames, i)
      NodeNetwork.setNeighbors(current, [prev] ++ [next])
      Listener.set_neighbors(MyListener, {current, [prev] ++ [next]})
    end)

    last = Enum.fetch!(childNames, (length(childNames)-1))
    NodeNetwork.setNeighbors(last, [Enum.fetch!(childNames, (length(childNames)-2))])
    Listener.set_neighbors(MyListener, {last, [Enum.fetch!(childNames, (length(childNames)-2))]})

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
      IO.inspect(neighbors)
      {current, _} = currChild
      NodeNetwork.setNeighbors(current, neighbors)
      Listener.set_neighbors(MyListener, {current, neighbors})
    end)
  end

  defp rand2DNeighbors(current, positions) do

    {node1, {x1, y1}} = current
#    IO.inspect(current, label: "Main")
    neighbors = Enum.map(List.delete(positions, current), fn next ->
      {node2, {x2, y2}} = next
#      IO.inspect(next, label: "Inside")
      distance = :math.pow((x2 - x1),2) + :math.pow((y2 - y1),2) |> :math.sqrt()
#      IO.inspect(distance)
      if distance < 0.5 do
        node2
      end
    end)
  end



end
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

    c = Enum.map(1..length(childNames) - 2, fn i ->
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



end
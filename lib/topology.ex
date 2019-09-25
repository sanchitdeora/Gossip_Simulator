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
    IO.inspect(childNodes)

    childNames =
      Enum.map(childNodes, fn curr_node ->
        {curr_name, _, _, _} = curr_node
        curr_name
      end)

    IO.inspect(childNames)

    case topology do
      :full -> fullNetwork(childNames)

      :line -> lineNetwork(childNames)
    end
  end

  def fullNetwork(childNames) do

    Enum.map(childNames, fn curr_name ->
      NodeNetwork.setNeighbors(curr_name, List.delete(childNames, curr_name))
      Listener.set_neighbors(MyListener, {curr_name, List.delete(childNames, curr_name)})
    end)

  end

  def lineNetwork(childNames) do

  end


end
defmodule Full do

  def initiate(numNodes, algorithm) do
    children =
      Enum.map(0..(numNodes - 1), fn i ->
        nodeName = ("N" <> Integer.to_string(i)) |> String.to_atom

        %{
          id: nodeName,
          start: {Network, :start_link, [algorithm, [name: nodeName]]}
        }
    end)
    IO.inspect(children)
    createChild(children)
  end

  def startNetwork(supervisorId, algorithm) do
#    IO.inspect("Here1")
    childNodes = Supervisor.which_children(supervisorId)
    childNames =
      Enum.map(childNodes, fn curr_node ->
        {curr_name, _, _, _} = curr_node
        curr_name
      end)

    firstNode = Enum.random(childNames)

    Network.gossip(firstNode, {firstNode, "MESSAGE"})

  end














  def createChild(children) do
    {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)

    {:ok, listener} = Listener.start_link(name: MyListener)

    childNodes = Supervisor.which_children(pid)
    IO.inspect(childNodes)

    childNames =
      Enum.map(childNodes, fn curr_node ->
        {curr_name, _, _, _} = curr_node
        curr_name
      end)

    IO.inspect(childNames)

    Enum.map(childNames, fn curr_name ->
      Network.setNeighbors(curr_name, List.delete(childNames, curr_name))
#      Listener.setNeighbors(listener_pid, {curr_name, List.delete(childNames, curr_name)})
    end)
    pid
  end

end

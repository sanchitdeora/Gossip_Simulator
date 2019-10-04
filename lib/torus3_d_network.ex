defmodule Torus3DNetwork do

  # Creates the 3D Torus Network
  def create(childNames, max) do

    # Creates chunks in the list according to the coordinates on the grid
    n = length(childNames)
    each_n = (n / max) |> trunc
    sqroot_each_n = :math.sqrt(each_n) |> trunc
    lists = Enum.chunk_every(childNames, each_n)

    # Creating 2D
    list_2darray =
      Enum.map(lists, fn each_list ->
        list = Enum.chunk_every(each_list, sqroot_each_n)
        from_list(list)
      end)
    d3array = 0..length(list_2darray) |> Stream.zip(list_2darray) |> Enum.into(%{})

    # setting up basic 2D grip topology
    Enum.each(d3array, fn {_key, val} ->
      d2setup(val, sqroot_each_n)
    end)

    # setting the 3D neighbors
    d3setup(d3array, sqroot_each_n, max)

    # setting the Torus neighbors
    torusNeighbors(d3array, sqroot_each_n, max)

  end

  # Connects all the 2D neighbor of the nodes
  defp d2setup(array, sq_root) do
    Enum.each(0..(sq_root - 1), fn i ->
      Enum.each(0..(sq_root - 1), fn j ->
        curr = array[i][j]

        if i == 0 do
          cond do
            j == 0 ->
              neighbors_list = [
                array[i][j + 1],
                array[i + 1][j]
              ]

              setNeighbors(curr, neighbors_list)

            j == sq_root - 1 ->
              neighbors_list = [array[i][j - 1], array[i + 1][j]]
              setNeighbors(curr, neighbors_list)

            true ->
              neighbors_list = [
                array[i + 1][j],
                array[i][j + 1],
                array[i][j - 1]
              ]

              setNeighbors(curr, neighbors_list)
          end

        else
          if i == sq_root - 1 do
            cond do
              j == 0 ->
                neighbors_list = [array[i - 1][j], array[i][j + 1]]
                setNeighbors(curr, neighbors_list)

              j == sq_root - 1 ->
                neighbors_list = [array[i - 1][j], array[i][j - 1]]
                setNeighbors(curr, neighbors_list)

              true ->
                neighbors_list = [array[i][j - 1], array[i][j + 1], array[i - 1][j]]
                setNeighbors(curr, neighbors_list)
            end
          end
        end


        if j == 0 && (i != 0 && i != sq_root - 1) do
          neighbors_list = [array[i][j + 1], array[i - 1][j], array[i + 1][j]]
          setNeighbors(curr, neighbors_list)
        end

        if j == sq_root - 1 && (i != 0 && i != sq_root - 1) do
          neighbors_list = [array[i][j - 1], array[i + 1][j], array[i - 1][j]]
          setNeighbors(curr, neighbors_list)
        end

        if i != 0 && i != sq_root - 1 && j != 0 && j != sq_root - 1 do
          neighbors_list = [array[i][j - 1], array[i - 1][j], array[i][j + 1], array[i + 1][j]]
          setNeighbors(curr, neighbors_list)
        end
      end)
    end)
  end

  # Connects all 3D neighbors of the nodes
  defp d3setup(d3array, sqroot_each_n, max) do

    Enum.each(0..(max - 1), fn k ->
      Enum.each(0..(sqroot_each_n - 1), fn i ->
        Enum.each(0..(sqroot_each_n - 1), fn j ->
          cond do
            k == 0 ->
              NodeNetwork.updateNeighbors(d3array[k][i][j], d3array[k + 1][i][j])
              Listener.updateNeighbors(MyListener, {d3array[k][i][j], [d3array[k + 1][i][j]]})

            k == max - 1 ->
              NodeNetwork.updateNeighbors(d3array[k][i][j], d3array[k - 1][i][j])
              Listener.updateNeighbors(MyListener, {d3array[k][i][j], [d3array[k - 1][i][j]]})

            true ->
              NodeNetwork.updateNeighbors(d3array[k][i][j], d3array[k - 1][i][j])
              NodeNetwork.updateNeighbors(d3array[k][i][j], d3array[k + 1][i][j])

              Listener.updateNeighbors( MyListener, {d3array[k][i][j], [d3array[k - 1][i][j], d3array[k + 1][i][j]]})
          end
        end)
      end)
    end)
  end

  # Connects all the outer nodes in the grid
  defp torusNeighbors(d3array, sqroot_each_n, max) do

    Enum.each(0..(max - 1), fn z ->
        Enum.each(0..(sqroot_each_n - 1), fn y ->
            Enum.each(0..(sqroot_each_n), fn x ->

              elem = d3array[z][y][x]
              cond do
                x == 0 -> NodeNetwork.updateNeighbors(elem, d3array[z][y][sqroot_each_n - 1])
                x == sqroot_each_n - 1 -> NodeNetwork.updateNeighbors(elem, d3array[z][y][0])
                true -> []
              end
              cond do
                y == 0 -> NodeNetwork.updateNeighbors(elem, d3array[z][sqroot_each_n - 1][x])
                y == sqroot_each_n - 1 -> NodeNetwork.updateNeighbors(elem, d3array[z][0][x])
                true -> []
              end
              cond do
                z == 0 -> NodeNetwork.updateNeighbors(elem, d3array[max - 1][y][x])
                z == max - 1 -> NodeNetwork.updateNeighbors(elem, d3array[0][y][x])
                true -> []
              end

          end)
        end)
      end)
  end

  defp setNeighbors(curr, neighbors_list) do
    NodeNetwork.setNeighbors(curr, neighbors_list)
    Listener.setNeighbors(MyListener, {curr, neighbors_list})
  end

  # Used to form Maps of List to get 3D coordinates (x, y, z) for the nodes
  defp from_list(list) when is_list(list) do
    do_from_list(list)
  end

  defp do_from_list(list, map \\ %{}, index \\ 0)
  defp do_from_list([], map, _index), do: map

  defp do_from_list([h | t], map, index) do
    map = Map.put(map, index, do_from_list(h))
    do_from_list(t, map, index + 1)
  end

  defp do_from_list(other, _, _), do: other
end

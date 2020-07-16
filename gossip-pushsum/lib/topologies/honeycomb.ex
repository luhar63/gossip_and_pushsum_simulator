defmodule Project.Topo.HoneyComb do
  def start(node_list, withRandom) do
    find_neighbours(node_list, withRandom)
  end

  def find_neighbours(node_list, withRandom) do
    colCount = 8
    # assuming column count as 8

    node_list
    |> Enum.with_index()
    |> Enum.map(fn {node, i} ->
      rowNumber = trunc(Float.floor(i / colCount))
      connected = []

      connected =
        if(2 * rowNumber * colCount == i or 2 * rowNumber * colCount + 7 == i) do
          connected
        else
          if(Integer.mod(rowNumber + i, 2) == 0) do
            connected ++ [Enum.at(node_list, i + 1)]
          else
            connected ++ [Enum.at(node_list, i - 1)]
          end
        end

      connected =
        if(i + colCount < length(node_list)) do
          connected ++ [Enum.at(node_list, i + colCount)]
        else
          connected
        end

      connected =
        if(i - colCount > 0) do
          connected ++ [Enum.at(node_list, i - colCount)]
        else
          connected
        end

      connected =
        if(withRandom) do
          connected ++ [Enum.random(node_list -- [node])]
        else
          connected
        end

      Project.Nodes.Worker.setNeighbors(node, Enum.filter(connected, fn elem -> elem != nil end))
    end)
  end
end

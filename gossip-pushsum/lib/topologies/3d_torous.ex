defmodule Project.Topo.Torous3D do
  def start(node_list) do
    find_neighbours(node_list)
  end

  def find_neighbours(node_list) do
    node_list_length = length(node_list)

    rc = trunc(Float.ceil(:math.pow(node_list_length, 1 / 3)))
    # IO.inspect(node_list)

    node_list
    |> Enum.with_index()
    |> Enum.map(fn {node, i} ->
      # rowNumber = trunc(Float.floor(i / rc))
      layerNumber = trunc(Float.floor(i / (rc * rc)))
      layerElements = rc * rc
      connected = []

      connected =
        if layerNumber == 0 or layerNumber == rc - 1 do
          connected =
            if(layerNumber == 0) do
              connected ++
                [
                  Enum.at(node_list, i + layerElements * (rc - 1)),
                  Enum.at(node_list, i + rc * rc)
                ]
            else
              connected
            end

          connected =
            if(layerNumber == rc - 1) do
              connected ++
                [
                  Enum.at(node_list, i - layerElements * (rc - 1)),
                  Enum.at(node_list, i - rc * rc)
                ]
            else
              connected
            end

          connected
        else
          connected ++ [Enum.at(node_list, i + rc * rc), Enum.at(node_list, i - rc * rc)]
        end

      connected =
        if rem(i, layerElements) < rc or
             (rem(i, layerElements) >= rc * (rc - 1) and rem(i, layerElements) < rc * rc) do
          connected =
            if(rem(i, layerElements) < rc) do
              connected ++ [Enum.at(node_list, i + rc * (rc - 1)), Enum.at(node_list, i + rc)]
            else
              connected
            end

          connected =
            if(rem(i, layerElements) >= rc * (rc - 1) and rem(i, layerElements) < rc * rc) do
              connected ++ [Enum.at(node_list, i - rc * (rc - 1)), Enum.at(node_list, i - rc)]
            else
              connected
            end

          connected
        else
          connected ++ [Enum.at(node_list, i + rc), Enum.at(node_list, i - rc)]
        end

      connected =
        if(rem(i, rc) == 0 or rem(i, rc) == rc - 1) do
          connected =
            if(rem(i, rc) == 0) do
              connected ++ [Enum.at(node_list, i + (rc - 1)), Enum.at(node_list, i + 1)]
            else
              connected
            end

          connected =
            if rem(i, rc) == rc - 1 do
              connected ++ [Enum.at(node_list, i - (rc - 1)), Enum.at(node_list, i - 1)]
            else
              connected
            end

          connected
        else
          connected ++ [Enum.at(node_list, i + 1), Enum.at(node_list, i - 1)]
        end

      # IO.inspect(i)
      # IO.inspect(connected)
      # connected

      Project.Nodes.Worker.setNeighbors(node, Enum.filter(connected, fn elem -> elem != nil end))
    end)
  end
end

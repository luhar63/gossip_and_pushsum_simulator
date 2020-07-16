defmodule Project.Topo.Line do
  def start(node_list) do
    find_neighbours(node_list)
  end

  def find_neighbours(node_list) do
    node_list_length = length(node_list)

    node_list
    |> Enum.with_index()
    |> Enum.map(fn {node, i} ->
      cond do
        i == 0 ->
          Project.Nodes.Worker.setNeighbors(node, [Enum.at(node_list, i + 1)])

        i == node_list_length - 1 ->
          Project.Nodes.Worker.setNeighbors(node, [Enum.at(node_list, i - 1)])

        true ->
          Project.Nodes.Worker.setNeighbors(node, [
            Enum.at(node_list, i - 1),
            Enum.at(node_list, i + 1)
          ])
      end
    end)
  end
end

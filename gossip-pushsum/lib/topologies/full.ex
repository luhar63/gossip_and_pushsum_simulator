defmodule Project.Topo.Full do
  def start(node_list) do
    find_neighbours(node_list)
  end

  def find_neighbours(node_list) do
    Enum.map(node_list, fn node ->
      Project.Nodes.Worker.setNeighbors(node, List.delete(node_list, node))
    end)
  end
end

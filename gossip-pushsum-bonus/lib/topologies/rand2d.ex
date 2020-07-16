defmodule Project.Topo.Rand2D do
  def start(node_list) do
    nodes = set_coordinates(node_list)
    # IO.inspect(nodes)
    find_neighbors(nodes)
  end

  def get_random_coordinates() do
    x = Float.round(:rand.uniform(), 3)
    y = Float.round(:rand.uniform(), 3)
    %{x: x, y: y}
  end

  def set_coordinates(node_list) do
    node_list
    |> Enum.with_index()
    |> Enum.map(fn {node, i} ->
      coordinate = get_random_coordinates()
      %{node: node, coordinate: coordinate, index: i}
    end)
  end

  def find_neighbors(coordinated_nodes_list) do
    coordinated_nodes_list
    |> Enum.map(fn current_node ->
      neighbor = []

      neighbor =
        for neighbor_node <-
              List.delete(coordinated_nodes_list, current_node),
            are_neighbor_close(current_node.coordinate, neighbor_node.coordinate, 0.1),
            do: neighbor ++ neighbor_node.node

      Project.Nodes.Worker.setNeighbors(current_node.node, neighbor)
    end)
  end

  def are_neighbor_close(node, neighbor_node, distance) do
    if get_distance_between(node, neighbor_node) < distance do
    end

    get_distance_between(node, neighbor_node) < distance
  end

  def get_distance_between(node1, node2) do
    :math.sqrt(:math.pow(node1.x - node2.x, 2) + :math.pow(node1.y - node2.y, 2))
  end
end

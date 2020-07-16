defmodule Project.Algorithm.Gossip do
  # 15sec timeout (can be configured for more number of nodes)
  @timeout 15000
  def start(superPid, startTime) do
    node_list = Enum.map(Supervisor.which_children(superPid), fn {_, pid, _, _} -> pid end)

    activeNodes = Project.Nodes.Worker.checkActiveNodes(node_list)

    if(length(activeNodes) == 0) do
      if(System.monotonic_time(:millisecond) - startTime > 10000) do
        IO.puts("No nodes are connected")
        System.halt(0)
      end

      start(superPid, startTime)
    else
      currentNode = Enum.random(activeNodes)
      IO.puts("Rumour Started By")
      IO.inspect(currentNode)
      start_a_rumour("Rumour", currentNode, superPid, startTime)

      Project.Algorithm.infiniteLoop(
        node_list,
        startTime,
        0,
        System.monotonic_time(:millisecond),
        @timeout
      )
    end
  end

  def start_a_rumour(message, currentNode, superPid, startTime) do
    %{:neighbors => neighbors} = Project.Nodes.Worker.getState(currentNode)
    possibleNeighbours = Project.Nodes.Worker.checkActiveNodes(neighbors)

    if(length(possibleNeighbours) > 0) do
      randomNeighbor = Enum.random(possibleNeighbours)
      Project.Nodes.Worker.sendMessage(randomNeighbor, message, currentNode, startTime, superPid)
    else
      start(superPid, startTime)
    end
  end
end

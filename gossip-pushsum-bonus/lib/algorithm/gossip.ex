defmodule Project.Algorithm.Gossip do
  # 15sec timeout (can be configured for more number of nodes)
  @timeout 15000
  def start(superPid, startTime, failure) do
    node_list = Enum.map(Supervisor.which_children(superPid), fn {_, pid, _, _} -> pid end)

    activeNodes = Project.Nodes.Worker.checkActiveNodes(node_list)

    if(length(activeNodes) == 0) do
      if(System.monotonic_time(:millisecond) - startTime > 10000) do
        IO.puts("No nodes are connected")
        System.halt(0)
      end

      start(superPid, startTime, failure)
    else
      currentNode = Enum.random(activeNodes)
      IO.puts("Rumour Started By")
      IO.inspect(currentNode)

      if(failure > 0) do
        disableNodes(failure, node_list)
      end

      start_a_rumour("Rumour", currentNode, superPid, startTime, failure)

      Project.Algorithm.infiniteLoop(
        node_list,
        startTime,
        0,
        System.monotonic_time(:millisecond),
        @timeout
      )
    end
  end

  def disableNodes(failure, node_list) do
    node_list_length = length(node_list)
    failureNumber = round(failure / 100 * node_list_length)

    failureIndexes =
      for _i <- 1..(2 * failureNumber),
          do: Enum.random(0..(node_list_length - 1))

    failureIndexes = failureIndexes |> Enum.uniq() |> Enum.slice(0, failureNumber)
    # IO.inspect(failureIndexes)

    for failureIndex <- failureIndexes do
      Project.Nodes.Worker.setInactive(Enum.at(node_list, failureIndex))
    end

    # IO.inspect({"Disabled", failureNumber})
  end

  def start_a_rumour(message, currentNode, superPid, startTime, failure) do
    %{:neighbors => neighbors} = Project.Nodes.Worker.getState(currentNode)
    possibleNeighbours = Project.Nodes.Worker.checkActiveNodes(neighbors)

    if(length(possibleNeighbours) > 0) do
      randomNeighbor = Enum.random(possibleNeighbours)
      Project.Nodes.Worker.sendMessage(randomNeighbor, message, startTime, superPid)
    else
      start(superPid, startTime, failure)
    end
  end
end

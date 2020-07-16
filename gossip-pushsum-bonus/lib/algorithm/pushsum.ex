defmodule Project.Algorithm.PushSum do
  def start(superPid, startTime, failure) do
    node_list = Enum.map(Supervisor.which_children(superPid), fn {_, pid, _, _} -> pid end)
    currentNode = Enum.random(node_list)

    IO.puts("Push-Sum started by Node:")
    IO.inspect(currentNode)

    if(failure > 0) do
      disableNodes(failure, node_list)
    end

    start_computation(superPid, currentNode, startTime, failure)

    infiniteCheck(node_list, startTime)
  end

  def disableNodes(failure, node_list) do
    node_list_length = length(node_list)
    failureNumber = round(failure / 100 * node_list_length)

    failureIndexes =
      for _i <- 1..(2 * failureNumber),
          do: Enum.random(0..(node_list_length - 1))

    failureIndexes = failureIndexes |> Enum.uniq() |> Enum.slice(0, failureNumber)

    for failureIndex <- failureIndexes do
      Project.Nodes.Worker.setInactive(Enum.at(node_list, failureIndex))
    end

    # IO.inspect({"killed", failureNumber})
  end

  def infiniteCheck(node_list, startTime) do
    activelist =
      Enum.filter(node_list, fn pid ->
        %{:active => active} = Project.Nodes.Worker.getState(pid)
        active
      end)

    # IO.inspect(length(activelist))

    # convergence % - 1%
    if(length(activelist) >= 1) do
      infiniteCheck(node_list, startTime)
    else
      IO.puts("Final Time")
      IO.inspect(System.monotonic_time(:millisecond) - startTime)
    end

    infiniteCheck(node_list, startTime)

    # IO.inspect(activelist)
  end

  def start_computation(superPid, currentNode, startTime, failure) do
    %{:neighbors => neighbors, :sum => sum, :weight => weight} =
      Project.Nodes.Worker.getState(currentNode)

    if(length(neighbors) == 0) do
      start(superPid, startTime, failure)
    else
      possibleNeighbours = Project.Nodes.Worker.checkActiveNodes(neighbors)

      if(length(possibleNeighbours) > 0) do
        randomNeighbor = Enum.random(possibleNeighbours)
        Project.Nodes.Worker.updateSumEstimate(currentNode, sum / 2, weight / 2)
        Project.Nodes.Worker.computeSumEstimate(randomNeighbor, sum / 2, weight / 2, startTime)
      end
    end
  end
end

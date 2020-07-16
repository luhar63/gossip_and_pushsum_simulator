defmodule Project.Algorithm.PushSum do
  def start(superPid, startTime) do
    node_list = Enum.map(Supervisor.which_children(superPid), fn {_, pid, _, _} -> pid end)
    currentNode = Enum.random(node_list)

    IO.puts("Push-Sum started by Node:")
    IO.inspect(currentNode)

    start_computation(superPid, currentNode, startTime)

    infiniteCheck(node_list, startTime)
  end

  def infiniteCheck(node_list, startTime) do
    activelist =
      Enum.filter(node_list, fn pid ->
        %{:active => active} = Project.Nodes.Worker.getState(pid)
        active
      end)

    # IO.inspect(length(activelist))

    # check if we have any active list
    if(length(activelist) >= 1) do
      infiniteCheck(node_list, startTime)
    else
      IO.puts("Final Time")
      IO.inspect(System.monotonic_time(:millisecond) - startTime)
    end

    infiniteCheck(node_list, startTime)

    # IO.inspect(activelist)
  end

  def start_computation(superPid, currentNode, startTime) do
    %{:neighbors => neighbors, :sum => sum, :weight => weight} =
      Project.Nodes.Worker.getState(currentNode)

    if(length(neighbors) == 0) do
      start(superPid, startTime)
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

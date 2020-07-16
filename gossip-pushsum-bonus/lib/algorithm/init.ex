defmodule Project.Algorithm do
  def start(superPid, algorithm, startTime, failure) do
    run_algorithm(superPid, algorithm, startTime, failure)
  end

  def run_algorithm(superPid, algorithm, startTime, failure) do
    cond do
      algorithm == "gossip" ->
        Project.Algorithm.Gossip.start(superPid, startTime, failure)

      algorithm == "push-sum" ->
        Project.Algorithm.PushSum.start(superPid, startTime, failure)
    end
  end

  def getSpread(node_list) do
    infected =
      Enum.filter(node_list, fn pid ->
        %{:count => count} = Project.Nodes.Worker.getState(pid)
        count > 0
      end)

    IO.inspect({"spread %: ", length(infected) / length(node_list) * 100})
  end

  def infiniteLoop(node_list, startTime, prevActivelist, invocationTime, timeout) do
    activelist =
      Enum.filter(node_list, fn pid ->
        %{:active => active} = Project.Nodes.Worker.getState(pid)
        active
      end)

    # IO.inspect(length(activelist))

    if(
      length(activelist) === prevActivelist &&
        System.monotonic_time(:millisecond) - invocationTime > timeout
    ) do
      IO.puts("Timed out: node didn't send anything for last 15 sec")
      getSpread(node_list)
      IO.puts("Total Time:")
      IO.inspect(System.monotonic_time(:millisecond) - startTime)
    else
      invocationTime =
        if(length(activelist) != prevActivelist) do
          System.monotonic_time(:millisecond)
        else
          invocationTime
        end

      if(length(activelist) >= 1) do
        infiniteLoop(node_list, startTime, length(activelist), invocationTime, timeout)
      else
        getSpread(node_list)
        IO.puts("Convergence Time")
        IO.inspect(System.monotonic_time(:millisecond) - startTime)
      end
    end
  end
end

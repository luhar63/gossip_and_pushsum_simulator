defmodule Project.Nodes.Worker do
  use GenServer, restart: :permanent

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  def init(serial_number) do
    # for node
    state = %{}
    state = Map.put(state, :active, false)
    # for gossip

    state = Map.put(state, :count, 0)

    # for push sum
    state = Map.put(state, :sum, elem(Integer.parse(Enum.at(serial_number, 0)), 0))
    state = Map.put(state, :weight, 1)
    state = Map.put(state, :diff, 0)
    # state = Map.put(state, :endTime, 0)

    {:ok, state}
  end

  def checkActiveNodes(neighbors) do
    Enum.filter(neighbors, fn current ->
      if(Process.alive?(current)) do
        %{:active => active} = getState(current)
        active
      else
        false
      end
    end)
  end

  #  client code

  def getState(pid) do
    GenServer.call(pid, {:getState}, :infinity)
  end

  def getNeighbors(pid) do
    GenServer.call(pid, {:getNeighbors}, :infinity)
  end

  def setNeighbors(pid, neighbors) do
    GenServer.cast(pid, {:setNeighbors, neighbors, pid})
  end

  def setInactive(pid) do
    GenServer.cast(pid, {:setInactive})
  end

  # #################### GOSSIP ############################
  def sendMessage(toPid, message, startTime, superPid) do
    GenServer.cast(toPid, {:sendMessage, message, startTime, superPid})
  end

  # #################### GOSSIP Ends ############################

  # #################### PUSH SUM ############################
  def computeSumEstimate(pid, sum, weight, startTime) do
    GenServer.cast(pid, {:computeSumEstimate, sum, weight, startTime})
  end

  def updateSumEstimate(pid, sum, weight) do
    GenServer.cast(pid, {:updateSumEstimate, sum, weight})
  end

  def displayNodeCount(superPid, state) do
    IO.inspect(
      Enum.map(Supervisor.which_children(superPid), fn {_, pid, _, _} ->
        if(pid != self()) do
          %{:count => count} = getState(pid)
          {pid, count}
        else
          {self(), state[:count]}
        end
      end)
    )
  end

  def resend_message(neighbors, message, startTime, superPid) do
    neighbors = checkActiveNodes(neighbors)
    # IO.inspect(neighbors)

    if(length(neighbors) > 0) do
      randomNeighbor = Enum.random(neighbors)

      sendMessage(
        randomNeighbor,
        message,
        startTime,
        superPid
      )

      Process.sleep(50)
      resend_message(neighbors, message, startTime, superPid)
    end
  end

  # #################### PUSH SUM Ends ############################

  #  server code

  def handle_call({:getState}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:getNeighbors}, _from, state) do
    {:reply, state[:neighbors], state}
  end

  def handle_cast({:setNeighbors, neighbors, pid}, state) do
    state = Map.put(state, :neighbors, neighbors)

    state =
      if(length(neighbors) > 0) do
        Map.put(state, :active, true)
      else
        state
      end

    {:noreply, Map.put(state, :pid, pid)}
  end

  def handle_cast({:setInactive}, state) do
    {:noreply, Map.put(state, :active, false)}
  end

  # #################### GOSSIP ############################

  def handle_cast({:sendMessage, message, startTime, superPid}, state) do
    state =
      if(state[:message] == message) do
        Map.put(state, :count, state.count + 1)
      else
        Map.put(state, :count, 1)
      end

    state = Map.put(state, :message, message)

    # {:ok, pid} =
    if(state[:count] == 1) do
      Task.start_link(__MODULE__, :resend_message, [
        state[:neighbors],
        message,
        startTime,
        superPid
      ])
    end

    if(state[:count] >= 10) do
      setInactive(self())
    end

    {:noreply, state}
  end

  # #################### GOSSIP Ends ############################

  # #################### PUSH SUM ############################

  def handle_cast({:computeSumEstimate, sum, weight, startTime}, state) do
    prevSumEstimate = state[:sum] / state[:weight]
    totalSum = state[:sum] + sum
    totalWeight = state[:weight] + weight
    currentSumEstimate = totalSum / totalWeight

    diff = currentSumEstimate - prevSumEstimate

    state =
      if(abs(diff) < :math.pow(10, -10)) do
        Map.put(state, :diff, state[:diff] + 1)
      else
        Map.put(state, :diff, 0)
      end

    # IO.inspect(
    #   {self(), state[:sum], state[:weight], state[:diff], state[:active], currentSumEstimate}
    # )

    state = Map.put(state, :sum, totalSum)
    state = Map.put(state, :weight, totalWeight)

    neighbors = checkActiveNodes(state[:neighbors])

    state =
      if(length(neighbors) == 0) do
        setInactive(self())
        IO.inspect({"Last Sum Estimate", state[:sum] / state[:weight]})
        IO.inspect(System.monotonic_time(:millisecond) - startTime)
        # Map.put(state, :endTime, System.monotonic_time(:millisecond))
        System.halt(0)
      else
        state
      end

    if(state[:diff] <= 3 and length(neighbors) > 0) do
      randomNeighbor = Enum.random(neighbors)
      updateSumEstimate(self(), state[:sum] / 2, state[:weight] / 2)

      computeSumEstimate(
        randomNeighbor,
        state[:sum] / 2,
        state[:weight] / 2,
        startTime
      )

      if(state[:diff] == 3) do
        # IO.puts("TaskEnd ")
        # IO.inspect(self())
        setInactive(self())
        # IO.inspect(System.monotonic_time(:millisecond) - startTime)
      end
    end

    {:noreply, state}
  end

  def handle_cast({:updateSumEstimate, sum, weight}, state) do
    state = Map.put(state, :sum, sum)
    state = Map.put(state, :weight, weight)
    {:noreply, state}
  end

  def terminate(_reason, _state) do
  end

  # #################### PUSH SUM Ends ############################
end

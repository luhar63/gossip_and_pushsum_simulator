defmodule Project.Main do
  def start([numNodes, topology, algorithm]) do
    numNodes =
      if(String.valid?(numNodes)) do
        elem(Integer.parse(numNodes), 0)
      else
        numNodes
      end

    startTime = System.monotonic_time(:millisecond)
    numNodes = Project.Topo.reconfigurationOfNodes(numNodes, topology)
    {nodes, superPid} = createNodes(numNodes)
    Project.Topo.start(nodes, topology)
    Project.Algorithm.start(superPid, algorithm, startTime)
    # next = System.monotonic_time(:microsecond)
    # diff = next - prev
    # diff
    # for node <- nodes, do: Project.Nodes.Worker.getState(node)
  end

  def createNodes(numNodes) do
    {:ok, superPid} = Project.Nodes.Supervisor.start_link(numNodes)
    node_worker_list = Supervisor.which_children(superPid)
    node_list = Enum.map(node_worker_list, fn {_, pid, _, _} -> pid end)
    {node_list, superPid}
  end
end

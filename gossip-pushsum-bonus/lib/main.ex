defmodule Project.Main do
  def start([numNodes, topology, algorithm, failure]) do
    numNodes =
      if(String.valid?(numNodes)) do
        elem(Integer.parse(numNodes), 0)
      else
        numNodes
      end

    failure =
      if(String.valid?(failure)) do
        elem(Integer.parse(failure), 0)
      else
        failure
      end

    if(failure == 100) do
      IO.puts("We need nodes to run our algorithms")
      System.halt(0)
    end

    startTime = System.monotonic_time(:millisecond)
    numNodes = Project.Topo.reconfigurationOfNodes(numNodes, topology)
    {nodes, superPid} = createNodes(numNodes)
    Project.Topo.start(nodes, topology)
    Project.Algorithm.start(superPid, algorithm, startTime, failure)
  end

  def createNodes(numNodes) do
    {:ok, superPid} = Project.Nodes.Supervisor.start_link(numNodes)
    node_worker_list = Supervisor.which_children(superPid)
    node_list = Enum.map(node_worker_list, fn {_, pid, _, _} -> pid end)
    {node_list, superPid}
  end
end

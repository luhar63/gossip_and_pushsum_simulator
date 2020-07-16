defmodule Project.Topo do
  def start(node_list, topology) do
    configure_topology(node_list, topology)
  end

  def reconfigurationOfNodes(nodeNumber, topology) do
    cond do
      topology == "full" ->
        nodeNumber

      topology == "line" ->
        nodeNumber

      topology == "rand2D" ->
        nodeNumber

      topology == "honeycomb" ->
        nodeNumber - rem(nodeNumber, 8)

      topology == "randhoneycomb" ->
        nodeNumber - rem(nodeNumber, 8)

      topology == "3Dtorus" ->
        trunc(:math.pow(trunc(Float.ceil(:math.pow(nodeNumber, 1 / 3))), 3))

      true ->
        nodeNumber
    end
  end

  def configure_topology(nodes, topology) do
    cond do
      topology == "full" ->
        Project.Topo.Full.start(nodes)

      topology == "line" ->
        Project.Topo.Line.start(nodes)

      topology == "rand2D" ->
        Project.Topo.Rand2D.start(nodes)

      topology == "honeycomb" ->
        Project.Topo.HoneyComb.start(nodes, false)

      topology == "randhoneycomb" ->
        Project.Topo.HoneyComb.start(nodes, true)

      topology == "3Dtorus" ->
        Project.Topo.Torous3D.start(nodes)

      true ->
        IO.puts("Please enter a matching Topology")
        System.halt(0)
    end
  end
end

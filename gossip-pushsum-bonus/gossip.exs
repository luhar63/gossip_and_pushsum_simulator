[nodesNumber, topology, algorithm, failure] = System.argv()

Project.Main.start([
  String.to_integer(nodesNumber),
  topology,
  algorithm,
  String.to_integer(failure)
])

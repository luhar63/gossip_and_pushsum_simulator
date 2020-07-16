[nodesNumber, topology, algorithm] = System.argv()

Project.Application.start(:normal, {String.to_integer(nodesNumber), topology, algorithm})

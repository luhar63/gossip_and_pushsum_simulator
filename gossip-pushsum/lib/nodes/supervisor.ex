defmodule Project.Nodes.Supervisor do
  use Supervisor

  def start_link(nodes) do
    Supervisor.start_link(__MODULE__, nodes)
  end

  def init(numberOfNodes) do
    # IO.puts(numberOfNodes)
    # parseArguments()
    # IO.puts("Supervisor creating nodes")

    children =
      for num <- 1..numberOfNodes,
          into: [],
          do:
            Supervisor.child_spec({Project.Nodes.Worker, [Integer.to_string(num)]},
              id: String.to_atom("my_worker_#{num}")
            )

    Supervisor.init(children, strategy: :one_for_one)
  end
end

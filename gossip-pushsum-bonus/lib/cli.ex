defmodule Project.CLI do
  def main(args \\ []) do
    args
    |> Project.Main.start()
  end
end

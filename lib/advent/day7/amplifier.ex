defmodule Advent.Day7.Amplifier do
  @moduledoc """
  A wrapped around an interpreter to denote an amplified.
  """

  use GenStage

  alias Advent.Day2.Interpreter
  alias Advent.Day7.MemoryIO

  def start_link(opts \\ []) do
    memory = Keyword.fetch!(opts, :memory)
    configuration = Keyword.fetch!(opts, :configuration)

    GenStage.start_link(__MODULE__, %{configuration: configuration, memory: memory}, opts)
  end

  def init(%{configuration: configuration, memory: memory} = state) do
    io = MemoryIO.new()
      |> MemoryIO.push(configuration)

    interpreter = memory
      |> Interpreter.new()
      |> Interpreter.with_io(MemoryIO, io)
      |> Interpreter.with_break([:input, :output])
      |> Interpreter.run()
  end
end

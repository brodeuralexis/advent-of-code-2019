defmodule Advent.Day7.MemoryIO do
  @moduledoc """
  An IO module that uses memory to hold input and output.
  """

  defstruct input: [], output: []

  @behaviour Advent.Day2.Interpreter.IO

  @typedoc """
  The type of this memory IO for an interpreter.
  """
  @type t :: %__MODULE__{
    input: [integer],
    output: [integer],
  }

  @doc """
  Creates a new memory IO for an interpreter.
  """
  @spec new() :: t
  def new do
    %__MODULE__{}
  end

  @doc """
  Pushes the given value unto the inputs of this memory IO.
  """
  @spec push(t, integer) :: t
  def push(%__MODULE__{input: input} = memory_io, integer) when is_integer(integer) do
    %{memory_io|input: input ++ [integer]}
  end

  @doc """
  Pops a value from the output of this memory io.
  """
  @spec pop(t) :: {t, integer | nil}

  def pop(%__MODULE__{output: []} = memory_io) do
    {memory_io, nil}
  end

  def pop(%__MODULE__{output: [integer | output]} = memory_io) do
    memory_io = %{memory_io|output: output}

    {memory_io, integer}
  end

  @impl true
  def output(%__MODULE__{output: output} = memory_io, integer) do
    memory_io = %{memory_io|output: output ++ [integer]}

    {:ok, memory_io}
  end

  @impl true
  def input(%__MODULE__{input: []}) do
    {:error, :eof}
  end

  @impl true
  def input(%__MODULE__{input: [integer | input]} = memory_io) do
    memory_io = %{memory_io|input: input}

    {:ok, memory_io, integer}
  end
end

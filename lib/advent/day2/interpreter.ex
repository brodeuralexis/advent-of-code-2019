defmodule Advent.Day2.Interpreter do
  @moduledoc """
  An intcode interpreter, interpreting a list of integers as byte code to be
  executed.
  """

  defstruct [:memory, :instruction_pointer, :io, :break]

  alias Advent.Day2.Instruction

  alias __MODULE__, as: Interpreter
  alias Interpreter.Decoder

  @typedoc """
  The type of decoded intcode.
  """
  @type intcode :: [integer]

  @typedoc """
  The type of an intcode interpreter.
  """
  @opaque t :: %Interpreter{
    memory: intcode,
    instruction_pointer: integer,
    io: {atom, term},
    break: :input | :output | nil | [:input | :output],
  }

  @doc """
  Returns an new intcode interpreter from the given intcode program memory.
  """
  @spec new(intcode | String.t, atom) :: t
  def new(memory, io \\ Interpreter.IO, context \\ nil)

  def new(memory, io, context) when is_list(memory) do
    %Interpreter{
      memory: memory,
      instruction_pointer: 0,
      io: {io, context},
      break: nil,
    }
  end

  def new(memory, io, context) when is_binary(memory) do
    new(Decoder.decode_intcode(memory), io, context)
  end

  @doc """
  Breaks intcode execution when the specified event occurs.
  """
  @spec with_break(t, :input | :output | nil | [:input | :output]) :: t
  def with_break(%Interpreter{} = interpreter, break) do
    %{interpreter|break: break}
  end

  @doc """
  Changes the module to handle input and output of the interpreter.
  """
  @spec with_io(t, atom) :: t
  def with_io(%Interpreter{} = interpreter, io, context \\ nil) when is_atom(io) do
    %{interpreter|io: {io, context}}
  end

  @doc """
  Runs the interpreter until halting, returning the memory at the end of the
  program's execution.
  """
  @spec run(t) :: intcode
  def run(%__MODULE__{memory: memory, instruction_pointer: instruction_pointer, break: break} = interpreter) do
    memory
    |> Enum.fetch!(instruction_pointer)
    |> Instruction.decode()
    |> Instruction.run(Enum.slice(memory, (instruction_pointer+1)..-1), memory)
    |> case do
      :halt ->
        interpreter = %{interpreter|memory: memory, instruction_pointer: instruction_pointer}

        {:halt, interpreter}
      {:continue, memory: memory, size: size} ->
        interpreter = %{interpreter|memory: memory, instruction_pointer: instruction_pointer + size}

        run(interpreter)
      {:jump, memory: memory, to: instruction_pointer} ->
        interpreter = %{interpreter|memory: memory, instruction_pointer: instruction_pointer}

        run(interpreter)
      {:input, at: at, memory: memory, size: size} ->
        if break == :input or is_list(break) and :input in break do
          {:break, interpreter, :input, fn value ->
            memory = List.replace_at(memory, at, value)

            interpreter = %{interpreter|memory: memory, instruction_pointer: instruction_pointer + size}

            run(interpreter)
          end}
        else
          {interpreter, value} = input!(interpreter)
          memory = List.replace_at(memory, at, value)

          interpreter = %{interpreter|memory: memory, instruction_pointer: instruction_pointer + size}

          run(interpreter)
        end
      {:output, value: value, memory: memory, size: size} ->
        if break == :output or is_list(break) and :output in break do
          {:break, interpreter, :output, value}
        else
          interpreter = output!(interpreter, value)

          interpreter = %{interpreter|memory: memory, instruction_pointer: instruction_pointer + size}

          run(interpreter)
        end
    end
  end

  @doc """
  Returns the memory associated with this interpreter.
  """
  @spec get_memory(t) :: intcode
  def get_memory(%Interpreter{memory: memory}) do
    memory
  end

  @doc """
  Returns the IO context used by this interpreter.
  """
  @spec get_io(t) :: term
  def get_io(%__MODULE__{io: {_, context}}) do
    context
  end

  @doc """
  Returns some input from outside the interpreter.
  """
  @spec input(t) :: {:ok, t, integer} | {:error, term}
  def input(%Interpreter{io: {io, context}} = interpreter) do
    with {:ok, context, integer} <- io.input(context) do
      {:ok, %{interpreter|io: {io, context}}, integer}
    end
  end

  @doc """
  Returns some input from outside the interpreter.
  """
  @spec input!(t) :: {t, integer}
  def input!(%Interpreter{} = interpreter) do
    case input(interpreter) do
      {:ok, interpreter, integer} ->
        {interpreter, integer}
      {:error, reason} ->
        raise "input failed with #{inspect(reason)}"
    end
  end

  @doc """
  Sends some output outside of the interpreter.
  """
  @spec output(t, integer) :: {:ok, t} | {:error, term}
  def output(%Interpreter{io: {io, context}} = interpreter, integer) do
    with {:ok, context} <- io.output(context, integer) do
      {:ok, %{interpreter|io: {io, context}}}
    end
  end

  @doc """
  Sends some output outside of the interpreter.
  """
  @spec output!(t, integer) :: t
  def output!(%Interpreter{} = interpreter, integer) do
    case output(interpreter, integer) do
      {:ok, interpreter} ->
        interpreter
      {:error, reason} ->
        raise "input failed with #{inspect(reason)}"
    end
  end
end

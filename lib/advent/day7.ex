defmodule Advent.Day7 do
  @moduledoc """
  Day 7: Amplification Circuit
  """

  alias Advent.Day2.Interpreter
  alias Advent.Day2.Interpreter.Decoder
  alias Advent.Day7.MemoryIO

  @puzzle_input File.read!("#{__DIR__}/day7/puzzle_input.txt")

  def part1 do
    %{result: result} = @puzzle_input
      |> Decoder.decode_intcode()
      |> all_possible_amplifier_configurations()
      |> Enum.sort_by(&(&1.result), &>=/2)
      |> hd()

    result
  end

  def part2 do
    memory = @puzzle_input
      |> Decoder.decode_intcode()

    [5, 6, 7, 8, 9]
    |> permutations()
    |> Enum.map(fn permutation ->
      Enum.map(permutation, fn initial ->
        {:break, _, :input, continue} = memory
          |> Interpreter.new()
          |> Interpreter.with_io(MemoryIO, MemoryIO.new())
          |> Interpreter.with_break(:input)
          |> Interpreter.run()

        {:break, _, :input, continue} = continue.(initial)

        continue
      end)
      |> amplify_feedback(0)
    end)
    |> Enum.max()
  end

  def all_possible_amplifier_configurations(memory) do
    for [a, b, c, d, e] <- permutations([0, 1, 2, 3, 4]) do
      %{result: amplifier(memory, [a, b, c, d, e]), a: a, b: b, c: c, d: d, e: e}
    end
  end

  def all_possible_amplifier_feedback_configurations(_memory) do
    for [a, b, c, d, e] <- permutations([0, 1, 2, 3, 4]) do
      {a, b, c, d, e}
    end
  end

  def amplifier(memory, configurations) do
    Enum.reduce(configurations, 0, fn configuration, signal ->
      run_with_configuration(memory, configuration, signal)
    end)
  end

  def run_with_configuration(memory, configuration, signal) do
    io = MemoryIO.new()
      |> MemoryIO.push(configuration)
      |> MemoryIO.push(signal)

    {:halt, interpreter} = memory
      |> Interpreter.new()
      |> Interpreter.with_io(MemoryIO, io)
      |> Interpreter.run()

    {_, next_signal} = interpreter
      |> Interpreter.get_io()
      |> MemoryIO.pop()

    next_signal
  end

  def amplify_feedback(amplifiers, strength) do
    {amplifiers, status} = Enum.map_reduce(amplifiers, {:running, strength}, fn continue, {_, strength} ->
      case continue.(strength) do
        {:break, interpreter, :input, continue} ->
          {continue, {:running, peek_signal(interpreter)}}
        {:halt, interpreter} ->
          {:unreachable, {:ending, peek_signal(interpreter)}}
      end
    end)

    case status do
      {:running, signal} ->
        amplify_feedback(amplifiers, signal)
      {:ending, signal} ->
        signal
    end
  end

  @doc """
  Returns all possible permutations of the provided terms.

  ## Examples

      ```iex
      iex> permutations([0, 1, 2])
      [
        [0, 1, 2],
        [0, 2, 1],
        [1, 0, 2],
        [1, 2, 0],
        [2, 0, 1],
        [2, 1, 0]
      ]
      ```

      ```iex
      iex> permutations([0])
      [[0]]
      ```

      ```iex
      iex> permutations([])
      []
      ```
  """
  @spec permutations([term]) :: [[term]]

  def permutations([]) do
    []
  end

  def permutations([a]) do
    [[a]]
  end

  def permutations(list) when is_list(list) do
    for elem <- list,
        rest <- permutations(list -- [elem])
    do
      [elem | rest]
    end
  end

  defp peek_signal(interpreter) do
    io = Interpreter.get_io(interpreter)
    Enum.at(io.output, length(io.output) - 1)
  end
end

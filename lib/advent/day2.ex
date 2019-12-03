defmodule Advent.Day2 do
  @moduledoc """
  Day 2: 1202 Program Alarm
  """

  @type raw :: String.t
  @type intcode :: List.t(integer)

  @puzzle_input File.read!("#{__DIR__}/day2/puzzle_input.txt")

  @doc """
  Get result for the 2nd day of the advent of code 2019.
  """
  @spec day2() :: nil
  def day2 do
    [
      puzzle_input: day2_part1(),
      missing_noun_and_verb: day2_part2()
    ]
  end

  @doc """
  The first part of day 2's challenge.
  """
  @spec day2_part1() :: integer
  def day2_part1 do
    @puzzle_input
    |> decode_intcode()
    |> List.replace_at(1, 12)
    |> List.replace_at(2, 2)
    |> run()
    |> Enum.at(0)
  end

  @doc """
  The second part of day 2's challenge.
  """
  @spec day2_part2() :: integer
  def day2_part2 do
    values = for noun <- 0..99, verb <- 0..99 do
      [noun: noun, verb: verb]
    end

    [noun: noun, verb: verb] = Enum.find(values, fn [noun: noun, verb: verb] ->
      value =
        @puzzle_input
        |> decode_intcode()
        |> List.replace_at(1, noun)
        |> List.replace_at(2, verb)
        |> run()
        |> Enum.at(0)

      value == 19690720
    end)

    [result: 100 * noun + verb, noun: noun, verb: verb]
  end

  @doc """
  Decodes and runs the given string in the intcode interpreter.
  """
  @spec run(raw) :: intcode
  def run(string) when is_binary(string) do
    string
    |> decode_intcode()
    |> run()
  end

  @doc """
  Runs the given intcode in the interpreter.
  """
  @spec run(intcode) :: intcode
  def run(memory) when is_list(memory) do
    run(memory, 0)
  end

  @spec run(intcode, intcode) :: intcode
  defp run(memory, instruction_pointer) do
    memory
    |> Enum.slice(instruction_pointer..-1)
    |> interpret(memory)
    |> case do
      :halt ->
        memory
      {:continue, memory: memory, size: size} ->
        run(memory, instruction_pointer + size)
    end
  end

  @doc """
  Interprets a slice of memory as the given program and returns new information
  for the interpreter.
  """
  @spec interpret(intcode, intcode) :: :halt | {:continue, memory: intcode, size: integer}
  def interpret(program, memory)

  def interpret([99] ++ _, _memory) do
    :halt
  end

  def interpret([1, left, right, result] ++ _, memory) do
    left = Enum.at(memory, left)
    right = Enum.at(memory, right)

    memory = List.replace_at(memory, result, left + right)

    {:continue, memory: memory, size: 4}
  end

  def interpret([2, left, right, result] ++ _, memory) do
    left = Enum.at(memory, left)
    right = Enum.at(memory, right)

    memory = List.replace_at(memory, result, left * right)

    {:continue, memory: memory, size: 4}
  end

  def interpret([intcode] ++ rest, memory) do
    position = Enum.count(memory) - Enum.count(rest) - 1

    raise "invalid intcode #{intcode} at #{position}"
  end

  @doc """
  Decodes the given Intcode program into a list of integers.

  ## Examples
      ```iex
      iex> decode_intcode("1,9,10,3,2,3,11,0,99,30,40,50")
      [1, 9, 10, 3, 2, 3, 11, 0, 99, 30, 40, 50]
      ```

      ```iex
      iex> decode_intcode("1,1,1,4,99,5,6,0,99")
      [1, 1, 1, 4, 99, 5, 6, 0, 99]
      ```
  """
  @spec decode_intcode(raw) :: intcode
  def decode_intcode(binary) do
    binary
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.with_index()
    |> Enum.map(&decode_intcode_integer/1)
  end

  defp decode_intcode_integer({binary, index}) do
    case Integer.parse(binary) do
      {integer, ""} ->
        integer
      _ ->
        raise "invalid intcode at #{index}"
    end
  end
end

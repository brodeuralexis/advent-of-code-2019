defmodule Advent.Day2 do
  @moduledoc """
  Day 2: 1202 Program Alarm
  """

  alias Advent.Day2.Interpreter
  alias Advent.Day2.Interpreter.Decoder

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
    |> Decoder.decode_intcode()
    |> List.replace_at(1, 12)
    |> List.replace_at(2, 2)
    |> Interpreter.run()
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
        |> Decoder.decode_intcode()
        |> List.replace_at(1, noun)
        |> List.replace_at(2, verb)
        |> Interpreter.run()
        |> Enum.at(0)

      value == 19690720
    end)

    [result: 100 * noun + verb, noun: noun, verb: verb]
  end
end

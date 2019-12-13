defmodule Advent.Day9 do
  @moduledoc """
  Day 9: Sensor Boost
  """

  @boost File.read!("#{__DIR__}/day9/boost.txt")

  alias Advent.Day2.Interpreter

  def part1 do
    @boost
    |> Interpreter.new()
    |> Interpreter.run()
  end

  def part2 do
    @boost
    |> Interpreter.new()
    |> Interpreter.run()
  end
end

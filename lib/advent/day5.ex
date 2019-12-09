defmodule Advent.Day5 do
  @moduledoc """
  Day 5: Sunny with a Chance of Asteroids
  """

  @puzzle_input File.read!("#{__DIR__}/day5/puzzle_input.txt")

  alias Advent.Day2.Interpreter

  def test do
    @puzzle_input
    |> Interpreter.new()
    |> Interpreter.run()
  end
end

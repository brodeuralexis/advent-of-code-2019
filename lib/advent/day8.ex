defmodule Advent.Day8 do
  @moduledoc """
  Day 8: Space Image Format
  """

  alias Advent.Day8.SpaceImageFormat

  @puzzle_input File.read!("#{__DIR__}/day8/puzzle_input.txt")

  def part1 do
    image()
    |> SpaceImageFormat.checksum()
  end

  def part2 do
    layer = image()
      |> SpaceImageFormat.decode()

    Enum.each(layer, fn row ->
      row
      |> Enum.map(fn
        0 -> ?0
        1 -> ?1
        2 -> ?2
      end)
      |> to_string()
      |> IO.puts()
    end)
  end

  def image do
    @puzzle_input
    |> SpaceImageFormat.parse(width: 25, height: 6)
  end
end

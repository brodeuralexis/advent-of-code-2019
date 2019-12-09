defmodule Advent.Day3 do
  @moduledoc """
  Day 3: Crossed Wires
  """

  alias Advent.Day3.Decoder
  alias Advent.Day3.WireGrid
  alias Advent.Day3.WirePath

  @type position :: WirePath.position

  @puzzle_input File.read!("#{__DIR__}/day3/puzzle_input.txt")

  def part1 do
    @puzzle_input
    |> Decoder.decode_wire_grid()
    |> WireGrid.intersections()
    |> Enum.min_by(&manhattan_distance/1)
    |> manhattan_distance()
  end

  def part2 do
    wire_grid = @puzzle_input
      |> Decoder.decode_wire_grid()

    wire_grid
    |> WireGrid.intersections()
    |> Stream.map(&WireGrid.steps_to_intersection(wire_grid, &1))
    |> Enum.min()
  end

  @doc """
  Returns the manhattan distance between the given position and the origin.

  ## Example

      ```iex
      iex> manhattan_distance({4, 8})
      12
      ```
  """
  @spec manhattan_distance(position) :: integer
  def manhattan_distance(position) do
    manhattan_distance(position, {0, 0})
  end

  @doc """
  Returns the manhattan distance between the 2 given positions.

  ## Example

      ```iex
      iex> manhattan_distance({3, 5}, {-1, 1})
      8
      ```
  """
  @spec manhattan_distance(position, position) :: integer
  def manhattan_distance({x1, y1}, {x2, y2}) do
    abs(x2 - x1) + abs(y2 - y1)
  end
end

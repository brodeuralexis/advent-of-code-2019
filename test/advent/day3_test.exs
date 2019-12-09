defmodule Advent.Day3Test do
  use ExUnit.Case, async: true

  alias Advent.Day3
  import Day3

  alias Advent.Day3.Decoder
  alias Advent.Day3.WireGrid

  doctest Day3

  test "minimum number of tests" do
    wire_grid = "R75,D30,R83,U83,L12,D49,R71,U7,L72\nU62,R66,U55,R34,D71,R55,D58,R83"
      |> Decoder.decode_wire_grid()

    steps = wire_grid
      |> WireGrid.intersections()
      |> Enum.map(fn intersection ->
        wire_grid
        |> WireGrid.steps_to_intersection(intersection)
      end)
      |> Enum.min()

    assert steps == 610
  end
end

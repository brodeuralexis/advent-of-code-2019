defmodule Advent.Day6Test do
  use ExUnit.Case, async: true

  # alias Advent.Day6.OrbitSystem
  alias Advent.Day6.Decoder

  alias Advent.Day6
  import Day6

  @orbit_system Decoder.decode_orbits("COM)B\nB)C\nC)D\nD)E\nE)F\nB)G\nG)H\nD)I\nE)J\nJ)K\nK)L")

  doctest Day6
end

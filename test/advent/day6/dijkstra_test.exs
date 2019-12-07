defmodule Advent.Day6.DijkstraTest do
  use ExUnit.Case, async: true

  alias Advent.Day6.OrbitSystem
  alias Advent.Day6.Dijkstra.Track

  alias Advent.Day6.Dijkstra
  import Dijkstra

  @orbit_system (
    OrbitSystem.new
    |> OrbitSystem.add_orbit(planet: "COM", satellite: "B")
    |> OrbitSystem.add_orbit(planet: "B", satellite: "C")
    |> OrbitSystem.add_orbit(planet: "C", satellite: "D")
    |> OrbitSystem.add_orbit(planet: "D", satellite: "E")
    |> OrbitSystem.add_orbit(planet: "E", satellite: "F")
    |> OrbitSystem.add_orbit(planet: "B", satellite: "G")
    |> OrbitSystem.add_orbit(planet: "G", satellite: "H")
    |> OrbitSystem.add_orbit(planet: "D", satellite: "I")
    |> OrbitSystem.add_orbit(planet: "E", satellite: "J")
    |> OrbitSystem.add_orbit(planet: "J", satellite: "K")
    |> OrbitSystem.add_orbit(planet: "K", satellite: "L")
  )

  doctest Dijkstra
end

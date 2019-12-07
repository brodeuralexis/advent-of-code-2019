defmodule Advent.Day6 do
  @moduledoc """
  Day 6: Universal Orbit Map
  """

  alias Advent.Day6.OrbitSystem
  alias Advent.Day6.Decoder
  alias Advent.Day6.Dijkstra

  @puzzle_input File.read!("#{__DIR__}/day6/puzzle_input.txt")

  def part1 do
    @puzzle_input
    |> Decoder.decode_orbits()
    |> all_links()
    |> length()
  end

  def part2 do
    system = @puzzle_input
      |> Decoder.decode_orbits()

    san_planet = OrbitSystem.get_planet(system, "SAN")
    you_planet = OrbitSystem.get_planet(system, "YOU")

    system
    |> Dijkstra.dijkstra(you_planet)
    |> Dijkstra.get_shortest_path(san_planet)
    |> length()
  end

  @doc """
  Returns all links between all objects of the given system.

  ## Example

      ```iex
      iex> @orbit_system |> all_links() |> length()
      42
      ```
  """
  @spec all_links(OrbitSystem.t) :: [OrbitSystem.link]
  def all_links(%OrbitSystem{} = system) do
    combinations = for center <- OrbitSystem.get_centers(system),
                       object <- OrbitSystem.get_objects(system),
                       center != object,
                       do: [planet: center, satellite: object]

    combinations
    |> Stream.flat_map(&OrbitSystem.links_between(system, &1))
    |> Enum.to_list()
  end
end

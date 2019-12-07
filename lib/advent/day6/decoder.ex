defmodule Advent.Day6.Decoder do
  @moduledoc """
  A module to decode orbits in textual format.
  """

  alias Advent.Day6.OrbitSystem

  @type raw :: String.t

  @doc """
  Decodes a list of orbits.

  ## Example

      ```iex
      iex> system = decode_orbits "COM)B\\nB)C\\nC)D"
      iex> OrbitSystem.get_satellites(system, "COM")
      MapSet.new(["B"])
      iex> OrbitSystem.get_satellites(system, "B")
      MapSet.new(["C"])
      iex> OrbitSystem.get_satellites(system, "C")
      MapSet.new(["D"])
      iex> OrbitSystem.get_satellites(system, "D")
      MapSet.new([])
      ```
  """
  @spec decode_orbits(raw) :: OrbitSystem.t
  def decode_orbits(raw) do
    raw
    |> String.split("\n")
    |> Stream.map(&String.trim/1)
    |> Stream.filter(&(&1 != ""))
    |> Stream.map(&decode_orbit/1)
    |> Enum.reduce(OrbitSystem.new, fn orbit, system ->
      OrbitSystem.add_orbit(system, orbit)
    end)
  end

  defp decode_orbit(raw) do
    raw
    |> String.normalize(:nfd)
    |> String.split(~r/[\(\)]/, include_captures: true)
    |> case do
      [satellite, "(", planet] ->
        [planet: planet, satellite: satellite]
      [planet, ")", satellite] ->
        [planet: planet, satellite: satellite]
      e ->
        raise "invalid orbit: #{inspect(raw)}, decoded to: #{inspect(e)}"
    end
  end
end

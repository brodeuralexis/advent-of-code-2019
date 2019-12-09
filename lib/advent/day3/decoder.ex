defmodule Advent.Day3.Decoder do
  @moduledoc """
  A decoder for a raw representation of a wire grid.
  """

  alias Advent.Day3.WirePath
  alias Advent.Day3.WireGrid

  @typedoc """
  The raw representation of a wire grid.
  """
  @type raw :: String.t

  @doc """
  Decodes the given raw data into a wire grid.

  If the raw data is invalid, an error is raised.
  """
  @spec decode_wire_grid(raw) :: WireGrid.t
  def decode_wire_grid(raw) do
    raw
    |> String.split("\n")
    |> Stream.map(&String.trim/1)
    |> Stream.filter(&(&1 != ""))
    |> Stream.map(&decode_wire_path/1)
    |> Stream.with_index()
    |> Enum.reduce(WireGrid.empty(), fn {wire_path, index}, wire_grid ->
      WireGrid.with_wire_path(wire_grid, wire_path, index)
    end)
  end

  @doc """
  Decodes a wire path from its given raw representation.

  ## Examples

      ```iex
      iex> decode_wire_path("R8,U5,L5,D3")
      %WirePath{
        steps: [right: 8, up: 5, left: 5, down: 3]
      }
      ```

      ```iex
      iex> decode_wire_path("U7,R6,D4,L4")
      %WirePath{
        steps: [up: 7, right: 6, down: 4, left: 4]
      }
      ```
  """
  @spec decode_wire_path(raw) :: WirePath.t
  def decode_wire_path(raw) do
    raw
    |> String.split(",")
    |> Stream.map(&String.trim/1)
    |> Stream.filter(&(&1 != ""))
    |> Stream.map(&decode_step/1)
    |> Enum.reduce(WirePath.empty(), fn step, wire_path ->
      WirePath.with_steps(wire_path, [step])
    end)
  end

  for {direction, raw_direction} <- [up: "U", down: "D", left: "L", right: "R"] do
    defp decode_step(unquote(raw_direction) <> integer = step) do
      case Integer.parse(integer) do
        {integer, ""} ->
          {unquote(direction), integer}
        _ ->
          raise "invalid step #{inspect(step)}"
      end
    end
  end

  defp decode_step(step) do
    raise "invalid step #{inspect(step)}"
  end
end

defmodule Advent.Day3.WireGrid do
  @moduledoc """
  A grid upon which wires live.
  """

  defstruct cells: %{}, paths: %{}

  alias Advent.Day3.WirePath

  @type position :: WirePath.position

  @typep cells :: %{optional(position) => MapSet.t(term)}

  @typep paths :: %{optional(term) => WirePath.t}

  @typedoc """
  A wire grid.
  """
  @opaque t :: %__MODULE__{
    cells: cells,
    paths: paths
  }

  @doc """
  Creates an empty wire grid.
  """
  @spec empty() :: t
  def empty do
    %__MODULE__{}
  end

  @doc """
  Adds the given wire path to this wire grid.
  """
  @spec with_wire_path(t, WirePath.t, term) :: t
  def with_wire_path(%__MODULE__{cells: cells, paths: paths} = wire_grid, wire_path, name) do
    cells = wire_path
      |> WirePath.trajectory()
      |> Enum.reduce(cells, fn position, cells ->
        Map.update(cells, position, MapSet.new([name]), &MapSet.put(&1, name))
      end)

    %{wire_grid|
      cells: cells,
      paths: Map.put(paths, name, wire_path)
    }
  end

  @doc """
  Lists all wire intersections for this wire grid.
  """
  @spec intersections(t) :: [position]
  def intersections(%__MODULE__{cells: cells}) do
    for {position, wires} <- cells,
        MapSet.size(wires) > 1,
        do: position
  end

  @doc """
  Returns the number of steps a path needs to get to an intersection.
  """
  @spec steps_to_intersection(t, position) :: %{optional(term) => integer}
  def steps_to_intersection(%__MODULE__{paths: paths}, intersection) do
    Enum.reduce(paths, 0, fn {_name, path}, steps ->
      path
      |> WirePath.trajectory_to(intersection)
      |> length()
      |> Kernel.+(steps)
    end)
  end
end

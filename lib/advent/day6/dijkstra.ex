defmodule Advent.Day6.Dijkstra do
  @moduledoc """
  A module containing the Dijkstra implementation for the orbit system.
  """

  defstruct tracks: %{}, unvisited: MapSet.new()

  alias Advent.Day6.OrbitSystem

  defmodule Track do
    @moduledoc false

    defstruct distance: nil, previous: nil

    @typedoc """
    A row of information in our tracking information.

    For `:distance`, `nil` represents infinity.
    For `:previous`, `nil` represents the abscence of a path.
    """
    @type t :: %__MODULE__{
      distance: integer | nil,
      previous: OrbitSystem.object | nil
    }

    @doc """
    Creates a new track with the given distance and previous node.
    """
    @spec new(integer | nil, OrbitSystem.object | nil) :: t
    def new(distance, previous) do
      %__MODULE__{
        distance: distance,
        previous: previous,
      }
    end
  end


  @typedoc """
  The tracking data to use when applying Dijkstra's algorithm to our orbit
  system.
  """
  @type tracks :: %{optional(OrbitSystem.object) => Track.t}

  @typedoc """
  The type of the state needed by Dijkstra's algorithm.
  """
  @type t :: %{
    tracks: tracks,
    unvisited: MapSet.t(OrbitSystem.object),
  }

  def new(system, object, track) do
    %__MODULE__{
      tracks: %{object => track},
      unvisited: system |> OrbitSystem.get_objects() |> MapSet.delete(object),
    }
  end

  @doc """
  Performs dijkstra on the given orbit system.

  ## Example

      ```iex
      iex> dijkstra(@orbit_system, "K")
      %{
        "B" => %Track{distance: 5, previous: "C"},
        "C" => %Track{distance: 4, previous: "D"},
        "COM" => %Track{distance: 6, previous: "B"},
        "D" => %Track{distance: 3, previous: "E"},
        "E" => %Track{distance: 2, previous: "J"},
        "F" => %Track{distance: 3, previous: "E"},
        "G" => %Track{distance: 6, previous: "B"},
        "H" => %Track{distance: 7, previous: "G"},
        "I" => %Track{distance: 4, previous: "D"},
        "J" => %Track{distance: 1, previous: "K"},
        "L" => %Track{distance: 1, previous: "K"},
        "K" => %Track{distance: 0, previous: nil},
      }
      ```
  """
  @spec dijkstra(OrbitSystem.t, OrbitSystem.object) :: tracks
  def dijkstra(%OrbitSystem{} = system, object) do
    track = Track.new(0, nil)
    state = new(system, object, track)

    state = do_dijkstra(system, object, track, state)

    state.tracks
  end

  defp do_dijkstra(system, current_object, current_track, state) do
    next_distance = current_track.distance + 1

    system
    |> OrbitSystem.get_links(current_object)
    |> Enum.reduce(state, fn linked_object, state ->
      linked_track = case state.tracks[linked_object] do
        %Track{} = linked_track ->
          if linked_track.distance <= next_distance do
            linked_track
          else
            Track.new(next_distance, current_object)
          end
        _ ->
          Track.new(next_distance, current_object)
      end

      tracks = Map.put(state.tracks, linked_object, linked_track)

      if MapSet.member?(state.unvisited, linked_object) do
        do_dijkstra(system, linked_object, linked_track, %{state|
          tracks: tracks,
          unvisited: MapSet.delete(state.unvisited, linked_object),
        })
      else
        %{state|tracks: tracks}
      end
    end)
  end

  @doc """
  Returns the shortest path from the Dijkstra's result to the target object.

  ## Example

      ```iex
      iex> @orbit_system |> dijkstra("K") |> get_shortest_path("I")
      [
        {"K", "J"},
        {"J", "E"},
        {"E", "D"},
        {"D", "I"},
      ]
      ```
  """
  @spec get_shortest_path(tracks, OrbitSystem.object) :: [OrbitSystem.link]
  def get_shortest_path(tracks, target) do
    do_get_shortest_path(tracks, target, [])
  end

  defp do_get_shortest_path(tracks, target, acc) do
    case tracks[target] do
      nil ->
        raise "no path to #{inspect(target)}"
      %Track{previous: nil} ->
        acc
      %Track{previous: previous} ->
        do_get_shortest_path(tracks, previous, [{previous, target} | acc])
    end
  end
end

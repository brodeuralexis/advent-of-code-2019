defmodule Advent.Day6.OrbitSystem do
  @moduledoc """
  A struct representing a system of planets orbiting one another.
  """

  defstruct objects: MapSet.new(), satellites: %{}, planets: %{}, links: %{}

  @typedoc """
  An object of the orbit system.
  """
  @type object :: String.t

  @typedoc """
  A link between 2 objects in a direction.
  """
  @type link :: {from :: object, to :: object}

  @typedoc """
  An orbit system.
  """
  @opaque t :: %__MODULE__{
    objects: MapSet.t(object),
    satellites: %{optional(object) => MapSet.t(object)},
    planets: %{optional(object) => object | nil},
  }

  @doc """
  Creates a new system.

  ## Example

      ```iex
      iex> new()
      %OrbitSystem{}
      ```
  """
  @spec new() :: t
  def new do
    %__MODULE__{}
  end

  @doc """
  Adds information about a satellite orbiting a planet.

  ## Example

      ```iex
      iex> system = @orbit_system |> add_orbit(planet: "COM", satellite: "NEW")
      iex> get_satellites(system, "NEW")
      MapSet.new([])
      iex> get_planet(system, "NEW")
      "COM"
      iex> "NEW" in get_satellites(system, "COM")
      true
      ```
  """
  @spec add_orbit(t, planet: object, satellite: object) :: t
  def add_orbit(%__MODULE__{objects: objects, satellites: satellites, planets: planets} = system, planet: planet, satellite: satellite) do
    %{system |
      objects: objects |> MapSet.put(planet) |> MapSet.put(satellite),
      satellites: Map.update(satellites, planet, MapSet.new([satellite]), &(MapSet.put(&1, satellite))),
      planets: Map.update(planets, satellite, planet, fn current_planet ->
        raise "satellite #{inspect(satellite)} already has planet #{inspect(current_planet)}, cannot add planet #{inspect(planet)}"
      end),
    }
  end

  defmacrop ensure_object(system, object) do
    quote bind_quoted: [system: system, object: object] do
      unless MapSet.member?(system.objects, object) do
        raise "unknown object: #{inspect(object)}"
      end
    end
  end

  @doc """
  Returns all the satellites for a given object, raising if the object does not
  exist.

  ## Examples

      ```iex
      iex> get_satellites(@orbit_system, "COM")
      MapSet.new(["B"])
      ```

      ```iex
      iex> get_satellites(@orbit_system, "E")
      MapSet.new(["J", "F"])
      ```
  """
  @spec get_satellites(t, object) :: MapSet.t(object)
  def get_satellites(%__MODULE__{satellites: satellites} = system, object) do
    ensure_object(system, object)

    Map.get(satellites, object, MapSet.new())
  end

  @doc """
  Returns the orbit that this object orbits around of, raising if the object
  does not exist.

  ## Example

      ```iex
      iex> get_planet(@orbit_system, "B")
      "COM"
      ```

      ```iex
      iex> get_planet(@orbit_system, "F")
      "E"
      ```

      ```iex
      iex> get_planet(@orbit_system, "COM")
      nil
      ```
  """
  @spec get_planet(t, object) :: MapSet.t(object)
  def get_planet(%__MODULE__{planets: planets} = system, object) do
    ensure_object(system, object)

    Map.get(planets, object, nil)
  end

  @doc """
  Returns all links of this object.

  ## Examples

      ```iex
      iex> get_links(@orbit_system, "D")
      MapSet.new(["C", "E", "I"])
      ```

      ```iex
      iex> get_links(@orbit_system, "G")
      MapSet.new(["B", "H"])
      ```
  """
  @spec get_links(t, object) :: MapSet.t(object)
  def get_links(%__MODULE__{} = system, object) do
    ensure_object(system, object)

    satellites = get_satellites(system, object)

    case get_planet(system, object) do
      nil -> satellites
      planet -> MapSet.put(satellites, planet)
    end
  end

  @doc """
  Returns all the objecst defined for the orbit system.

  ## Example

      ```iex
      iex> get_objects(@orbit_system)
      MapSet.new(["COM", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L"])
      ```
  """
  @spec get_objects(t) :: MapSet.t(object)
  def get_objects(%__MODULE__{objects: objects}) do
    objects
  end

  @doc """
  Returns the objects at the center of orbits.

  These are the objects that do not themselves orbit around another object.

  ## Example

      ```iex
      iex> get_centers(@orbit_system)
      MapSet.new(["COM"])
      ```
  """
  @spec get_centers(t) :: [object]
  def get_centers(%__MODULE__{objects: objects} = system) do
    objects
    |> Enum.filter(&(system |> get_planet(&1) |> is_nil()))
    |> MapSet.new()
  end

  @doc """
  Returns the number of links between a satellite and one of the bodies it
  eventually orbits around of.

  ## Examples

      ```iex
      iex> links_between(@orbit_system, planet: "COM", satellite: "D")
      [
        {"D", "C"},
        {"C", "B"},
        {"B", "COM"}
      ]
      ```

      ```iex
      iex> links_between(@orbit_system, planet: "COM", satellite: "L")
      [
        {"L", "K"},
        {"K", "J"},
        {"J", "E"},
        {"E", "D"},
        {"D", "C"},
        {"C", "B"},
        {"B", "COM"}
      ]
      ```
  """
  @spec links_between(t, planet: object, satellite: object) :: [link]
  def links_between(%__MODULE__{} = system, planet: planet, satellite: satellite) do
    ensure_object(system, planet)
    ensure_object(system, satellite)

    system
    |> do_links_between([], planet, satellite, satellite)
    |> Enum.reverse()
  end

  defp do_links_between(system, acc, end_planet, current_planet, start_planet) do
    system
    |> get_planet(current_planet)
    |> case do
      nil ->
        []
      ^end_planet ->
        [{current_planet, end_planet} | acc]
      next_planet ->
        do_links_between(system, [{current_planet, next_planet} | acc], end_planet, next_planet, start_planet)
    end
  end
end

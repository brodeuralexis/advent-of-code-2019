defmodule Advent.Day1 do
  @moduledoc """
  Day 1: The Tyranny of the Rocket Equation
  """

  @puzzle_input File.read!("#{__DIR__}/day1/puzzle_input.txt")

  @typedoc """
  The raw input to the puzzle.
  """
  @type raw :: String.t

  @typedoc """
  The weight of a single module of the spacecraft.
  """
  @type weight :: integer

  @typedoc """
  A list of all the weigts for all modules of the spacecraft.
  """
  @type weights :: List.t(weight)

  @typedoc """
  The amount of fuel required by a module.
  """
  @type fuel :: integer

  @doc """
  Results for the day 1 puzzles.
  """
  @spec day1() :: [{atom, integer}]
  def day1 do
    [
      fuel_for_modules: day1_part1(),
      fuel_for_modules_and_fuel: day1_part2()
    ]
  end

  @doc """
  Result for the first part of day 1's puzzles.
  """
  @spec day1_part1() :: integer
  def day1_part1 do
    @puzzle_input
    |> decode_weights()
    |> Stream.map(&required_fuel/1)
    |> Enum.reduce(0, &(&1 + &2))
  end

  @doc """
  Result for the second part of day 1's puzzles.
  """
  @spec day1_part2() :: integer
  def day1_part2 do
    @puzzle_input
    |> decode_weights()
    |> Stream.map(&required_fuel/1)
    |> Stream.map(&(&1 + required_fuel(&1, for: :fuel)))
    |> Enum.reduce(0, &(&1 + &2))
  end

  @doc """
  Returns the amount of fuel required for a given module's weight.

  ## Examples

      ```iex
      iex> required_fuel(12)
      2
      ```

      ```iex
      iex> required_fuel(14)
      2
      ```

      ```iex
      iex> required_fuel(1969)
      654
      ```

      ```iex
      iex> required_fuel(100756)
      33583
      ```
  """
  @spec required_fuel(weight) :: fuel
  def required_fuel(weight) do
    fuel = Integer.floor_div(weight, 3) - 2

    if fuel >= 0 do
      fuel
    else
      0
    end
  end

  @doc """
  Returns the amount of fuel required for a weight of fuel.

  ## Examples

      ```iex
      iex> required_fuel(2, for: :fuel)
      0
      ```

      ```iex
      iex> required_fuel(654, for: :fuel) + 654
      966
      ```

      ```iex
      iex> required_fuel(33583, for: :fuel) + 33583
      50346
      ```
  """
  @spec required_fuel(weight, for: :fuel) :: integer
  def required_fuel(weight, for: :fuel) do
    do_required_fuel(weight, 0, for: :fuel)
  end

  defp do_required_fuel(weight, acc, for: :fuel) do
    case required_fuel(weight) do
      0 ->
        acc
      n ->
        do_required_fuel(n, acc + n, for: :fuel)
    end
  end

  @doc """
  Decodes a list of weights.

  ## Examples

      ```iex
      iex> decode_weights("42\\n13\\n2\\n")
      [42, 13, 2]
      ```
  """
  @spec decode_weights(raw) :: weights
  def decode_weights(raw) when is_binary(raw) do
    raw
    |> String.split("\n")
    |> Stream.map(&String.trim/1)
    |> Stream.filter(&(&1 != ""))
    |> Stream.with_index()
    |> Stream.map(&decode_weight/1)
    |> Enum.to_list()
  end

  @spec decode_weight({raw, integer}) :: weight
  defp decode_weight({raw, index}) when is_binary(raw) do
    case Integer.parse(raw) do
      {integer, ""} ->
        integer
      e ->
        raise "invalid number #{inspect(e)} at index #{index}"
    end
  end
end

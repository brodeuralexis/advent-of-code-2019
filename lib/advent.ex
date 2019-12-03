defmodule Advent do
  @moduledoc """
  Documentation for Advent.
  """

  defdelegate day1(), to: Advent.Day1

  defdelegate day2(), to: Advent.Day2
end

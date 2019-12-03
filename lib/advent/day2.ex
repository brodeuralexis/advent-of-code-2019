defmodule Advent.Day2 do
  @moduledoc """
  Day 2: 1202 Program Alarm
  """

  @type raw :: String.t
  @type intcode :: List.t(integer)

  @puzzle_input File.read!("#{__DIR__}/day2/puzzle_input.txt")

  @doc """
  Get result for the 2nd day of the advent of code 2019.
  """
  @spec day2() :: integer
  def day2 do
    @puzzle_input
    |> decode_intcode()
    |> List.replace_at(1, 12)
    |> List.replace_at(2, 2)
    |> run()
    |> Enum.at(0)
  end

  @doc """
  Decodes and runs the given string in the intcode interpreter.
  """
  @spec run(raw) :: intcode
  def run(string) when is_binary(string) do
    string
    |> decode_intcode()
    |> run()
  end

  @doc """
  Runs the given intcode in the interpreter.
  """
  @spec run(intcode) :: intcode
  def run(memory) when is_list(memory) do
    run(memory, 0)
  end

  @spec run(intcode, intcode) :: intcode
  defp run(memory, offset) do
    case Enum.slice(memory, offset..(offset + 3)) do
      [99] ++ _ ->
        memory
      [1, left, right, result] ->
        left = Enum.at(memory, left)
        right = Enum.at(memory, right)
        memory = List.replace_at(memory, result, left + right)

        run(memory, offset + 4)
      [2, left, right, result] ->
        left = Enum.at(memory, left)
        right = Enum.at(memory, right)
        memory = List.replace_at(memory, result, left * right)

        run(memory, offset + 4)
      intcode_with_args ->
        raise "invalid intcode with arguments: #{inspect(intcode_with_args)}"
    end
  end

  @doc """
  Decodes the given Intcode program into a list of integers.

  ## Examples
      ```iex
      iex> decode_intcode("1,9,10,3,2,3,11,0,99,30,40,50")
      [1, 9, 10, 3, 2, 3, 11, 0, 99, 30, 40, 50]
      ```

      ```iex
      iex> decode_intcode("1,1,1,4,99,5,6,0,99")
      [1, 1, 1, 4, 99, 5, 6, 0, 99]
      ```
  """
  @spec decode_intcode(raw) :: intcode
  def decode_intcode(binary) do
    binary
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.with_index()
    |> Enum.map(&decode_intcode_integer/1)
  end

  defp decode_intcode_integer({binary, index}) do
    case Integer.parse(binary) do
      {integer, ""} ->
        integer
      _ ->
        raise "invalid intcode at #{index}"
    end
  end
end

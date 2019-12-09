defmodule Advent.Day2.Interpreter.Decoder do
  @moduledoc """
  A module where decoding function for intcode are located.
  """

  alias Advent.Day2.Interpreter

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
  @spec decode_intcode(String.t) :: Interpreter.intcode
  def decode_intcode(binary) do
    binary
    |> String.split(",")
    |> Stream.map(&String.trim/1)
    |> Stream.with_index()
    |> Stream.map(&decode_intcode_integer/1)
    |> Enum.to_list()
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

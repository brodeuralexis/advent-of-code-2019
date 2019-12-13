defmodule Advent.Day2.Interpreter.StandardIO do
  @moduledoc """
  An IO implemention for an interpreter requiring use of the CLI's standard
  input and output.
  """

  alias Advent.Day2.Interpreter

  @behaviour Interpreter.IO

  @impl true
  def input(term) do
    case IO.gets("input> ") do
      {:error, reason} ->
        {:error, reason}
      :eof ->
        {:error, :eof}
      data ->
        data
        |> String.trim()
        |> Integer.parse()
        |> case do
          {integer, ""} ->
            {:ok, term, integer}
          data ->
            {:error, {:invalid_integer, data}}
        end
    end
  end

  @impl true
  def output(term, integer) do
    integer
    |> to_string()
    |> IO.puts()

    {:ok, term}
  end
end

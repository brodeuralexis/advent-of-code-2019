defmodule Advent.Day2.Interpreter.IO do
  @moduledoc """
  Information about input and output in the context of an intcode interpreter.
  """

  @typedoc """
  The type of the function for retrieving input.
  """
  @type input_function :: (term -> {:ok, term, integer} | {:error, term})

  @typedoc """
  The type of the function for outputing information.
  """
  @type output_function :: (term, integer -> {:ok, term} | {:error, term})

  @doc """
  Outputs an integer from the interpreter.
  """
  @callback output(term, integer) :: {:ok, term} | {:error, term}

  @doc """
  Inputs an integer in the interpreter.
  """
  @callback input(term) :: {:ok, term, integer} | {:error, term}
end

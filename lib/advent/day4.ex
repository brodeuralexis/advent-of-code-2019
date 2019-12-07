defmodule Advent.Day4 do
  @moduledoc """
  Day 4: Secure Container
  """

  @typedoc """
  The raw representation of a password.
  """
  @type raw :: integer

  @typedoc """
  A digit of a password.
  """
  @type digit :: 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9

  @typedoc """
  The internal representation of a password.
  """
  @type password :: [digit]

  def part1 do
    145852..616942
    |> Stream.filter(&valid1?/1)
    |> Enum.to_list()
    |> length()
  end

  def part2 do
    145852..616942
    |> Stream.filter(&valid2?/1)
    |> Enum.to_list()
    |> length()
  end

  @doc """
  Indicates if a password is valid.

  ## Examples

      ```iex
      iex> valid1?(111111)
      true
      ```

      ```iex
      iex> valid1?(223450)
      false
      ```

      ```iex
      iex> valid1?(123789)
      false
      ```
  """
  @spec valid1?(password) :: boolean
  def valid1?(password) when is_list(password) do
    digits_increasing?(password) and digit_repeated_at_least_once?(password)
  end

  @spec valid1?(raw) :: boolean
  def valid1?(password) when is_integer(password) do
    password
    |> to_password()
    |> valid1?()
  end

  @doc """
  Indicates if a password is valid.

  ## Examples

    ```iex
    iex> valid2?(112233)
    true
    ```

    ```iex
    iex> valid2?(123444)
    false
    ```

    ```iex
    iex> valid2?(111122)
    true
    ```
  """
  @spec valid2?(password) :: boolean
  def valid2?(password) when is_list(password) do
    digits_increasing?(password) and digit_repeated_exactly_once?(password)
  end

  @spec valid2?(raw) :: boolean
  def valid2?(password) when is_integer(password) do
    password
    |> to_password()
    |> valid2?()
  end

  defp digits_increasing?([d1, d2, d3, d4, d5, d6]) do
    d1 <= d2 and d2 <= d3 and d3 <= d4 and d4 <= d5 and d5 <= d6
  end

  defp digit_repeated_at_least_once?([d, d, d, d, d, d]), do: true
  defp digit_repeated_at_least_once?([d, d, d, d, d, _]), do: true
  defp digit_repeated_at_least_once?([d, d, d, d, _, _]), do: true
  defp digit_repeated_at_least_once?([d, d, d, _, _, _]), do: true
  defp digit_repeated_at_least_once?([d, d, _, _, _, _]), do: true
  defp digit_repeated_at_least_once?([_, d, d, d, d, d]), do: true
  defp digit_repeated_at_least_once?([_, d, d, d, d, _]), do: true
  defp digit_repeated_at_least_once?([_, d, d, d, _, _]), do: true
  defp digit_repeated_at_least_once?([_, d, d, _, _, _]), do: true
  defp digit_repeated_at_least_once?([_, _, d, d, d, d]), do: true
  defp digit_repeated_at_least_once?([_, _, d, d, d, _]), do: true
  defp digit_repeated_at_least_once?([_, _, d, d, _, _]), do: true
  defp digit_repeated_at_least_once?([_, _, _, d, d, d]), do: true
  defp digit_repeated_at_least_once?([_, _, _, d, d, _]), do: true
  defp digit_repeated_at_least_once?([_, _, _, _, d, d]), do: true
  defp digit_repeated_at_least_once?([_, _, _, _, _, _]), do: false

  defp digit_repeated_exactly_once?(password) when is_list(password) do
    count = password
      |> Enum.reduce(%{}, fn digit, acc ->
        Map.update(acc, digit, 1, &(&1 + 1))
      end)
      |> Enum.filter(fn {_digit, count} ->
        count == 2
      end)
      |> length()

    count >= 1
  end

  @doc """
  Transforms an integer into the password representation.
  """
  @spec to_password(raw) :: password
  def to_password(integer) do
    case do_to_password(integer, []) do
      password when length(password) <= 6 ->
        [_] ++ leading_zeroes = for _ <- length(password)..6, do: 0
        leading_zeroes ++ password
      password ->
        raise "invalid password length: #{inspect(password)}"
    end
  end

  defp do_to_password(0, acc) do
    acc
  end

  defp do_to_password(integer, acc) do
    rest = Integer.floor_div(integer, 10)
    digit = integer - (rest * 10)
    do_to_password(rest, [digit] ++ acc)
  end
end

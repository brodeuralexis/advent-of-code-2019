defmodule Advent.Day8.SpaceImageFormat do
  @moduledoc """
  A module for encoding and decoding SIF (Space Image Format encoding) images.

  A SIF image is encoded as a list of 3 digit integers, including left padding
  zeroes.

  To decode an image, its dimensions must be known in advance.
  """

  defstruct [:width, :height, :layers]

  @typedoc """
  Raw image data.
  """
  @type raw :: String.t

  @typedoc """
  The pixel data in the Space Image Format.
  """
  @type pixel :: 0 | 1 | 2

  @typedoc """
  A row of pixels in the Space Image Format.
  """
  @type row :: [pixel]

  @typedoc """
  A layer of the Space Image Format.
  """
  @type layer :: [row]

  @typedoc """
  The data of an image in the Space Image Format.
  """
  @type t :: %__MODULE__{
    width: integer,
    height: integer,
    layers: [layer]
  }

  @doc """
  Parses the given raw image into its Space Image Format representation.

  If the raw data is not valid according to the SIF specifications or the width
  and height that are provided are invalid, an error is raised.

  ## Example

      ```iex
      iex> parse("111222000111", width: 3, height: 2)
      %#{__MODULE__}{
        width: 3,
        height: 2,
        layers: [
          [[1, 1, 1], [2, 2, 2]],
          [[0, 0, 0], [1, 1, 1]]
        ]
      }
      ```
  """
  @spec parse(raw, width: integer, height: integer) :: t
  def parse(raw, width: width, height: height) do
    layers = raw
      |> String.trim()
      |> to_charlist()
      |> Enum.chunk_every(width * height)
      |> Enum.with_index()
      |> Enum.map(fn {raw, layer} ->
        parse_layer(raw, width: width, height: height, layer: layer)
      end)

    %__MODULE__{width: width, height: height, layers: layers}
  end

  @spec parse_layer(raw, term) :: layer
  defp parse_layer(raw, width: width, height: height, layer: layer) do
    rows = raw
      |> Enum.chunk_every(width)
      |> Enum.with_index()
      |> Enum.map(fn {raw, row} ->
        parse_row(raw, width: width, layer: layer, row: row)
      end)

    if length(rows) != height do
      raise "invalid height, expected #{height} but got #{length(rows)} for layer #{layer}"
    end

    rows
  end

  @spec parse_row(raw, term) :: row
  defp parse_row(raw, width: width, layer: layer, row: row) do
    row = raw
      |> Stream.chunk_every(1)
      |> Stream.with_index()
      |> Stream.map(fn {raw, column} ->
        parse_pixel(raw, at: [layer: layer, row: row, column: column])
      end)
      |> Enum.to_list()

    if length(row) != width do
      raise "invalid width for row #{row}, expected #{width} but got #{length(row)} for layer #{layer}"
    end

    row
  end

  @spec parse_pixel(raw, row: integer, column: integer) :: pixel
  defp parse_pixel(raw, opts)

  for pixel <- [0, 1, 2] do
    defp parse_pixel(unquote(to_charlist(pixel)), _opts) do
      unquote(pixel)
    end
  end

  defp parse_pixel(raw, opts) do
    raise (if at = Keyword.get(opts, :at) do
      "invalid pixel data #{raw |> to_string |> inspect()} at #{inspect(at)}"
    else
      "invalid pixel data #{raw |> to_string |> inspect()}"
    end)
  end

  @doc """
  Returns a checksum of the image as per the Space Image Format specification.
  """
  @spec checksum(t) :: integer
  def checksum(image) do
    layer = image.layers
      |> Enum.min_by(&count(&1, 0))

    count(layer, 1) * count(layer, 2)
  end

  defp count(layer, digit) do
    Enum.reduce(layer, 0, fn row, count ->
      Enum.reduce(row, count, fn
        ^digit, count -> count + 1
        _, count -> count
      end)
    end)
  end

  @doc """
  Decodes the image into its singular layer.
  """
  @spec decode(t) :: layer
  def decode(%__MODULE__{width: width, height: height} = image) do
    for row <- 0..(height - 1) do
      for column <- 0..(width - 1) do
        get_decoded_pixel(image, row, column)
      end
    end
  end

  @spec get_decoded_pixel(t, integer, integer) :: pixel
  defp get_decoded_pixel(%__MODULE__{layers: layers}, row, column) do
    Enum.reduce_while(layers, 2, fn layer, acc ->
      case get_pixel(layer, row, column) do
        2 -> {:cont, acc}
        pixel -> {:halt, pixel}
      end
    end)
  end

  @spec get_pixel(layer, integer, integer) :: pixel
  defp get_pixel(layer, row, column) do
    layer
    |> Enum.at(row)
    |> Enum.at(column)
  end
end

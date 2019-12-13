defmodule Advent.Day2.Instruction do
  defstruct [:code, :parameters]

  @type intcode :: [integer]
  @type parameter_mode :: :positional | :immediate | :relative

  @type t :: any

  @parameter_size 10
  @code_size 100
  @default_parameter_mode :positional

  require Advent.Day2.Instruction.Debug
  import Advent.Day2.Instruction.Debug, only: [debug: 1]

  @doc """
  Decodes the given integer into an instruction.
  """
  @spec decode(integer) :: t
  def decode(integer) when is_integer(integer) do
    decode_instruction(integer)
  end

  @doc """
  Steps a single instruction from a slice of memory as the given program and
  returns new information for the interpreter.
  """
  @spec run(t, intcode, intcode, integer) :: :halt | {:continue, memory: intcode, size: integer}
  def run(instruction, program, memory, offset)

  def run(%__MODULE__{code: 99} = instruction, _program, _memory, _offset) do
    debug do
      nil
    end

    :halt
  end

  def run(%__MODULE__{code: 1} = instruction, [left, right, result] ++ _, memory, offset) do
    left_value = get_parameter(instruction, :left, left, memory, offset)
    right_value = get_parameter(instruction, :right, right, memory, offset)

    memory = set_parameter(instruction, :result, result, left_value + right_value, memory, offset)

    debug do
      parameter :left
      parameter :right
      result left_value + right_value
    end

    {:continue, memory: memory, size: 4}
  end

  def run(%__MODULE__{code: 2} = instruction, [left, right, result] ++ _, memory, offset) do
    left_value = get_parameter(instruction, :left, left, memory, offset)
    right_value = get_parameter(instruction, :right, right, memory, offset)

    memory = set_parameter(instruction, :result, result, left_value * right_value, memory, offset)

    debug do
      parameter :left
      parameter :right
      result left_value + right_value
    end

    {:continue, memory: memory, size: 4}
  end

  def run(%__MODULE__{code: 3} = instruction, [at] ++ _, memory, offset) do
    at_value = case get_parameter_mode(instruction, :at) do
      :immediate ->
        raise "cannot use relative addressing with an input instruction"
      :relative ->
        offset + at
      :positional ->
        at
    end

    debug do
      parameter :at
    end

    {:input, at: at_value, memory: memory, size: 2}
  end

  def run(%__MODULE__{code: 4} = instruction, [output] ++ _, memory, offset) do
    output_value = get_parameter(instruction, :output, output, memory, offset)

    debug do
      parameter :output
    end

    {:output, value: output_value, memory: memory, size: 2}
  end

  def run(%__MODULE__{code: 5} = instruction, [condition, to] ++ _, memory, offset) do
    condition_value = get_parameter(instruction, :condition, condition, memory, offset)
    to_value = get_parameter(instruction, :to, to, memory, offset)

    debug do
      parameter :condition
      parameter :to
    end

    if condition_value != 0 do
      {:jump, memory: memory, to: to_value}
    else
      {:continue, memory: memory, size: 3}
    end
  end

  def run(%__MODULE__{code: 6} = instruction, [condition, to] ++ _, memory, offset) do
    condition_value = get_parameter(instruction, :condition, condition, memory, offset)
    to_value = get_parameter(instruction, :to, to, memory, offset)

    debug do
      parameter :condition
      parameter :to
    end

    if condition_value == 0 do
      {:jump, memory: memory, to: to_value}
    else
      {:continue, memory: memory, size: 3}
    end
  end

  def run(%__MODULE__{code: 7} = instruction, [left, right, result] ++ _, memory, offset) do
    left_value = get_parameter(instruction, :left, left, memory, offset)
    right_value = get_parameter(instruction, :right, right, memory, offset)

    memory = set_parameter(instruction, :result, result, (if left_value < right_value, do: 1, else: 0), memory, offset)

    debug do
      parameter :left
      parameter :right
      result left < right_value
    end

    {:continue, memory: memory, size: 4}
  end

  def run(%__MODULE__{code: 8} = instruction, [left, right, result] ++ _, memory, offset) do
    left_value = get_parameter(instruction, :left, left, memory, offset)
    right_value = get_parameter(instruction, :right, right, memory, offset)

    memory = set_parameter(instruction, :result, result, (if left_value == right_value, do: 1, else: 0), memory, offset)

    debug do
      parameter :left
      parameter :right
      result left_value == right_value
    end

    {:continue, memory: memory, size: 4}
  end

  def run(%__MODULE__{code: 9} = instruction, [relative_base_offset] ++ _, memory, offset) do
    relative_base_offset_value = get_parameter(instruction, :offset, relative_base_offset, memory, offset)

    debug do
      parameter :offset
    end

    {:continue, memory: memory, size: 2, relative_base_offset: relative_base_offset_value}
  end

  def run(%__MODULE__{} = instruction, program, memory, _offset) do
    position = length(memory) - length(program) - 1

    debug do
      nil
    end

    raise "invalid instruction at #{position}: #{inspect(instruction)}"
  end

  @doc """
  Returns the mode of the parameter with the given indice.
  """
  @spec get_parameter_mode(t, integer) :: parameter_mode
  def get_parameter_mode(%__MODULE__{parameters: parameters}, index) when is_integer(index) do
    Enum.at(parameters, index, @default_parameter_mode)
  end

  @spec get_parameter_mode(t, atom) :: parameter_mode
  def get_parameter_mode(%__MODULE__{} = instruction, :left), do: get_parameter_mode(instruction, 0)
  def get_parameter_mode(%__MODULE__{} = instruction, :right), do: get_parameter_mode(instruction, 1)
  def get_parameter_mode(%__MODULE__{} = instruction, :result), do: get_parameter_mode(instruction, 2)
  def get_parameter_mode(%__MODULE__{} = instruction, :input), do: get_parameter_mode(instruction, 0)
  def get_parameter_mode(%__MODULE__{} = instruction, :output), do: get_parameter_mode(instruction, 0)
  def get_parameter_mode(%__MODULE__{} = instruction, :condition), do: get_parameter_mode(instruction, 0)
  def get_parameter_mode(%__MODULE__{} = instruction, :to), do: get_parameter_mode(instruction, 1)
  def get_parameter_mode(%__MODULE__{} = instruction, :offset), do: get_parameter_mode(instruction, 0)
  def get_parameter_mode(%__MODULE__{} = instruction, :at), do: get_parameter_mode(instruction, 0)

  def get_parameter(%__MODULE__{} = instruction, index, parameter, memory, offset) do
    instruction
    |> get_parameter_mode(index)
    |> case do
      :positional ->
        position = parameter

        if position < 0 do
          raise "invalid memory address #{position}"
        end

        Enum.at(memory, position, 0)
      :immediate ->
        parameter
      :relative ->
        position = offset + parameter

        if position < 0 do
          raise "invalid memory address #{position}"
        end

        Enum.at(memory, position, 0)
    end
  end

  def input() do
    case IO.gets("input> ") do
      :eof ->
        raise "unexpected eof when reading input"
      {:error, reason} ->
        raise "unexpected error when reading input: #{inspect(reason)}"
      data ->
        data
        |> String.trim()
        |> String.to_integer()
    end
  end

  def output(value) do
    IO.puts("#{value}")
  end

  def set_parameter(%__MODULE__{} = instruction, index, parameter, value, memory, offset) do
    position = instruction
      |> get_parameter_mode(index)
      |> case do
        :positional ->
          parameter
        :immediate ->
          raise "cannot write to an immediate parameter: #{inspect(instruction)}"
        :relative ->
          offset + parameter
      end

    if position < 0 do
      raise "invalid memory address #{position}"
    end

    padding = if position >= length(memory) do
      for _ <- length(memory)..position, do: 0
    else
      []
    end

    List.replace_at(memory ++ padding, position, value)
  end

  defp decode_instruction(integer) do
    parameters = Integer.floor_div(integer, @code_size)
    code = integer - (parameters * @code_size)

    %__MODULE__{
      code: code,
      parameters: decode_parameters(parameters, [])
    }
  end

  defp decode_parameters(0, parameters) do
    parameters
  end

  defp decode_parameters(integer, parameters) do
    rest = Integer.floor_div(integer, @parameter_size)
    parameter = integer - (rest * @parameter_size)

    decode_parameters(rest, parameters ++ [case parameter do
      0 -> :positional
      1 -> :immediate
      2 -> :relative
      n -> raise "invalid addressing mode: #{n}"
    end])
  end
end

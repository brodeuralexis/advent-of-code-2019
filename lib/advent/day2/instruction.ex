defmodule Advent.Day2.Instruction do
  defstruct [:code, :parameters]

  @type intcode :: [integer]
  @type parameter_mode :: :positional | :immediate

  @type t :: any

  @parameter_size 10
  @code_size 100
  @default_parameter_mode :positional

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
  @spec run(t, intcode, intcode) :: :halt | {:continue, memory: intcode, size: integer}
  def run(instruction, program, memory)

  def run(%__MODULE__{code: 99}, _program, _memory) do
    :halt
  end

  def run(%__MODULE__{code: 1} = instruction, [left, right, result] ++ _, memory) do
    left_value = get_parameter(instruction, :left, left, memory)
    right_value = get_parameter(instruction, :right, right, memory)

    memory = set_parameter(instruction, :result, result, left_value + right_value, memory)

    {:continue, memory: memory, size: 4}
  end

  def run(%__MODULE__{code: 2} = instruction, [left, right, result] ++ _, memory) do
    left_value = get_parameter(instruction, :left, left, memory)
    right_value = get_parameter(instruction, :right, right, memory)

    memory = set_parameter(instruction, :result, result, left_value * right_value, memory)

    {:continue, memory: memory, size: 4}
  end

  def run(%__MODULE__{code: 3} = _instruction, [at] ++ _, memory) do
    {:input, at: at, memory: memory, size: 2}
  end

  def run(%__MODULE__{code: 4} = instruction, [output] ++ _, memory) do
    value = get_parameter(instruction, :output, output, memory)

    {:output, value: value, memory: memory, size: 2}
  end

  def run(%__MODULE__{code: 5} = instruction, [condition, to] ++ _, memory) do
    condition_value = get_parameter(instruction, :condition, condition, memory)
    to_value = get_parameter(instruction, :to, to, memory)

    if condition_value != 0 do
      {:jump, memory: memory, to: to_value}
    else
      {:continue, memory: memory, size: 3}
    end
  end

  def run(%__MODULE__{code: 6} = instruction, [condition, to] ++ _, memory) do
    condition_value = get_parameter(instruction, :condition, condition, memory)
    to_value = get_parameter(instruction, :to, to, memory)

    if condition_value == 0 do
      {:jump, memory: memory, to: to_value}
    else
      {:continue, memory: memory, size: 3}
    end
  end

  def run(%__MODULE__{code: 7} = instruction, [left, right, result] ++ _, memory) do
    left_value = get_parameter(instruction, :left, left, memory)
    right_value = get_parameter(instruction, :right, right, memory)

    memory = set_parameter(instruction, :result, result, (if left_value < right_value, do: 1, else: 0), memory)

    {:continue, memory: memory, size: 4}
  end

  def run(%__MODULE__{code: 8} = instruction, [left, right, result] ++ _, memory) do
    left_value = get_parameter(instruction, :left, left, memory)
    right_value = get_parameter(instruction, :right, right, memory)

    memory = set_parameter(instruction, :result, result, (if left_value == right_value, do: 1, else: 0), memory)

    {:continue, memory: memory, size: 4}
  end

  def run(%__MODULE__{} = instruction, program, memory) do
    position = Enum.count(memory) - Enum.count(program) - 1

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

  def get_parameter(%__MODULE__{} = instruction, index, parameter, memory) do
    instruction
    |> get_parameter_mode(index)
    |> case do
      :positional ->
        Enum.fetch!(memory, parameter)
      :immediate ->
        parameter
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

  def set_parameter(%__MODULE__{} = instruction, index, parameter, value, memory) do
    instruction
    |> get_parameter_mode(index)
    |> case do
      :positional ->
        List.replace_at(memory, parameter, value)
      :immediate ->
        raise "cannot write to an immediate parameter: #{inspect(instruction)}"
    end
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
      n -> raise "invalid addressing mode: #{n}"
    end])
  end
end

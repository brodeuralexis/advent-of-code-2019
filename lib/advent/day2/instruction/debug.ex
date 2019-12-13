defmodule Advent.Day2.Instruction.Debug do
  @debug false

  def code_to_atom(1), do: :add
  def code_to_atom(2), do: :mul
  def code_to_atom(3), do: :in
  def code_to_atom(4), do: :out
  def code_to_atom(5), do: :jump_if_true
  def code_to_atom(6), do: :jump_if_false
  def code_to_atom(7), do: :less_than
  def code_to_atom(8), do: :equal
  def code_to_atom(9), do: :set_relative_base
  def code_to_atom(99), do: :halt
  def code_to_atom(_), do: :unknown

  defmacro debug(do: body) do
    if @debug do
      quote do
        require unquote(__MODULE__)
        import unquote(__MODULE__)

        IO.inspect(var!(instruction).code |> code_to_atom(), label: "instruction")
        IO.inspect(var!(instruction).parameters, label: "parameters")

        unquote(body)

        IO.puts("\n\n")
      end
    else
      quote do
        var!(instruction)
      end
    end
  end

  defmacro address(name) do
    quote do
      IO.inspect(var!(unquote({name, [], nil})), label: "#{unquote(name)}")
    end
  end

  defmacro parameter(name) do
    name_value = name
      |> to_string()
      |> Kernel.<>("_value")
      |> String.to_atom()

    quote do
      IO.inspect(var!(unquote({name, [], nil})), label: "#{unquote(name)}")
      IO.inspect(var!(unquote({name_value, [], nil})), label: "@#{unquote(name)}")
    end
  end

  defmacro result(value) do
    quote do
      IO.inspect(var!(result), label: "result")
      IO.inspect(unquote(value), label: "@result")
    end
  end
end

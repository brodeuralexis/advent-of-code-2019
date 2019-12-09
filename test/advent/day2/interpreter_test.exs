defmodule Advent.Day2.InterpreterTest do
  use ExUnit.Case, async: true

  alias Advent.Day2.Interpreter
  import Interpreter

  doctest Interpreter

  describe "run/1" do
    test "should run `1,0,0,0,99` successfully" do
      {:halt, interpreter} = run(new("1,0,0,0,99"))
      assert get_memory(interpreter) == [2,0,0,0,99]
    end

    test "should run `2,3,0,3,99` successfully" do
      {:halt, interpreter} = run(new("2,3,0,3,99"))
      assert get_memory(interpreter) == [2,3,0,6,99]
    end

    test "should run `2,4,4,5,99,0` successfully" do
      {:halt, interpreter} = run(new("2,4,4,5,99,0"))
      assert get_memory(interpreter) == [2,4,4,5,99,9801]
    end

    test "should run `1,1,1,4,99,5,6,0,99` successfully" do
      {:halt, interpreter} = run(new("1,1,1,4,99,5,6,0,99"))
      assert get_memory(interpreter) == [30,1,1,4,2,5,6,0,99]
    end
  end
end

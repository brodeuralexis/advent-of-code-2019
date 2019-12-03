defmodule Advent.Day2Test do
  use ExUnit.Case, async: true

  alias Advent.Day2
  import Day2

  doctest Day2

  describe "run/1" do
    test "should run `1,0,0,0,99` successfully" do
      assert run("1,0,0,0,99") == [2,0,0,0,99]
    end

    test "should run `2,3,0,3,99` successfully" do
      assert run("2,3,0,3,99") == [2,3,0,6,99]
    end

    test "should run `2,4,4,5,99,0` successfully" do
      assert run("2,4,4,5,99,0") == [2,4,4,5,99,9801]
    end

    test "should run `1,1,1,4,99,5,6,0,99` successfully" do
      assert run("1,1,1,4,99,5,6,0,99") == [30,1,1,4,2,5,6,0,99]
    end
  end
end

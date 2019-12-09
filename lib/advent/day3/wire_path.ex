defmodule Advent.Day3.WirePath do
  @moduledoc """
  The path a wire takes on the wire grid.
  """

  defstruct steps: []

  @typedoc """
  The steps a wire takes through a wire grid.
  """
  @type step :: {:up, integer}
              | {:down, integer}
              | {:left, integer}
              | {:right, integer}

  @typedoc """
  A position in 2D space.
  """
  @type position :: {x :: integer, y :: integer}

  @typedoc """
  The path a wire takes through a wire grid.
  """
  @type t :: %__MODULE__{
    steps: [step]
  }

  @doc """
  Returns a new empty wire path.
  """
  @spec empty() :: t
  def empty do
    %__MODULE__{}
  end

  @doc """
  Adds the given steps to this wire path.
  """
  @spec with_steps(t, [step]) :: t
  def with_steps(%__MODULE__{steps: current_steps} = wire_path, next_steps) do
    %{wire_path|steps: current_steps ++ next_steps}
  end

  @doc """
  Returns the trajectory of this wire path.
  """
  @spec trajectory(t) :: Stream.t(position)
  def trajectory(%__MODULE__{steps: steps}) do
    state = %{x: 0, y: 0, trajectory: []}

    steps
    |> Enum.reduce(state, fn
      {:up, integer}, state ->
        %{state|y: state.y + integer, trajectory: state.trajectory ++ for i <- 1..integer do
          {state.x, state.y + i}
        end}
      {:down, integer}, state ->
        %{state|y: state.y - integer, trajectory: state.trajectory ++ for i <- 1..integer do
          {state.x, state.y - i}
        end}
      {:left, integer}, state ->
        %{state|x: state.x - integer, trajectory: state.trajectory ++ for i <- 1..integer do
          {state.x - i, state.y}
        end}
      {:right, integer}, state ->
        %{state|x: state.x + integer, trajectory: state.trajectory ++ for i <- 1..integer do
          {state.x + i, state.y}
        end}
    end)
    |> Map.fetch!(:trajectory)
  end

  @doc """
  Returns the trajectory to get to a certain position on the wire's path.
  """
  @spec trajectory_to(t, position) :: [position]
  def trajectory_to(wire_path, position) do
    trajectory = wire_path
      |> trajectory()

    trajectory_to = trajectory
      |> Enum.take_while(&(&1 != position))
      |> Kernel.++([position])

    if length(trajectory_to) > length(trajectory) do
      raise "could not find a trajectory to #{inspect(position)}"
    end

    trajectory_to
  end
end

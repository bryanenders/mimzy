defmodule Mimzy.FakeMachine do
  @behaviour Mimzy

  @impl Mimzy
  def handle_event(_event),
    do: nil

  @impl Mimzy
  def init(0),
    do: {:halt, :halted}

  def init(1),
    do: {:cont, :state, nil}

  @impl Mimzy
  def handle_event(:state, :perform, 1, nil),
    do: :continued
end

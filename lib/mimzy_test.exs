defmodule MimzyTest do
  use ExUnit.Case, async: true

  alias Mimzy.FakeMachine

  describe "handle_event/3" do
    test "when the init/1 callback halts the event handling" do
      assert :halted === Mimzy.handle_event(0, :perform, FakeMachine)
    end

    test "when the init/1 callback continues the event handling" do
      assert :continued === Mimzy.handle_event(1, :perform, FakeMachine)
    end
  end
end

# Mimzy

## Installation

Add `:mimzy` to your list of dependencies in `mix.exs`:

```elixir
defp deps do
  [
    {:mimzy, "~> 1.0"}
  ]
end
```

## About

Mimzy is a finite-state machine library for Elixir.  Here is an example:

```elixir
defmodule ButtonMachine do
  @behaviour Mimzy

  def handle_event(:create),
    do: _id = ButtonRepo.insert(count: 0, state: :off)

  def handle_event(event, id),
    do: Mimzy.handle_event(event, id, __MODULE)

  def init(id) do
    button = ButtonRepo.get_and_lock(id)
    {:cont, button.state, button.count}
  end

  def handle_event(:off, :push, id, count) do
    :ok = ButtonRepo.update_and_unlock(id, count: count + 1, state: :on)
    :on
  end

  def handle_event(:on, :push, id, _count) do
    :ok = ButtonRepo.update_and_unlock(id, state: :off)
    :off
  end

  def handle_event(_state, :get_count, _id, count),
    do: count
end
```

## License

This Source Code Form is subject to the terms of the Mozilla Public License,
v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain
one at https://mozilla.org/MPL/2.0/.

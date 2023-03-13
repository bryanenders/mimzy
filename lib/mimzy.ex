defmodule Mimzy do
  @moduledoc """
  A module for working with finite-state machines and defining finite-state
  machine callbacks.

  Unlike `:gen_statem`, which implements the machine as an Erlang process, this
  state machine can be implemented with a distributed storage mechanism such as
  a database.

  ## Example

  The following example shows a simple pushbutton model for a toggling
  pushbutton.  You can push the button and it replies if it went on or off, and
  you can ask for a count of how many times it has been pushed to switch on.

  The following is the complete callback module file `push_button.ex`:

      defmodule PushButton do
        @behaviour Mimzy

        import Ecto.Query, only: [from: 2]

        @impl Mimzy
        def handle_event(:create) do
          {1, [%{id: id}]} = Repo.insert_all("buttons", [[count: 0, state: "off"]], returning: [:id])
          {:ok, id}
        end

        @spec handle_event(Mimzy.event(), Mimzy.id()) :: term
        def handle_event(event, id),
          do: Mimzy.handle_event(event, id, __MODULE__)

        @impl Mimzy
        def init(id) do
          case Repo.one(
                 from b in button_query(id),
                   lock: "FOR UPDATE NOWAIT",
                   select: {b.state, b.count}
                ) do
            {state, count} ->
              {:cont, state, count}

            nil ->
              {:halt, :error}
          end
        end


        @impl Mimzy
        def handle_event("off", :push, id, count) do
          id
          |> button_query()
          |> Repo.update_all(set: [count: count + 1, state: "on"])

          :on
        end

        def handle_event("on", :push, id, count) do
          id
          |> button_query()
          |> Repo.update_all(set: [count: count, state: "off"])

          :off
        end

        def handle_event(_state, {:put_count, new_count}, id, _count) do
          id
          |> button_query()
          |> Repo.update_all(set: [count: new_count])

          :ok
        end

        def handle_event(_state, :delete, id, _count) do
          {1, nil} =
            id
            |> button_query()
            |> Repo.delete_all()

          :ok
        end

        def handle_event(_state, :get_count, _id, count),
          do: count

        @spec button_query(Mimzy.id()) :: Ecto.Query.t()
        defp button_query(id) do
          from b in "buttons", where: b.id == ^id
        end
      end

  Usage would be:

      {:ok, id} = PushButton.handle_event(:create)
      #=> {:ok, 1}

      PushButton.handle_event(:get_count, id)
      #=> 0

      PushButton.handle_event(:push, id)
      #=> :on

      PushButton.handle_event(:get_count, id)
      #=> 1

      PushButton.handle_event(:push, id)
      #=> :off

      PushButton.handle_event({:put_count, 99}, id)
      #=> :ok

      PushButton.handle_event(:get_count, id)
      #=> 99

      PushButton.handle_event(:delete, id)
      #=> :ok

      PushButton.handle_event(:push, id)
      #=> :error
  """
  @type data :: any
  @type event :: any
  @type id :: any
  @type state :: any

  @spec handle_event(event, id, module) :: term
  def handle_event(event, id, module) do
    case module.init(id) do
      {:cont, state, data} ->
        module.handle_event(state, event, id, data)

      {:halt, term} ->
        term
    end
  end

  @doc """
  Called when a state machine event is ready to be handled and the machine is
  in a nonexistent or pseudo state.

  This is the function that would create a new finite-state machine.
  """
  @callback handle_event(event) :: term

  @doc """
  Called when a state machine event is ready to be handled.

  This function is called before `handle_event/4` in order to retrieve the
  state and any machine-associated data.

  The return value is expected to be

    * `{:cont, state, data}` to continue the event handling
    * `{:halt, term}` to halt the event handling and return the `term`
  """
  @callback init(id) :: {:cont, state, data} | {:halt, term}

  @doc """
  This function is called after `init/1`.

  This is the function that would transition a finite-state machine from one
  state to another.
  """
  @callback handle_event(state, event, id, data) :: term

  @optional_callbacks handle_event: 1
end

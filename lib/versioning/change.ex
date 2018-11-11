defmodule Versioning.Change do
  @moduledoc """
  Documentation to come.
  """

  @doc """
  Accepts a `Versioning` struct, and returns a modified `Versioning` struct.

  ## Parameters

    - versioning: A `Versioning` struct.
  """
  @callback change(Versioning.t()) :: Versioning.t()

  defmacro __using__(_opts) do
    quote do
      @behaviour Versioning.Change

      def change(versioning) do
        versioning
      end

      defoverridable Versioning.Change
    end
  end
end

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

      @desc "No Description"

      def change(versioning) do
        versioning
      end

      defoverridable change: 1

      @before_compile Versioning.Change
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def __description__ do
        @desc
      end
    end
  end
end

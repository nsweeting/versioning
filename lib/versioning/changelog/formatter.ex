defmodule Versioning.Changelog.Formatter do
  @moduledoc """
  Documentation to come.
  """

  @doc """
  Accepts a list of changelog versions, a single version, or a single change,
  and returns a formatted version.

  ## Parameters

    - changelog: A changelog map.
  """
  @callback format(
              Versioning.Changelog.t()
              | Versioning.Changelog.version()
              | Versioning.Changelong.change()
            ) :: any()

  defmacro __using__(_opts) do
    quote do
      @behaviour Versioning.Changelog.Formatter
    end
  end
end

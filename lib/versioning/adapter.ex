defmodule Versioning.Adapter do
  @moduledoc """
  Defines a versioning adapter.

  A versioning adapter is used to parse and compare versions. This allows versions
  to be defined in a variety of ways - from semantic, to date based.

  """
  @type t :: module()

  @doc """
  Callback invoked to parse a binary version.

  Returns `{:ok, term}` on success, where `term` will be the adapters representation
  of a version. Returns `:error` if the version cannot be parsed.
  """
  @callback parse(version :: term()) :: {:ok, term()} | :error

  @doc """
  Callback invoked to compare versions.

  Returns `:gt` if the first verison is greater than the second, and `:lt` for
  vice-versa. If the two versions are equal, `:eq` is returned.
  """
  @callback compare(version :: term(), version :: term()) :: :gt | :lt | :eq | :error

  @doc false
  @spec parse(adapter :: Versioning.Adapter.t(), binary()) :: {:ok, term()} | :error
  def parse(adapter, version) do
    adapter.parse(version)
  end

  @doc false
  @spec compare(adapter :: Versioning.Adapter.t(), binary(), binary()) :: :gt | :lt | :eq | :error
  def compare(adapter, version1, version2) do
    adapter.compare(version1, version2)
  end
end

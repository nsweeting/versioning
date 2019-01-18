defmodule Versioning.Adapter.Semantic do
  @moduledoc """
  A versioning adapter for semantic-based versions.

  Under the hood, this adapter uses the `Version` module. For details on the rules
  that are used for parsing and comparison, please see the `Version` module.

  ## Example

      defmodule MyApp.Versioning do
        use Versioning.Schema, adapter: Versioning.Adapter.Semantic

        version "1.0.0" do
          type "Post" do
            change(MyApp.Change)
          end
        end
      end

  """

  @behaviour Versioning.Adapter

  @doc """
  Parses semantic based versions.

  ## Example

        iex> Versioning.Adapter.Semantic.parse("1.0.0")
        {:ok, #Version<1.0.0>}
        iex> Versioning.Adapter.Semantic.parse("foo")
        :error

  """
  @impl Versioning.Adapter
  @spec parse(binary() | Version.t()) :: :error | {:ok, Version.t()}
  def parse(version) when is_binary(version) do
    Version.parse(version)
  end

  def parse(%Version{} = version) do
    {:ok, version}
  end

  def parse(_) do
    :error
  end

  @doc """
  Compares semantic based versions.

  Returns `:gt` if the first verison is greater than the second, and `:lt` for
  vice-versa. If the two versions are equal, `:eq` is returned.

  ## Example

        iex> Versioning.Adapter.Semantic.compare("1.0.1", "1.0.0")
        :gt
        iex> Versioning.Adapter.Semantic.compare("1.0.0", "1.0.1)
        :lt
        iex> Versioning.Adapter.Semantic.compare("1.0.1", "1.0.1")
        :eq

  """
  @impl Versioning.Adapter
  @spec compare(binary() | Version.t(), binary() | Version.t()) :: :eq | :error | :gt | :lt
  def compare(version1, version2) when is_binary(version1) and is_binary(version2) do
    with {:ok, version1} <- parse(version1),
         {:ok, version2} <- parse(version2) do
      compare(version1, version2)
    end
  end

  def compare(%Version{} = version1, %Version{} = version2) do
    Version.compare(version1, version2)
  rescue
    _ -> :error
  end

  def compare(_version1, _version2) do
    :error
  end
end

defmodule Versioning.Adapter.Date do
  @moduledoc """
  A versioning adapter for date-based versions.

  Under the hood, this adapter uses the `Date` module. For details on the rules
  that are used for parsing and comparison, please see the `Date` module.

  ## Example

      defmodule MyApp.Versioning do
        use Versioning.Schema, adapter: Versioning.Adapter.Date

        version "2019-01-01" do
          type "Post" do
            change(MyApp.Change)
          end
        end
      end

  """

  @behaviour Versioning.Adapter

  @doc """
  Parses date based versions using ISO8601 formatting.

  ## Example

        iex> Versioning.Adapters.Date.parse("2019-01-01")
        {:ok, ~D[2019-01-01]}
        iex> Versioning.Adapters.Date.parse("foo")
        :error

  """
  @impl Versioning.Adapter
  @spec parse(binary() | Date.t()) :: :error | {:ok, Date.t()}
  def parse(version) when is_binary(version) do
    case Date.from_iso8601(version) do
      {:ok, _} = result -> result
      _ -> :error
    end
  end

  def parse(%Date{} = version) do
    {:ok, version}
  end

  def parse(_) do
    :error
  end

  @doc """
  Compares date based versions using ISO8601 formatting.

  Returns `:gt` if the first verison is greater than the second, and `:lt` for
  vice-versa. If the two versions are equal, `:eq` is returned. Returns `:error`
  if the version cannot be parsed.

  ## Example

        iex> Versioning.Adapters.Date.compare("2019-01-01", "2018-12-31")
        :gt
        iex> Versioning.Adapters.Date.compare("2018-12-31", "2019-01-01")
        :lt
        iex> Versioning.Adapters.Date.compare("2019-01-01", "2019-01-01")
        :eq
        iex> Versioning.Adapters.Date.compare("foo", "bar")
        :error

  """
  @impl Versioning.Adapter
  @spec compare(binary() | Date.t(), binary() | Date.t()) :: :gt | :lt | :eq | :error
  def compare(version1, version2) when is_binary(version1) and is_binary(version2) do
    with {:ok, version1} <- parse(version1),
         {:ok, version2} <- parse(version2) do
      compare(version1, version2)
    end
  end

  def compare(%Date{} = version1, %Date{} = version2) do
    Date.compare(version1, version2)
  rescue
    _ -> :error
  end

  def compare(_version1, _version2) do
    :error
  end
end

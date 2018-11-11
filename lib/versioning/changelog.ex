defmodule Versioning.Changelog do
  @moduledoc false

  @type change :: %{type: module(), descriptions: [binary()]}
  @type version :: %{version: binary(), changes: [change()]}
  @type t :: [version()]

  @doc false
  @spec build(Versioning.Schema.t()) :: Versioning.Changelog.t()
  def build(schema) do
    Enum.reduce(schema, [], fn {version, changes}, changelog ->
      add_version(changelog, version, changes)
    end)
  end

  @spec with_options(Versioning.Changelog.t(), keyword()) :: any()
  def with_options(changelog, opts) do
    version = Keyword.get(opts, :version)
    type = Keyword.get(opts, :type)
    changelog = fetch_changelog(changelog, version, type)
    format(changelog, opts)
  end

  defp fetch_changelog(changelog, nil, nil) do
    changelog
  end

  defp fetch_changelog(_changelog, nil, type) when is_atom(type) do
    raise ArgumentError, """
    cannot fetch a changelog type without a version.

    type: #{inspect(type)}
    """
  end

  defp fetch_changelog(changelog, version, nil) do
    do_get_version(changelog, version)
  end

  defp fetch_changelog(changelog, version, type) do
    changelog
    |> do_get_version(version)
    |> do_get_version_type(type)
  end

  defp do_get_version(changelog, version) do
    Enum.find(changelog, &(Map.get(&1, :version) == version))
  end

  defp do_get_version_type(version, type) do
    version
    |> Map.get(:changes)
    |> Enum.find(&(Map.get(&1, :type) == type))
  end

  defp add_version(changelog, version, changes) do
    changelog ++ [%{version: version, changes: build_changes(changes)}]
  end

  defp build_changes(changes) do
    Enum.reduce(changes, [], fn
      {type, change}, result when is_atom(change) -> add_change(result, type, [change])
      {type, change}, result -> add_change(result, type, change)
      change, result -> add_change(result, Any, [change])
    end)
  end

  defp add_change(current, type, changes) do
    current ++ [%{type: type, descriptions: build_descriptions(changes)}]
  end

  defp build_descriptions(changes) do
    Enum.reduce(changes, [], fn change, descriptions ->
      descriptions ++ [change.__description__()]
    end)
  end

  defp format(data, opts) do
    case Keyword.get(opts, :formatter) do
      nil -> data
      formatter -> formatter.format(data)
    end
  end
end

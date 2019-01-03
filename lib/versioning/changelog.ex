defmodule Versioning.Changelog do
  @moduledoc """
  Creates changelogs for schemas.

  The changelog is composed of a list of maps that describe the history of
  the schema. For example:

      [
        %{
          version: "1.1.0",
          changes: [
            %{type: Foo, descriptions: ["Changed this.", "Changed that."]}
          ]
        },
        %{
          version: "1.0.0",
          changes: [
            %{type: Foo, descriptions: ["Changed this.", "Changed that."]}
          ]
        }
      ]

  The descriptions associated with each change can be attributed via the
  `@desc` module attribute on a change module. Please see `Versioning.Change`
  for more details.

  Formatters can be used to turn the raw changelog into different formats. Please
  see the `Versioning.Changelog.Formatter` behaviour for more details.

  The `Versioning.Changelog.Markdown` formatter is included with this package.
  """

  @type change :: %{type: module(), descriptions: [binary()]}
  @type version :: %{version: binary(), changes: [change()]}
  @type t :: [version()]

  @doc """
  Builds a changelog of the schema.

  ## Options
    * `:version` - A specific version within the changelog.
    * `:type` - A specific type within the specified version.
    * `:formatter` - A module that adheres to the `Versioning.Changelog.Formatter`
    behaviour.

  ## Examples

      Versioning.Changelog.build(MySchema, formatter: Versioning.Changelog.Markdown)

  """
  @spec build(Versioning.Schema.t()) :: Versioning.Changelog.t()
  def build(schema, opts \\ []) do
    version = Keyword.get(opts, :version)
    type = Keyword.get(opts, :type)
    formatter = Keyword.get(opts, :formatter)

    schema
    |> do_build()
    |> do_fetch(version, type)
    |> do_format(formatter)
  end

  defp do_build(schema) do
    Enum.reduce(schema.__schema__(:down), [], fn {version, types}, changelog ->
      add_version(changelog, version, types)
    end)
  end

  defp add_version(changelog, version, types) do
    changelog ++ [%{version: to_string(version), changes: build_changes(types)}]
  end

  defp build_changes(types) do
    Enum.reduce(types, [], fn {type, changes}, result ->
      add_change(result, type, changes)
    end)
  end

  defp add_change(current, type, changes) do
    current ++ [%{type: type, descriptions: build_descriptions(changes)}]
  end

  defp build_descriptions(changes) do
    Enum.reduce(changes, [], fn {change, _init}, descriptions ->
      descriptions ++ [change.__description__()]
    end)
  end

  defp do_fetch(changelog, nil, nil) do
    changelog
  end

  defp do_fetch(_changelog, nil, type) when is_atom(type) do
    raise Versioning.ChangelogError, """
    cannot fetch a changelog type without a version.

    type: #{inspect(type)}
    """
  end

  defp do_fetch(changelog, version, nil) do
    do_get_version(changelog, version)
  end

  defp do_fetch(changelog, version, type) do
    changelog
    |> do_get_version(version)
    |> do_get_version_type(type)
  end

  defp do_get_version(changelog, version) do
    Enum.find(changelog, &(Map.get(&1, :version) == to_string(version))) ||
      invalid_version!(version)
  end

  defp do_get_version_type(version, type) do
    version
    |> Map.get(:changes)
    |> Enum.find(&(Map.get(&1, :type) == type))
  end

  defp do_format(changelog, nil) do
    changelog
  end

  defp do_format(changelog, formatter) do
    formatter.format(changelog)
  end

  defp invalid_version!(version) do
    raise Versioning.ChangelogError, """
    version cannot be found in schema.

    version: #{inspect(version)}
    """
  end
end

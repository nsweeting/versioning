defmodule Versioning.Schema.Compiler do
  @moduledoc false

  @doc false
  def build(env) do
    schema = Module.get_attribute(env.module, :_schema)
    adapter = Module.get_attribute(env.module, :adapter)

    schema_down =
      schema
      |> Enum.reverse()
      |> Enum.reduce([], &do_build(adapter, &1, &2))
      |> Enum.map(&escape_version/1)
      |> Enum.reverse()

    {schema_down, reverse(schema_down)}
  end

  defp do_build(adapter, {:version, version}, schema) do
    case Versioning.Adapter.parse(adapter, version) do
      {:ok, version} ->
        validate_version!(schema, adapter, version)
        [{version, []} | schema]

      :error ->
        raise Versioning.CompileError, """
        invalid version format for #{inspect(adapter)}.

        version: #{inspect(version)}
        """
    end
  end

  defp do_build(_adapter, {:type, type}, [{version, types} | schema]) do
    validate_type!(types, type)
    types = types ++ [{type, []}]
    [{version, types} | schema]
  end

  defp do_build(_adapter, {:change, change, init}, [{version, objects} | schema]) do
    [{object, changes} | objects] = Enum.reverse(objects)
    validate_change!(change)
    changes = changes ++ [{change, init}]
    [{version, objects ++ [{object, changes}]} | schema]
  end

  defp reverse(schema) do
    schema
    |> Enum.map(fn {version, objects} ->
      objects =
        Enum.map(objects, fn
          {object, changes} -> {object, Enum.reverse(changes)}
          changes -> changes
        end)

      {version, Enum.reverse(objects)}
    end)
    |> Enum.reverse()
  end

  defp validate_version!(schema, adapter, version) do
    improper_order =
      Enum.any?(schema, fn {current_version, _types} ->
        case Versioning.Adapter.compare(adapter, version, current_version) do
          :gt -> true
          _ -> false
        end
      end)

    if improper_order do
      raise Versioning.CompileError, """
      versions are incorrectly ordered.

      version: #{inspect(version)}
      """
    end

    :ok
  end

  defp validate_type!(types, type) when is_binary(type) do
    already_exists =
      Enum.member?(types, fn
        {current_type, _changes} -> current_type == type
        _ -> false
      end)

    if already_exists do
      raise Versioning.CompileError, """
      cannot have more than one type in a version of a schema.

      type: #{inspect(type)}
      """
    end

    :ok
  end

  defp validate_type!(_types, type) do
    raise Versioning.CompileError, """
    expected type to be a string.

    type: #{inspect(type)}
    """
  end

  defp validate_change!(change) when is_atom(change), do: :ok

  defp validate_change!(change) do
    raise Versioning.CompileError, """
    expected change to be an atom.

    change: #{inspect(change)}
    """
  end

  defp escape_version({version, changes}) do
    {Macro.escape(version), changes}
  end
end

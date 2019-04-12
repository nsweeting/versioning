defmodule Versioning.Schema.Compiler do
  @moduledoc false

  @doc false
  def build(env) do
    schema = Module.get_attribute(env.module, :_schema)
    adapter = Module.get_attribute(env.module, :adapter)
    latest = Module.get_attribute(env.module, :latest)

    schema_down = do_build(adapter, schema)
    schema_up = do_reverse(schema_down)
    latest = do_latest(adapter, schema_down, latest)

    {schema_down, schema_up, latest}
  end

  defp do_build(adapter, schema) do
    schema
    |> Enum.reverse()
    |> Enum.reduce([], &do_build(adapter, &1, &2))
    |> Enum.reverse()
  end

  defp do_build(adapter, {:version, raw_version}, schema) do
    case Versioning.Adapter.parse(adapter, raw_version) do
      {:ok, parsed_version} ->
        validate_version!(schema, adapter, parsed_version)
        [{parsed_version, raw_version, []} | schema]

      :error ->
        raise Versioning.CompileError, """
        invalid version format for #{inspect(adapter)}.

        version: #{inspect(raw_version)}
        """
    end
  end

  defp do_build(_adapter, {:type, type}, [{version, raw_version, types} | schema]) do
    validate_type!(types, type)
    types = types ++ [{type, []}]
    [{version, raw_version, types} | schema]
  end

  defp do_build(_adapter, {:change, change, init}, [{version, raw_version, objects} | schema]) do
    [{object, changes} | objects] = Enum.reverse(objects)
    validate_change!(change)
    changes = changes ++ [{change, init}]
    [{version, raw_version, objects ++ [{object, changes}]} | schema]
  end

  defp do_reverse(schema) do
    schema
    |> Enum.map(fn {version, raw_version, objects} ->
      objects =
        Enum.map(objects, fn
          {object, changes} -> {object, Enum.reverse(changes)}
          changes -> changes
        end)

      {version, raw_version, Enum.reverse(objects)}
    end)
    |> Enum.reverse()
  end

  defp validate_version!(schema, adapter, version) do
    improper_order =
      Enum.any?(schema, fn {current_version, _raw_version, _types} ->
        case Versioning.Adapter.compare(adapter, version, current_version) do
          :lt -> false
          _ -> true
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
      Enum.any?(types, fn
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

  defp validate_change!(change) when is_atom(change) do
    try do
      change.module_info[:attributes]
      |> Keyword.get(:behaviour, [])
      |> Enum.member?(Versioning.Change)
      |> case do
        true -> :ok
        false -> invalid_change_module!(change)
      end
    rescue
      _ -> invalid_change_module!(change)
    end
  end

  defp validate_change!(change) do
    raise Versioning.CompileError, """
    expected change to be an atom.

    change: #{inspect(change)}
    """
  end

  defp invalid_change_module!(change) do
    raise Versioning.CompileError, """
    expected change to implement the Versioning.Change behaviour.

    change: #{inspect(change)}
    """
  end

  defp do_latest(_adapter, [{latest, _, _} | _], nil) do
    latest
  end

  defp do_latest(adapter, schema, latest) do
    validate_latest!(adapter, schema, latest)
    {:ok, parsed_latest} = Versioning.Adapter.parse(adapter, latest)
    parsed_latest
  end

  defp validate_latest!(adapter, schema, latest) do
    case Versioning.Adapter.parse(adapter, latest) do
      {:ok, parsed_latest} ->
        if Enum.find(schema, fn {version, _raw_version, _types} -> parsed_latest == version end) do
          :ok
        else
          raise Versioning.CompileError, """
          invalid @latest schema attribute. version could not be found.

          version: #{inspect(latest)}
          """
        end

      :error ->
        raise Versioning.CompileError, """
        invalid @latest schema attribute. version could not be parsed.

        version: #{inspect(latest)}
        """
    end
  end
end

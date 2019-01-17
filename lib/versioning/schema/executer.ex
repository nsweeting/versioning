defmodule Versioning.Schema.Executer do
  @moduledoc false

  @doc false
  def run(schema, versionings) when is_list(versionings) do
    Enum.map(versionings, &run(schema, &1))
  end

  def run(schema, versioning) do
    adapter = schema.__schema__(:adapter)

    with {:ok, target, current} <- parse_versions(adapter, versioning) do
      versioning = %{versioning | schema: schema, parsed_target: target, parsed_current: current}

      case Versioning.Adapter.compare(adapter, target, current) do
        :lt -> run(:down, schema, versioning)
        :gt -> run(:up, schema, versioning)
        :eq -> {:ok, versioning}
      end
    end
  end

  @doc false
  def run(direction, schema, %Versioning{} = versioning) do
    schema = schema.__schema__(direction)

    with {:ok, schema} <- locate_current(schema, versioning.parsed_current) do
      do_run(direction, schema, versioning)
    end
  end

  defp do_run(
         direction,
         [{version, types} | _schema],
         %Versioning{parsed_target: target} = versioning
       )
       when target == version do
    {:ok, do_run_types(direction, types, versioning)}
  end

  defp do_run(direction, [{_version, types} | schema], versioning) do
    versioning = do_run_types(direction, types, versioning)
    do_run(direction, schema, versioning)
  end

  defp do_run(_direction, [], _versioning) do
    {:error, %Versioning.ExecutionError{message: "no matching version found in schema."}}
  end

  defp do_run_types(_direction, [], versioning) do
    versioning
  end

  defp do_run_types(direction, [{"All!", changes} | types], versioning) do
    versioning = do_run_changes(direction, changes, versioning)
    do_run_types(direction, types, versioning)
  end

  defp do_run_types(direction, [{type1, changes} | types], %Versioning{type: type2} = versioning)
       when type1 == type2 do
    versioning = do_run_changes(direction, changes, versioning)
    do_run_types(direction, types, versioning)
  end

  defp do_run_types(direction, [_type | types], versioning) do
    do_run_types(direction, types, versioning)
  end

  defp do_run_changes(_direction, [], versioning) do
    versioning
  end

  defp do_run_changes(direction, changes, versioning) do
    Enum.reduce(changes, versioning, fn {change, opts}, versioning ->
      apply(Versioning.Change, direction, [versioning, change, opts])
    end)
  end

  defp parse_versions(adapter, versioning) do
    with {:ok, target} <- Versioning.Adapter.parse(adapter, versioning.target),
         {:ok, current} <- Versioning.Adapter.parse(adapter, versioning.current) do
      {:ok, target, current}
    else
      _ -> {:error, %Versioning.ExecutionError{message: "invalid versions provided."}}
    end
  end

  defp locate_current(schema, version) do
    schema
    |> Enum.drop_while(fn {v, _} -> version != v end)
    |> case do
      [] ->
        {:error, %Versioning.ExecutionError{message: "current version not found in schema."}}

      [_ | schema] ->
        {:ok, schema}
    end
  end
end

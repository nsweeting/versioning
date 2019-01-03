defmodule Versioning.Schema.Executer do
  @moduledoc false

  @doc false
  def run(schema, versionings) when is_list(versionings) do
    Enum.map(versionings, &run(schema, &1))
  end

  def run(schema, versioning) do
    case Version.compare(versioning.target, versioning.current) do
      :lt -> run(:down, schema, versioning)
      :gt -> run(:up, schema, versioning)
      :eq -> versioning
    end
  end

  @doc false
  def run(direction, schema, %Versioning{} = versioning) do
    schema = schema.__schema__(direction)
    schema = locate_current(schema, versioning.current)
    do_run(direction, schema, versioning)
  end

  defp do_run(
         direction,
         [{version, types} | _schema],
         %Versioning{target: target} = versioning
       )
       when target == version do
    do_run_types(direction, types, versioning)
  end

  defp do_run(direction, [{_version, types} | schema], versioning) do
    versioning = do_run_types(direction, types, versioning)
    do_run(direction, schema, versioning)
  end

  defp do_run(_direction, [], _versioning) do
    raise Versioning.ExecutionError, "no matching version found in schema."
  end

  defp do_run_types(_direction, [], versioning) do
    versioning
  end

  defp do_run_types(direction, [{Any, changes} | types], versioning) do
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
      versioning = %{versioning | changed: true}
      apply(change, direction, [versioning, opts])
    end)
  end

  defp locate_current(schema, version) do
    schema
    |> Enum.drop_while(fn {v, _} -> version != v end)
    |> case do
      [] -> raise Versioning.ExecutionError, "current version not found in schema."
      [_ | schema] -> schema
    end
  end
end

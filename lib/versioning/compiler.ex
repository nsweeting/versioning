defmodule Versioning.Compiler do
  @moduledoc false

  @type action :: :version | :change_all | :change

  @spec compile!(Versioning.Schema.t(), action(), any()) :: {binary(), Versioning.Schema.t()}
  def compile!(schema, :version, [version]) do
    schema = [{version, []} | schema]
    validate_version!(schema, version)
    {version, schema}
  end

  def compile!(schema, :change_all, [change]) do
    schema = add_change(schema, change)
    version = working_version(schema)

    validate_change!(schema, change)
    validate_change_all!(schema)

    {version, schema}
  end

  def compile!(schema, :change, [type, change]) do
    schema = add_change(schema, {type, change})
    version = working_version(schema)

    validate_type!(schema, type)
    validate_change!(schema, change)

    {version, schema}
  end

  defp add_change(schema, change) do
    [{current_version, current_changes} | history] = schema
    updated_changes = current_changes ++ [change]
    [{current_version, updated_changes} | history]
  end

  defp working_version([{version, _} | _]) do
    version
  end

  defp validate_change_all!([{version, changes} | _]) do
    if Enum.count(changes, &is_atom(&1)) > 1 do
      raise ArgumentError, """
      cannot have more than one change_all in a version.

      version: #{inspect(version)}
      """
    end

    :ok
  end

  defp validate_version!(schema, version) when is_binary(version) do
    count =
      Enum.count(schema, fn
        {current_version, _change} -> current_version == version
        _ -> false
      end)

    if count > 1 do
      raise ArgumentError, """
      cannot have more than one version in a schema.

      version: #{inspect(version)}
      """
    end

    :ok
  end

  defp validate_version!(_schema, version) do
    raise ArgumentError, """
    expected version to be a string.

    version: #{inspect(version)}
    """
  end

  defp validate_type!([{version, changes} | _history], type) when is_atom(type) do
    count =
      Enum.count(changes, fn
        {current_type, _change} -> current_type == type
        _ -> false
      end)

    if count > 1 do
      raise ArgumentError, """
      cannot have more than one change for a given version and type.

      version: #{inspect(version)}
      type: #{inspect(type)}
      """
    end

    :ok
  end

  defp validate_type!([{version, _changes} | _history], type) do
    raise ArgumentError, """
    expected type to be an atom.

    version: #{inspect(version)}
    type: #{inspect(type)}
    """
  end

  defp validate_change!(_schema, change) when is_atom(change), do: :ok

  defp validate_change!(schema, changes) when is_list(changes) do
    Enum.each(changes, &validate_change!(schema, &1))
    :ok
  end

  defp validate_change!([{version, _changes} | _history], change) do
    raise ArgumentError, """
    expected change to be an atom or list of atoms.

    version: #{inspect(version)}
    change: #{inspect(change)}
    """
  end
end

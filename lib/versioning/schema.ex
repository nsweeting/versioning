defmodule Versioning.Schema do
  @moduledoc """
  Documentation to come.
  """

  alias Versioning.Compiler

  @type change :: [atom() | {atom(), atom() | [atom()]}]

  @type version :: {binary(), change()}

  @type t :: [version()]

  defmacro __using__(_opts) do
    quote do
      import Versioning.Schema

      @versions []
      @schema []

      @before_compile Versioning.Schema
    end
  end

  defmacro version(version, do: block) do
    quote do
      {_version, schema} = Compiler.compile!(@schema, :version, [unquote(version)])

      @versions [unquote(version) | @versions]
      @schema schema

      unquote(block)
    end
  end

  defmacro change(type, do: change) do
    quote bind_quoted: [type: type, change: change] do
      {version, schema} = Compiler.compile!(@schema, :change, [type, change])

      defp change(unquote(version), unquote(type), %{target: target, type: type} = versioning)
           when target == unquote(version) and type == unquote(type) do
        {:halt, Versioning.change(versioning, unquote(change))}
      end

      defp change(unquote(version), unquote(type), %{type: type} = versioning)
           when type == unquote(type) do
        {:continue, Versioning.change(versioning, unquote(change))}
      end

      @schema schema
    end
  end

  defmacro change_all(do: change) do
    quote bind_quoted: [change: change] do
      {version, schema} = Compiler.compile!(@schema, :change_all, [change])

      defp change_all(unquote(version), %{target: target} = versioning)
           when target == unquote(version) do
        Versioning.change(versioning, unquote(change))
      end

      defp change_all(unquote(version), versioning) do
        Versioning.change(versioning, unquote(change))
      end

      @schema schema
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      @versions Enum.reverse(@versions)
      @schema Enum.reverse(@schema)

      @doc """
      Runs a versioning through the schema.

      ## Parameters
        - versioning: A `Versioning` struct.
      """
      def run(versioning) do
        do_run({:continue, versioning}, __versions__())
      end

      defp do_run({:halt, versioning}, _versions) do
        versioning
      end

      defp do_run({_, versioning}, []) do
        raise Versioning.Error, "no matching version found in schema."
      end

      defp do_run({:continue, versioning}, [version | versions]) do
        versioning = change_all(version, versioning)
        result = change(version, versioning.type, versioning)
        do_run(result, versions)
      end

      defp change_all(_version, versioning) do
        versioning
      end

      defp change(version, _type, %{target: target} = versioning)
           when version == target do
        {:halt, versioning}
      end

      defp change(_version, _type, versioning) do
        {:continue, versioning}
      end

      def __versions__ do
        @versions
      end

      def __schema__ do
        @schema
      end
    end
  end
end

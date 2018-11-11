defmodule Versioning.Schema do
  @moduledoc """
  Documentation to come.
  """

  alias Versioning.{Compiler, Changelog}

  @type change :: [atom() | {atom(), atom() | [atom()]}]

  @type version :: {binary(), change()}

  @type t :: [version()]

  @doc """
  Returns a list of versions within the schema.
  """
  @callback __versions__() :: [binary()]

  @doc """
  Returns a raw representation of the schema.
  """
  @callback __schema__() :: [version()]

  @doc """
  Runs a versioning through the schema.

  ## Parameters
    - versioning: A `Versioning` struct.
  """
  @callback run(versioning :: Versioning.t()) :: Versioning.t()

  @doc """
  Returns the changelog for the schema. The changelog represents a list of maps
  that describe the history of the schema. For example:

      [
        %{
          version: "1",
          changes: [
            %{type: Foo, descriptions: ["Changed this.", "Changed that."]}
          ]
        }
      ]

  The descriptions associated with each change can be attributed via the
  `@desc` module attribute on a change module. Please see `Versioning.Change`
  for more details.
  """
  @callback changelog() :: Versioning.Changelog.t()

  @doc """
  Returns a changelog using the given options.

  ## Options
    * `:version` - A specific version within the changelog.
    * `:type` - A specific type within the specified version.
    * `:formatter` - A module that adheres to the `Versioning.Changelog.Formatter` behaviour.
    By default, `Versioning` includes the `Versioning.Changelog.Markdown` formatter.
  """
  @callback changelog(keyword()) :: any()

  defmacro __using__(_opts) do
    quote do
      @behaviour Versioning.Schema

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
      @changelog Changelog.build(@schema)

      def run(versioning) do
        do_run({:continue, versioning}, @versions)
      end

      def __versions__ do
        @versions
      end

      def __schema__ do
        @schema
      end

      def changelog do
        @changelog
      end

      def changelog(opts) do
        Changelog.with_options(@changelog, opts)
      end

      defp do_run({:halt, versioning}, _versions) do
        versioning
      end

      defp do_run(_, []) do
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
    end
  end
end

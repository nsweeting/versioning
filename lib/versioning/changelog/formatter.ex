defmodule Versioning.Changelog.Formatter do
  @moduledoc """
  Defines a versioning changelog formatter.

  A changelog formatter is used to create custom outputs from raw changelog data.
  Included with this package is the `Versioning.Changelog.Markdown` ormatter.
  This accepts the standard changelog data structure, and converts it to a simple
  markdown format.

  ## Example

      defmodule MyApp.SomeFormatter do
        use Versioning.Changelog.Formatter

        @impl Versioning.Changelog.Formatter
        def format(changelog) do
          # Do custom formatting
        end
      end

  Please see the `Versioning.Changelog.Markdown` for an example of its use.
  """

  @doc """
  Formats a changelog.

  Accepts a list of changelog versions, a single version, or a single change,
  and returns a custom formatted version.
  """
  @callback format(
              Versioning.Changelog.t()
              | Versioning.Changelog.version()
              | Versioning.Changelog.change()
            ) :: any()

  defmacro __using__(_opts) do
    quote do
      @behaviour Versioning.Changelog.Formatter
    end
  end
end

defmodule Versioning.Changelog.Markdown do
  @moduledoc """
  Formats a changelog into a markdown version.
  """

  use Versioning.Changelog.Formatter

  @impl Versioning.Changelog.Formatter
  @spec format(binary() | maybe_improper_list() | map()) :: binary()
  def format(list) when is_list(list) do
    Enum.reduce(list, "", fn item, result ->
      result <> format(item)
    end)
  end

  def format(%{version: version, changes: changes}) do
    """

    ### Version: #{version}

    #{format(changes)}---
    """
  end

  def format(%{type: type, descriptions: descriptions}) do
    """
    ##### Resource: #{type}
    #{format(descriptions)}
    """
  end

  def format(description) when is_binary(description) do
    "- #{description}\n"
  end
end

defmodule Versioning.Changelog.MarkdownTest do
  @moduledoc """
  Better tests required...
  """

  use ExUnit.Case

  alias Versioning.TestSchema
  alias Versioning.Changelog.Markdown

  describe "format/1" do
    test "will format a full changelog" do
      changelog = TestSchema.changelog(formatter: Markdown)
      assert is_binary(changelog)
    end

    test "will format a specific version" do
      changelog = TestSchema.changelog(version: "1", formatter: Markdown)
      assert is_binary(changelog)
    end

    test "will format a specific version and type" do
      changelog = TestSchema.changelog(version: "1", type: Any, formatter: Markdown)
      assert is_binary(changelog)
    end
  end
end

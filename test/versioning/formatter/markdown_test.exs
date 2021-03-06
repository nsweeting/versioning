defmodule Versioning.Changelog.MarkdownTest do
  @moduledoc """
  Better tests required...
  """

  use ExUnit.Case

  alias Versioning.Changelog
  alias Versioning.Changelog.Markdown

  describe "format/1" do
    test "will format a full changelog" do
      changelog = Changelog.build(MySchema, formatter: Markdown)
      assert is_binary(changelog)
    end

    test "will format a specific version" do
      changelog = Changelog.build(MySchema, version: "1.0.1", formatter: Markdown)
      assert is_binary(changelog)
    end

    test "will format a specific version and type" do
      changelog = Changelog.build(MySchema, version: "1.0.1", type: "All!", formatter: Markdown)

      assert is_binary(changelog)
    end
  end
end

defmodule Versioning.Adapter.SemanticTest do
  use ExUnit.Case

  alias Versioning.Adapter.Semantic, as: SemanticAdapter

  describe "parse/1" do
    test "will parse string versions" do
      assert {:ok, %Version{major: 1, minor: 0, patch: 0}} = SemanticAdapter.parse("1.0.0")
    end

    test "will parse version versions" do
      assert {:ok, %Version{major: 1, minor: 0, patch: 0}} =
               SemanticAdapter.parse(%Version{major: 1, minor: 0, patch: 0})
    end

    test "will return :error on bad values" do
      assert :error = SemanticAdapter.parse(1)
      assert :error = SemanticAdapter.parse("1")
      assert :error = SemanticAdapter.parse(:foo)
      assert :error = SemanticAdapter.parse(%{})
    end
  end

  describe "compare/2" do
    test "will return :eq if two versions are equal for strings" do
      assert :eq = SemanticAdapter.compare("1.0.0", "1.0.0")
    end

    test "will return :eq if two versions are equal for dates" do
      assert :eq =
               SemanticAdapter.compare(%Version{major: 1, minor: 0, patch: 0}, %Version{
                 major: 1,
                 minor: 0,
                 patch: 0
               })
    end

    test "will return :gt if version1 is greater than version2 for strings" do
      assert :gt = SemanticAdapter.compare("1.0.1", "1.0.0")
    end

    test "will return :gt if version1 is greater than version2 for dates" do
      assert :gt =
               SemanticAdapter.compare(%Version{major: 1, minor: 0, patch: 1}, %Version{
                 major: 1,
                 minor: 0,
                 patch: 0
               })
    end

    test "will return :lt if version1 is less than than version2 for strings" do
      assert :lt = SemanticAdapter.compare("1.0.0", "1.0.1")
    end

    test "will return :lt if version1 is less than than version2 for dates" do
      assert :lt =
               SemanticAdapter.compare(%Version{major: 1, minor: 0, patch: 0}, %Version{
                 major: 1,
                 minor: 0,
                 patch: 1
               })
    end

    test "will return :error if version1 is a bad value" do
      assert :error = SemanticAdapter.compare(1, "1.0.0")
    end

    test "will return :error if version2 is a bad value" do
      assert :error = SemanticAdapter.compare("1.0.0", 1)
    end
  end
end

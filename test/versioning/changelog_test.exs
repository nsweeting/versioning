defmodule Versioning.ChangelogTest do
  use ExUnit.Case

  alias Versioning.Changelog

  describe "build/2" do
    test "will return a changelog map of the schema" do
      changelog = Changelog.build(SemVerSchema)

      assert changelog == [
               %{changes: [], version: "2.0.1"},
               %{
                 changes: [
                   %{descriptions: ["15", "14"], type: "All!"},
                   %{descriptions: ["13", "12"], type: "Foo"}
                 ],
                 version: "2.0.0"
               },
               %{changes: [%{descriptions: ["11", "10"], type: "All!"}], version: "1.1.1"},
               %{changes: [%{descriptions: ["9", "8"], type: "Bar"}], version: "1.1.0"},
               %{changes: [%{descriptions: ["7", "6"], type: "Foo"}], version: "1.0.2"},
               %{
                 changes: [
                   %{descriptions: ["3", "2"], type: "Bar"},
                   %{descriptions: ["5", "4"], type: "All!"},
                   %{descriptions: ["1"], type: "Foo"}
                 ],
                 version: "1.0.1"
               },
               %{changes: [], version: "1.0.0"}
             ]
    end

    test "will return a specific version of the changelog with :version option" do
      changelog = Changelog.build(SemVerSchema, version: "1.0.1")

      assert changelog == %{
               changes: [
                 %{descriptions: ["3", "2"], type: "Bar"},
                 %{descriptions: ["5", "4"], type: "All!"},
                 %{descriptions: ["1"], type: "Foo"}
               ],
               version: "1.0.1"
             }
    end

    test "will raise a Versioning.ChangelogError when given an invalid version" do
      assert_raise(Versioning.ChangelogError, fn ->
        Changelog.build(SemVerSchema, version: "foo")
      end)
    end

    test "will return a specific version and type of the changelog with :version and :type option" do
      changelog = Changelog.build(SemVerSchema, version: "1.0.1", type: "All!")

      assert changelog == %{descriptions: ["5", "4"], type: "All!"}
    end

    test "will raise a Versioning.ChangelogError when give a :type without a :version" do
      assert_raise(Versioning.ChangelogError, fn ->
        Changelog.build(SemVerSchema, type: "All!")
      end)
    end
  end
end

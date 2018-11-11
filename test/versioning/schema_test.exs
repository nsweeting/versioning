defmodule Versioning.SchemaTest do
  use ExUnit.Case

  alias Versioning.TestSchema

  describe "run/1" do
    test "will match on the first version with the Foo type specified" do
      version_change = Versioning.new("1", Foo, [])
      version_change = TestSchema.run(version_change)

      assert version_change.data == [:"2", :"3", :"7", :"6", :"9", :"12", :"15", :"16"]
    end

    test "will match on the first version with the Bar type specified" do
      version_change = Versioning.new("1", Bar, [])
      version_change = TestSchema.run(version_change)

      assert version_change.data == [:"1", :"3", :"5", :"8", :"11", :"14", :"13", :"16"]
    end

    test "will match on the latest version with the Foo type specified" do
      version_change = Versioning.new("5", Foo, [])
      version_change = TestSchema.run(version_change)

      assert version_change.data == [:"15", :"16"]
    end

    test "will match on the latest version with the Bar type specified" do
      version_change = Versioning.new("5", Bar, [])
      version_change = TestSchema.run(version_change)

      assert version_change.data == [:"14", :"13", :"16"]
    end

    test "will raise a Versioning.Error if no version is matched" do
      version_change = Versioning.new("6", Foo, [])

      assert_raise(Versioning.Error, fn ->
        TestSchema.run(version_change)
      end)
    end
  end

  describe "changelog/0" do
    test "will return a changelog map of the schema" do
      changelog = TestSchema.changelog()

      first_version = List.first(changelog)
      last_version = List.last(changelog)

      assert first_version == %{
               changes: [
                 %{descriptions: ["16"], type: Any},
                 %{descriptions: ["15"], type: Foo},
                 %{descriptions: ["13", "14"], type: Bar},
                 %{descriptions: ["17"], type: Baz}
               ],
               version: "5"
             }

      assert last_version == %{
               changes: [
                 %{descriptions: ["3"], type: Any},
                 %{descriptions: ["2"], type: Foo},
                 %{descriptions: ["1"], type: Bar},
                 %{descriptions: [], type: Baz}
               ],
               version: "1"
             }
    end
  end

  describe "changelog/1" do
    test "will return a specific version of the changelog with :version option" do
      changelog = TestSchema.changelog(version: "1")

      assert changelog == %{
               changes: [
                 %{descriptions: ["3"], type: Any},
                 %{descriptions: ["2"], type: Foo},
                 %{descriptions: ["1"], type: Bar},
                 %{descriptions: [], type: Baz}
               ],
               version: "1"
             }
    end

    test "will return a specific version and type of the changelog with :version and :type option" do
      changelog = TestSchema.changelog(version: "1", type: Any)

      assert changelog == %{descriptions: ["3"], type: Any}
    end

    test "will raise an ArgumentError when give a :type without a :version" do
      assert_raise(ArgumentError, fn ->
        TestSchema.changelog(type: Any)
      end)
    end
  end
end

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
end

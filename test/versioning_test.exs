defmodule VersioningTest do
  use ExUnit.Case

  defmodule Test do
    defstruct [
      :attr
    ]
  end

  describe "new/2" do
    test "will create a new versioning from a struct" do
      data = %Test{attr: "val"}
      versioning = Versioning.new("1", data)

      assert versioning.target == "1"
      assert versioning.type == Test
      assert versioning.data == %{attr: "val"}
    end

    test "will create a new versioning from a map" do
      versioning = Versioning.new("1", %{foo: "bar"})

      assert versioning.target == "1"
      assert versioning.type == Map
      assert versioning.data == %{foo: "bar"}
    end

    test "will create a new versioning from a list" do
      versioning = Versioning.new("1", ["foo"])

      assert versioning.target == "1"
      assert versioning.type == List
      assert versioning.data == ["foo"]
    end
  end

  describe "new/3" do
    test "will create a new versioning using the type and data" do
      versioning = Versioning.new("1", Foo, %{foo: :bar})

      assert versioning.target == "1"
      assert versioning.type == Foo
      assert versioning.data == %{foo: :bar}
    end
  end

  describe "change/2" do
    test "will change the versioning using a change module" do
      versioning = Versioning.new("1", Foo, [])

      assert versioning.data == []

      versioning = Versioning.change(versioning, TestChange1)

      assert versioning.data == [:"1"]
    end

    test "will change the versioning using a list of change modules" do
      versioning = Versioning.new("1", Foo, [])

      assert versioning.data == []

      versioning = Versioning.change(versioning, [TestChange1, TestChange2])

      assert versioning.data == [:"2", :"1"]
    end
  end

  describe "assign/3" do
    test "will assign a key value to the versioning assigns" do
      versioning = Versioning.new("1", Foo, [])

      assert versioning.assigns == %{}

      versioning = Versioning.assign(versioning, :foo, "bar")

      assert versioning.assigns == %{foo: "bar"}
    end
  end
end

defmodule VersioningTest do
  use ExUnit.Case

  describe "new/4" do
    test "will create a new default versioning" do
      versioning = Versioning.new()

      assert versioning.data == %{}
      assert versioning.type == nil
      assert versioning.current == nil
      assert versioning.target == nil
    end

    test "will create a versioning from a map" do
      versioning = Versioning.new(%{})

      assert versioning.data == %{}
      assert versioning.type == nil
      assert versioning.current == nil
      assert versioning.target == nil
    end

    test "will create a versioning from a struct" do
      versioning = Versioning.new(%Foo{})

      assert versioning.data == %{"down" => [], "up" => []}
      assert versioning.type == "Foo"
      assert versioning.current == nil
      assert versioning.target == nil
    end

    test "will create a versioning from a struct with a current version" do
      versioning = Versioning.new(%Foo{}, "0.1.0")

      assert versioning.data == %{"down" => [], "up" => []}
      assert versioning.type == "Foo"
      assert versioning.current == "0.1.0"
      assert versioning.target == nil
    end

    test "will create a versioning from a struct with a current and target version" do
      versioning = Versioning.new(%Foo{}, "0.1.0", "1.0.0")

      assert versioning.data == %{"down" => [], "up" => []}
      assert versioning.type == "Foo"
      assert versioning.current == "0.1.0"
      assert versioning.target == "1.0.0"
    end

    test "will create a versioning from a struct with a current and target version and other type" do
      versioning = Versioning.new(%Foo{}, "0.1.0", "1.0.0", Bar)

      assert versioning.data == %{"down" => [], "up" => []}
      assert versioning.type == "Bar"
      assert versioning.current == "0.1.0"
      assert versioning.target == "1.0.0"
    end

    test "will create a versioning from a map with a current and target version and type" do
      versioning = Versioning.new(%{}, "0.1.0", "1.0.0", Bar)

      assert versioning.data == %{}
      assert versioning.type == "Bar"
      assert versioning.current == "0.1.0"
      assert versioning.target == "1.0.0"
    end
  end

  describe "put_current/2" do
    test "will put the current version" do
      versioning = Versioning.new(%Foo{}, "0.1.0", "1.0.0")

      assert versioning.current == "0.1.0"
    end
  end

  describe "put_target/2" do
    test "will put the target version" do
      versioning = Versioning.new(%Foo{}, "0.1.0", "1.0.0")

      assert versioning.target == "1.0.0"

      versioning = Versioning.put_target(versioning, "0.1.1")

      assert versioning.target == "0.1.1"
    end
  end

  describe "put_type/2" do
    test "will put the type of version" do
      versioning = Versioning.new(%Foo{}, "0.1.0", "1.0.0")

      assert versioning.type == "Foo"

      versioning = Versioning.put_type(versioning, Bar)

      assert versioning.type == "Bar"
    end
  end

  describe "assign/3" do
    test "will assign the key and value to the assigns" do
      versioning = Versioning.new(%Foo{}, "0.1.0", "1.0.0")

      assert versioning.assigns == %{}

      versioning = Versioning.assign(versioning, :foo, "bar")

      assert versioning.assigns == %{foo: "bar"}
    end
  end

  describe "pop_data/3" do
    test "will pop a value from the data and return a new versioning" do
      versioning = Versioning.new(%Foo{}, "0.1.0", "1.0.0")

      assert versioning.data == %{"down" => [], "up" => []}
      assert {[], versioning} = Versioning.pop_data(versioning, "down")
      assert versioning.data == %{"up" => []}
    end

    test "will return the default value if it doesnt exist in data" do
      versioning = Versioning.new(%Foo{}, "0.1.0", "1.0.0")

      assert versioning.data == %{"down" => [], "up" => []}
      assert {[], versioning} = Versioning.pop_data(versioning, "foo", [])
      assert versioning.data == %{"down" => [], "up" => []}
    end
  end

  describe "put_data/2" do
    test "will put full data into the versioning" do
      versioning = Versioning.new(%Foo{}, "0.1.0", "1.0.0")

      assert versioning.data == %{"down" => [], "up" => []}

      versioning = Versioning.put_data(versioning, %{bar: :baz})

      assert versioning.data == %{"bar" => :baz}
    end
  end

  describe "put_data/3" do
    test "will put a key and value into the data" do
      versioning = Versioning.new(%Foo{}, "0.1.0", "1.0.0")

      assert versioning.data == %{"down" => [], "up" => []}

      versioning = Versioning.put_data(versioning, "foo", :bar)

      assert versioning.data == %{"down" => [], "up" => [], "foo" => :bar}
    end
  end
end

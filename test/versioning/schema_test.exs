defmodule Versioning.SchemaTest do
  use ExUnit.Case

  describe "run/1 with Semantic adapter" do
    test "will run all Foo changes from version 2.0.1 to 1.0.0" do
      versioning = Versioning.new(%Foo{}, "2.0.1", "1.0.0")

      assert {:ok, versioning} = SemanticSchema.run(versioning)
      assert versioning.data["down"] == [15, 14, 13, 12, 11, 10, 7, 6, 5, 4, 1]
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 2.0.1 to 1.0.1" do
      versioning = Versioning.new(%Foo{}, "2.0.1", "1.0.1")

      assert {:ok, versioning} = SemanticSchema.run(versioning)
      assert versioning.data["down"] == [15, 14, 13, 12, 11, 10, 7, 6, 5, 4, 1]
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 2.0.1 to 1.0.2" do
      versioning = Versioning.new(%Foo{}, "2.0.1", "1.0.2")

      assert {:ok, versioning} = SemanticSchema.run(versioning)
      assert versioning.data["down"] == [15, 14, 13, 12, 11, 10, 7, 6]
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 2.0.1 to 1.1.0" do
      versioning = Versioning.new(%Foo{}, "2.0.1", "1.1.0")

      assert {:ok, versioning} = SemanticSchema.run(versioning)
      assert versioning.data["down"] == [15, 14, 13, 12, 11, 10]
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 2.0.1 to 1.1.1" do
      versioning = Versioning.new(%Foo{}, "2.0.1", "1.1.1")

      assert {:ok, versioning} = SemanticSchema.run(versioning)
      assert versioning.data["down"] == [15, 14, 13, 12, 11, 10]
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 2.0.1 to 2.0.0" do
      versioning = Versioning.new(%Foo{}, "2.0.1", "2.0.0")

      assert {:ok, versioning} = SemanticSchema.run(versioning)
      assert versioning.data["down"] == [15, 14, 13, 12]
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 2.0.1 to 2.0.1" do
      versioning = Versioning.new(%Foo{}, "2.0.1", "2.0.1")

      assert {:ok, versioning} = SemanticSchema.run(versioning)
      assert versioning.data["down"] == []
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 2.0.0 to 1.0.0" do
      versioning = Versioning.new(%Foo{}, "2.0.0", "1.0.0")

      assert {:ok, versioning} = SemanticSchema.run(versioning)
      assert versioning.data["down"] == [11, 10, 7, 6, 5, 4, 1]
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 1.1.1 to 1.0.0" do
      versioning = Versioning.new(%Foo{}, "1.1.1", "1.0.0")

      assert {:ok, versioning} = SemanticSchema.run(versioning)
      assert versioning.data["down"] == [7, 6, 5, 4, 1]
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 1.1.0 to 1.0.0" do
      versioning = Versioning.new(%Foo{}, "1.1.0", "1.0.0")

      assert {:ok, versioning} = SemanticSchema.run(versioning)
      assert versioning.data["down"] == [7, 6, 5, 4, 1]
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 1.0.2 to 1.0.0" do
      versioning = Versioning.new(%Foo{}, "1.0.2", "1.0.0")

      assert {:ok, versioning} = SemanticSchema.run(versioning)
      assert versioning.data["down"] == [5, 4, 1]
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 1.0.1 to 1.0.0" do
      versioning = Versioning.new(%Foo{}, "1.0.1", "1.0.0")

      assert {:ok, versioning} = SemanticSchema.run(versioning)
      assert versioning.data["down"] == []
      assert versioning.data["up"] == []
    end

    test "will run all Bar changes from version 2.0.1 to 1.0.0" do
      versioning = Versioning.new(%Bar{}, "2.0.1", "1.0.0")

      assert {:ok, versioning} = SemanticSchema.run(versioning)
      assert versioning.data["down"] == [15, 14, 11, 10, 9, 8, 3, 2, 5, 4]
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 1.0.0 to 2.0.1" do
      versioning = Versioning.new(%Foo{}, "1.0.0", "2.0.1")

      assert {:ok, versioning} = SemanticSchema.run(versioning)
      assert versioning.data["down"] == []
      assert versioning.data["up"] == [1, 4, 5, 6, 7, 10, 11, 12, 13, 14, 15]
    end

    test "will run all Foo changes from version 1.0.1 to 2.0.1" do
      versioning = Versioning.new(%Foo{}, "1.0.1", "2.0.1")

      assert {:ok, versioning} = SemanticSchema.run(versioning)
      assert versioning.data["down"] == []
      assert versioning.data["up"] == [6, 7, 10, 11, 12, 13, 14, 15]
    end

    test "will run all Foo changes from version 1.0.2  to 2.0.1" do
      versioning = Versioning.new(%Foo{}, "1.0.2", "2.0.1")

      assert {:ok, versioning} = SemanticSchema.run(versioning)
      assert versioning.data["down"] == []
      assert versioning.data["up"] == [10, 11, 12, 13, 14, 15]
    end

    test "will run all Foo changes from version 1.1.0 to 2.0.1" do
      versioning = Versioning.new(%Foo{}, "1.1.0", "2.0.1")

      assert {:ok, versioning} = SemanticSchema.run(versioning)
      assert versioning.data["down"] == []
      assert versioning.data["up"] == [10, 11, 12, 13, 14, 15]
    end

    test "will run all Foo changes from version 1.1.1 to 2.0.1" do
      versioning = Versioning.new(%Foo{}, "1.1.1", "2.0.1")

      assert {:ok, versioning} = SemanticSchema.run(versioning)
      assert versioning.data["down"] == []
      assert versioning.data["up"] == [12, 13, 14, 15]
    end

    test "will run all Foo changes from version 2.0.0 to 2.0.1" do
      versioning = Versioning.new(%Foo{}, "2.0.0", "2.0.1")

      assert {:ok, versioning} = SemanticSchema.run(versioning)
      assert versioning.data["down"] == []
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 1.0.0 to 1.1.0" do
      versioning = Versioning.new(%Foo{}, "1.0.0", "1.1.1")

      assert {:ok, versioning} = SemanticSchema.run(versioning)
      assert versioning.data["down"] == []
      assert versioning.data["up"] == [1, 4, 5, 6, 7, 10, 11]
    end

    test "will run all Bar changes from version 1.0.0 to 2.0.1" do
      versioning = Versioning.new(%Bar{}, "1.0.0", "2.0.1")

      assert {:ok, versioning} = SemanticSchema.run(versioning)
      assert versioning.data["down"] == []
      assert versioning.data["up"] == [4, 5, 2, 3, 8, 9, 10, 11, 14, 15]
    end

    test "will return a Versioning.ExecutionError if current version is not matched" do
      versioning = Versioning.new(%Foo{}, "3.0.0", "1.0.0")

      assert {:error, %Versioning.ExecutionError{}} = SemanticSchema.run(versioning)
    end

    test "will return a Versioning.ExecutionError if target version is not matched" do
      versioning = Versioning.new(%Foo{}, "2.0.1", "3.0.0")

      assert {:error, %Versioning.ExecutionError{}} = SemanticSchema.run(versioning)
    end

    test "will return a Versioning.ExecutionError if target version is not parseable" do
      versioning = Versioning.new(%Foo{}, "foo", "1.0.0")

      assert {:error, %Versioning.ExecutionError{}} = SemanticSchema.run(versioning)
    end

    test "will return a Versioning.ExecutionError if current version is not parseable" do
      versioning = Versioning.new(%Foo{}, "1.0.0", "foo")

      assert {:error, %Versioning.ExecutionError{}} = SemanticSchema.run(versioning)
    end
  end

  describe "run/1 with Date adapter" do
    test "will run all Foo changes from version 2019-01-07 to 2019-01-01" do
      versioning = Versioning.new(%Foo{}, "2019-01-07", "2019-01-01")

      assert {:ok, versioning} = DateSchema.run(versioning)
      assert versioning.data["down"] == [15, 14, 13, 12, 11, 10, 7, 6, 5, 4, 1]
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 2019-01-07 to 2019-01-02" do
      versioning = Versioning.new(%Foo{}, "2019-01-07", "2019-01-02")

      assert {:ok, versioning} = DateSchema.run(versioning)
      assert versioning.data["down"] == [15, 14, 13, 12, 11, 10, 7, 6, 5, 4, 1]
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 2019-01-07 to 2019-01-03" do
      versioning = Versioning.new(%Foo{}, "2019-01-07", "2019-01-03")

      assert {:ok, versioning} = DateSchema.run(versioning)
      assert versioning.data["down"] == [15, 14, 13, 12, 11, 10, 7, 6]
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 2019-01-07 to 2019-01-04" do
      versioning = Versioning.new(%Foo{}, "2019-01-07", "2019-01-04")

      assert {:ok, versioning} = DateSchema.run(versioning)
      assert versioning.data["down"] == [15, 14, 13, 12, 11, 10]
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 2019-01-07 to 2019-01-05" do
      versioning = Versioning.new(%Foo{}, "2019-01-07", "2019-01-05")

      assert {:ok, versioning} = DateSchema.run(versioning)
      assert versioning.data["down"] == [15, 14, 13, 12, 11, 10]
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 2019-01-07 to 2019-01-06" do
      versioning = Versioning.new(%Foo{}, "2019-01-07", "2019-01-06")

      assert {:ok, versioning} = DateSchema.run(versioning)
      assert versioning.data["down"] == [15, 14, 13, 12]
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 2019-01-07 to 2019-01-07" do
      versioning = Versioning.new(%Foo{}, "2019-01-07", "2019-01-07")

      assert {:ok, versioning} = DateSchema.run(versioning)
      assert versioning.data["down"] == []
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 2019-01-06 to 2019-01-01" do
      versioning = Versioning.new(%Foo{}, "2019-01-06", "2019-01-01")

      assert {:ok, versioning} = DateSchema.run(versioning)
      assert versioning.data["down"] == [11, 10, 7, 6, 5, 4, 1]
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 2019-01-05 to 2019-01-01" do
      versioning = Versioning.new(%Foo{}, "2019-01-05", "2019-01-01")

      assert {:ok, versioning} = DateSchema.run(versioning)
      assert versioning.data["down"] == [7, 6, 5, 4, 1]
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 2019-01-04 to 2019-01-01" do
      versioning = Versioning.new(%Foo{}, "2019-01-04", "2019-01-01")

      assert {:ok, versioning} = DateSchema.run(versioning)
      assert versioning.data["down"] == [7, 6, 5, 4, 1]
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 2019-01-03 to 2019-01-01" do
      versioning = Versioning.new(%Foo{}, "2019-01-03", "2019-01-01")

      assert {:ok, versioning} = DateSchema.run(versioning)
      assert versioning.data["down"] == [5, 4, 1]
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 2019-01-02 to 2019-01-01" do
      versioning = Versioning.new(%Foo{}, "2019-01-02", "2019-01-01")

      assert {:ok, versioning} = DateSchema.run(versioning)
      assert versioning.data["down"] == []
      assert versioning.data["up"] == []
    end

    test "will run all Bar changes from version 2019-01-07 to 2019-01-01" do
      versioning = Versioning.new(%Bar{}, "2019-01-07", "2019-01-01")

      assert {:ok, versioning} = DateSchema.run(versioning)
      assert versioning.data["down"] == [15, 14, 11, 10, 9, 8, 3, 2, 5, 4]
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 2019-01-01 to 2019-01-07" do
      versioning = Versioning.new(%Foo{}, "2019-01-01", "2019-01-07")

      assert {:ok, versioning} = DateSchema.run(versioning)
      assert versioning.data["down"] == []
      assert versioning.data["up"] == [1, 4, 5, 6, 7, 10, 11, 12, 13, 14, 15]
    end

    test "will run all Foo changes from version 2019-01-02 to 2019-01-07" do
      versioning = Versioning.new(%Foo{}, "2019-01-02", "2019-01-07")

      assert {:ok, versioning} = DateSchema.run(versioning)
      assert versioning.data["down"] == []
      assert versioning.data["up"] == [6, 7, 10, 11, 12, 13, 14, 15]
    end

    test "will run all Foo changes from version 2019-01-03 to 2019-01-07" do
      versioning = Versioning.new(%Foo{}, "2019-01-03", "2019-01-07")

      assert {:ok, versioning} = DateSchema.run(versioning)
      assert versioning.data["down"] == []
      assert versioning.data["up"] == [10, 11, 12, 13, 14, 15]
    end

    test "will run all Foo changes from version 2019-01-04 to 2019-01-07" do
      versioning = Versioning.new(%Foo{}, "2019-01-04", "2019-01-07")

      assert {:ok, versioning} = DateSchema.run(versioning)
      assert versioning.data["down"] == []
      assert versioning.data["up"] == [10, 11, 12, 13, 14, 15]
    end

    test "will run all Foo changes from version 2019-01-05 to 2019-01-07" do
      versioning = Versioning.new(%Foo{}, "2019-01-05", "2019-01-07")

      assert {:ok, versioning} = DateSchema.run(versioning)
      assert versioning.data["down"] == []
      assert versioning.data["up"] == [12, 13, 14, 15]
    end

    test "will run all Foo changes from version 2019-01-06 to 2019-01-07" do
      versioning = Versioning.new(%Foo{}, "2019-01-06", "2019-01-07")

      assert {:ok, versioning} = DateSchema.run(versioning)
      assert versioning.data["down"] == []
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 2019-01-01 to 2019-01-05" do
      versioning = Versioning.new(%Foo{}, "2019-01-01", "2019-01-05")

      assert {:ok, versioning} = DateSchema.run(versioning)
      assert versioning.data["down"] == []
      assert versioning.data["up"] == [1, 4, 5, 6, 7, 10, 11]
    end

    test "will run all Bar changes from version 2019-01-01 to 2019-01-07" do
      versioning = Versioning.new(%Bar{}, "2019-01-01", "2019-01-07")

      assert {:ok, versioning} = DateSchema.run(versioning)
      assert versioning.data["down"] == []
      assert versioning.data["up"] == [4, 5, 2, 3, 8, 9, 10, 11, 14, 15]
    end

    test "will return a Versioning.ExecutionError if current version is not matched" do
      versioning = Versioning.new(%Foo{}, "2020-01-01", "2019-01-01")

      assert {:error, %Versioning.ExecutionError{}} = DateSchema.run(versioning)
    end

    test "will return a Versioning.ExecutionError if target version is not matched" do
      versioning = Versioning.new(%Foo{}, "2019-01-07", "2020-01-01")

      assert {:error, %Versioning.ExecutionError{}} = DateSchema.run(versioning)
    end

    test "will return a Versioning.ExecutionError if target version is not parseable" do
      versioning = Versioning.new(%Foo{}, "foo", "2019-01-01")

      assert {:error, %Versioning.ExecutionError{}} = DateSchema.run(versioning)
    end

    test "will return a Versioning.ExecutionError if current version is not parseable" do
      versioning = Versioning.new(%Foo{}, "2019-01-01", "foo")

      assert {:error, %Versioning.ExecutionError{}} = DateSchema.run(versioning)
    end
  end
end

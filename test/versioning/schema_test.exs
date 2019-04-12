defmodule Versioning.SchemaTest do
  use ExUnit.Case

  describe "run/1" do
    test "will run all Foo changes from version 2.0.1 to 1.0.0" do
      versioning = Versioning.new(%Foo{}, "2.0.1", "1.0.0")

      assert {:ok, versioning} = MySchema.run(versioning)
      assert versioning.data["down"] == [15, 14, 13, 12, 11, 10, 7, 6, 5, 4, 1]
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 2.0.1 to 1.0.1" do
      versioning = Versioning.new(%Foo{}, "2.0.1", "1.0.1")

      assert {:ok, versioning} = MySchema.run(versioning)
      assert versioning.data["down"] == [15, 14, 13, 12, 11, 10, 7, 6, 5, 4, 1]
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 2.0.1 to 1.0.2" do
      versioning = Versioning.new(%Foo{}, "2.0.1", "1.0.2")

      assert {:ok, versioning} = MySchema.run(versioning)
      assert versioning.data["down"] == [15, 14, 13, 12, 11, 10, 7, 6]
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 2.0.1 to 1.1.0" do
      versioning = Versioning.new(%Foo{}, "2.0.1", "1.1.0")

      assert {:ok, versioning} = MySchema.run(versioning)
      assert versioning.data["down"] == [15, 14, 13, 12, 11, 10]
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 2.0.1 to 1.1.1" do
      versioning = Versioning.new(%Foo{}, "2.0.1", "1.1.1")

      assert {:ok, versioning} = MySchema.run(versioning)
      assert versioning.data["down"] == [15, 14, 13, 12, 11, 10]
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 2.0.1 to 2.0.0" do
      versioning = Versioning.new(%Foo{}, "2.0.1", "2.0.0")

      assert {:ok, versioning} = MySchema.run(versioning)
      assert versioning.data["down"] == [15, 14, 13, 12]
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 2.0.1 to 2.0.1" do
      versioning = Versioning.new(%Foo{}, "2.0.1", "2.0.1")

      assert {:ok, versioning} = MySchema.run(versioning)
      assert versioning.data["down"] == []
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 2.0.0 to 1.0.0" do
      versioning = Versioning.new(%Foo{}, "2.0.0", "1.0.0")

      assert {:ok, versioning} = MySchema.run(versioning)
      assert versioning.data["down"] == [11, 10, 7, 6, 5, 4, 1]
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 1.1.1 to 1.0.0" do
      versioning = Versioning.new(%Foo{}, "1.1.1", "1.0.0")

      assert {:ok, versioning} = MySchema.run(versioning)
      assert versioning.data["down"] == [7, 6, 5, 4, 1]
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 1.1.0 to 1.0.0" do
      versioning = Versioning.new(%Foo{}, "1.1.0", "1.0.0")

      assert {:ok, versioning} = MySchema.run(versioning)
      assert versioning.data["down"] == [7, 6, 5, 4, 1]
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 1.0.2 to 1.0.0" do
      versioning = Versioning.new(%Foo{}, "1.0.2", "1.0.0")

      assert {:ok, versioning} = MySchema.run(versioning)
      assert versioning.data["down"] == [5, 4, 1]
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 1.0.1 to 1.0.0" do
      versioning = Versioning.new(%Foo{}, "1.0.1", "1.0.0")

      assert {:ok, versioning} = MySchema.run(versioning)
      assert versioning.data["down"] == []
      assert versioning.data["up"] == []
    end

    test "will run all Bar changes from version 2.0.1 to 1.0.0" do
      versioning = Versioning.new(%Bar{}, "2.0.1", "1.0.0")

      assert {:ok, versioning} = MySchema.run(versioning)
      assert versioning.data["down"] == [15, 14, 11, 10, 9, 8, 3, 2, 5, 4]
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 1.0.0 to 2.0.1" do
      versioning = Versioning.new(%Foo{}, "1.0.0", "2.0.1")

      assert {:ok, versioning} = MySchema.run(versioning)
      assert versioning.data["down"] == []
      assert versioning.data["up"] == [1, 4, 5, 6, 7, 10, 11, 12, 13, 14, 15]
    end

    test "will run all Foo changes from version 1.0.1 to 2.0.1" do
      versioning = Versioning.new(%Foo{}, "1.0.1", "2.0.1")

      assert {:ok, versioning} = MySchema.run(versioning)
      assert versioning.data["down"] == []
      assert versioning.data["up"] == [6, 7, 10, 11, 12, 13, 14, 15]
    end

    test "will run all Foo changes from version 1.0.2  to 2.0.1" do
      versioning = Versioning.new(%Foo{}, "1.0.2", "2.0.1")

      assert {:ok, versioning} = MySchema.run(versioning)
      assert versioning.data["down"] == []
      assert versioning.data["up"] == [10, 11, 12, 13, 14, 15]
    end

    test "will run all Foo changes from version 1.1.0 to 2.0.1" do
      versioning = Versioning.new(%Foo{}, "1.1.0", "2.0.1")

      assert {:ok, versioning} = MySchema.run(versioning)
      assert versioning.data["down"] == []
      assert versioning.data["up"] == [10, 11, 12, 13, 14, 15]
    end

    test "will run all Foo changes from version 1.1.1 to 2.0.1" do
      versioning = Versioning.new(%Foo{}, "1.1.1", "2.0.1")

      assert {:ok, versioning} = MySchema.run(versioning)
      assert versioning.data["down"] == []
      assert versioning.data["up"] == [12, 13, 14, 15]
    end

    test "will run all Foo changes from version 2.0.0 to 2.0.1" do
      versioning = Versioning.new(%Foo{}, "2.0.0", "2.0.1")

      assert {:ok, versioning} = MySchema.run(versioning)
      assert versioning.data["down"] == []
      assert versioning.data["up"] == []
    end

    test "will run all Foo changes from version 1.0.0 to 1.1.0" do
      versioning = Versioning.new(%Foo{}, "1.0.0", "1.1.1")

      assert {:ok, versioning} = MySchema.run(versioning)
      assert versioning.data["down"] == []
      assert versioning.data["up"] == [1, 4, 5, 6, 7, 10, 11]
    end

    test "will run all Bar changes from version 1.0.0 to 2.0.1" do
      versioning = Versioning.new(%Bar{}, "1.0.0", "2.0.1")

      assert {:ok, versioning} = MySchema.run(versioning)
      assert versioning.data["down"] == []
      assert versioning.data["up"] == [4, 5, 2, 3, 8, 9, 10, 11, 14, 15]
    end

    test "will return a Versioning.ExecutionError if current version is not matched" do
      versioning = Versioning.new(%Foo{}, "3.0.0", "1.0.0")

      assert {:error, %VersioningError{}} = MySchema.run(versioning)
    end

    test "will return a Versioning.ExecutionError if target version is not matched" do
      versioning = Versioning.new(%Foo{}, "2.0.1", "3.0.0")

      assert {:error, %VersioningError{}} = MySchema.run(versioning)
    end

    test "will return a Versioning.ExecutionError if target version is not parseable" do
      versioning = Versioning.new(%Foo{}, "foo", "1.0.0")

      assert {:error, %VersioningError{}} = MySchema.run(versioning)
    end

    test "will return a Versioning.ExecutionError if current version is not parseable" do
      versioning = Versioning.new(%Foo{}, "1.0.0", "foo")

      assert {:error, %VersioningError{}} = MySchema.run(versioning)
    end
  end

  # Metadata

  test "schema metadata" do
    assert %Version{major: 2, minor: 0, patch: 1} = MySchema.__schema__(:latest, :parsed)
    assert "2.0.1" = MySchema.__schema__(:latest, :string)
  end

  test "schema metadata with @latest attribute" do
    assert %Version{major: 1, minor: 0, patch: 0} = MySchemaLatest.__schema__(:latest, :parsed)
    assert "1.0.0" = MySchemaLatest.__schema__(:latest, :string)
  end

  # Errors

  test "duplicate versions" do
    assert_raise Versioning.CompileError, fn ->
      defmodule MySchemaWithDuplicateVersions do
        use Versioning.Schema, adapter: Versioning.Adapter.Semantic

        version("1.0.0", do: [])

        version("1.0.0", do: [])
      end
    end
  end

  test "invalid version order" do
    assert_raise Versioning.CompileError, fn ->
      defmodule MySchemaWithInvalidVersionOrder do
        use Versioning.Schema, adapter: Versioning.Adapter.Semantic

        version("1.0.0", do: [])

        version("1.0.1", do: [])
      end
    end
  end

  test "duplicate types" do
    assert_raise Versioning.CompileError, fn ->
      defmodule MySchemaWithDuplicateTypes do
        use Versioning.Schema, adapter: Versioning.Adapter.Semantic

        version "1.0.0" do
          type("Foo", do: [])
          type("Foo", do: [])
        end
      end
    end
  end

  test "invalid type format" do
    assert_raise Versioning.CompileError, fn ->
      defmodule MySchemaWithInvalidType do
        use Versioning.Schema, adapter: Versioning.Adapter.Semantic

        version "1.0.0" do
          type(Foo, do: [])
        end
      end
    end
  end

  test "invalid change module" do
    assert_raise Versioning.CompileError, fn ->
      defmodule MySchemaWithInvalidChangeModule do
        use Versioning.Schema, adapter: Versioning.Adapter.Semantic

        version "1.0.0" do
          type "Foo" do
            change(BadChange)
          end
        end
      end
    end
  end

  test "invalid @latest attirbute" do
    assert_raise Versioning.CompileError, fn ->
      defmodule MySchemaWithInvalidLatest do
        use Versioning.Schema, adapter: Versioning.Adapter.Semantic

        @latest "1.0.1"

        version("1.0.0", do: [])
      end
    end
  end
end

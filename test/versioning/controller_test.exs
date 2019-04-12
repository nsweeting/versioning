defmodule Versioning.ControllerTest do
  use ExUnit.Case
  use Plug.Test

  describe "put_schema/2" do
    test "will put the schema in the conn prviate map" do
      conn = conn(:get, "/")

      assert conn.private[:versioning_schema] == nil

      conn = Versioning.Controller.put_schema(conn, MySchema)

      assert conn.private.versioning_schema == MySchema
    end
  end

  describe "fetch_schema/1" do
    test "will fetch the schema from the conn" do
      conn = conn(:get, "/")

      conn = Versioning.Controller.put_schema(conn, MySchema)

      assert {:ok, MySchema} = Versioning.Controller.fetch_schema(conn)
    end

    test "will return :error if schema does not exist in conn" do
      conn = conn(:get, "/")

      assert :error = Versioning.Controller.fetch_schema(conn)
    end
  end

  describe "fetch_schema!/1" do
    test "will fetch the schema from the conn" do
      conn = conn(:get, "/")

      conn = Versioning.Controller.put_schema(conn, MySchema)

      assert MySchema = Versioning.Controller.fetch_schema!(conn)
    end

    test "will raise a Versioning.MissingSchemaError if no schema exists" do
      conn = conn(:get, "/")

      assert_raise Versioning.MissingSchemaError, fn ->
        Versioning.Controller.fetch_schema!(conn)
      end
    end
  end

  describe "fetch_version/1" do
    test "will fetch the version from the conn" do
      conn = conn(:get, "/")

      conn = Versioning.Controller.put_version(conn, "1.0.0")

      assert {:ok, "1.0.0"} = Versioning.Controller.fetch_version(conn)
    end

    test "will return :error if version does not exist in conn" do
      conn = conn(:get, "/")

      assert :error = Versioning.Controller.fetch_version(conn)
    end
  end

  describe "fetch_version!/1" do
    test "will fetch the version from the conn" do
      conn = conn(:get, "/")

      conn = Versioning.Controller.put_version(conn, "1.0.0")

      assert "1.0.0" = Versioning.Controller.fetch_version!(conn)
    end

    test "will raise a Versioning.MissingVersionError if no schema exists" do
      conn = conn(:get, "/")

      assert_raise Versioning.MissingVersionError, fn ->
        Versioning.Controller.fetch_version!(conn)
      end
    end
  end

  describe "apply_version/3" do
    test "will apply the version using a specificied header" do
      conn = conn(:get, "/") |> put_req_header("x-version", "1.0.0")
      conn = Versioning.Controller.apply_version(conn, "x-version")

      assert conn.private.versioning_version == "1.0.0"
    end

    test "will apply the version using a fallback module and function" do
      defmodule Fallback do
        def call(_conn) do
          "1.0.0"
        end
      end

      conn = conn(:get, "/")
      conn = Versioning.Controller.apply_version(conn, "x-version", {Fallback, :call})

      assert conn.private.versioning_version == "1.0.0"
    end

    test "will apply the version using the latest if no header is present" do
      conn =
        conn(:get, "/")
        |> Versioning.Controller.put_schema(MySchema)
        |> Versioning.Controller.apply_version()

      assert conn.private.versioning_version == "2.0.1"
    end
  end

  describe "params_version/3" do
    test "will run the params through the schema" do
      conn =
        conn(:get, "/")
        |> Versioning.Controller.put_schema(MySchema)
        |> Versioning.Controller.put_version("1.0.0")

      assert {:ok, params} = Versioning.Controller.params_version(conn, %{}, "Foo")
      assert params == %{"up" => [1, 4, 5, 6, 7, 10, 11, 12, 13, 14, 15]}
    end

    test "will return an error tuple if the version doesnt exist" do
      conn =
        conn(:get, "/")
        |> Versioning.Controller.put_schema(MySchema)
        |> Versioning.Controller.put_version("0.5.0")

      assert {:error, :bad_version} = Versioning.Controller.params_version(conn, %{}, "Foo")
    end
  end
end

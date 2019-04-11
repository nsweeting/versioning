defmodule Versioning.PlugTest do
  use ExUnit.Case
  use Plug.Test

  describe "init/1" do
    test "will raise an error if a schema is not provided" do
      assert_raise KeyError, fn ->
        Versioning.Plug.init(type: "Foo")
      end
    end
  end

  describe "call/2" do
    test "will put the schema in the conn private" do
      opts = Versioning.Plug.init(schema: MySchema)

      conn =
        conn(:get, "/")
        |> Versioning.Plug.call(opts)

      assert conn.private.versioning_schema == MySchema
    end

    test "will put the version request to the conn private map" do
      opts = Versioning.Plug.init(schema: MySchema)

      conn =
        conn(:get, "/")
        |> put_req_header("x-api-version", "1.0.0")
        |> Versioning.Plug.call(opts)

      assert conn.private.versioning_request == "1.0.0"
    end

    test "will use custom headers for the version request" do
      opts = Versioning.Plug.init(schema: MySchema, header: "x-version")

      conn =
        conn(:get, "/")
        |> put_req_header("x-version", "1.0.0")
        |> Versioning.Plug.call(opts)

      assert conn.private.versioning_request == "1.0.0"
    end

    test "will default to the latest version if no header or fallback is present" do
      opts = Versioning.Plug.init(schema: MySchema)

      conn =
        conn(:get, "/")
        |> Versioning.Plug.call(opts)

      assert conn.private.versioning_request == "2.0.1"
    end

    test "will use the fallback module function if provided" do
      defmodule Fallback do
        def call(_conn) do
          "1.0.0"
        end
      end

      opts = Versioning.Plug.init(schema: MySchema, fallback: {Fallback, :call})

      conn =
        conn(:get, "/")
        |> Versioning.Plug.call(opts)

      assert conn.private.versioning_request == "1.0.0"
    end
  end
end

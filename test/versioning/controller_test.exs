defmodule Versioning.ControllerTest do
  use ExUnit.Case
  use Plug.Test

  describe "put_schema/2" do
    test "will put the schema in the conn prviate map" do
      conn = conn(:get, "/")

      assert conn.private[:versioning_schema] == nil

      conn = Versioning.Controller.put_schema(conn, MySchema)

      assert conn.private[:versioning_schema] == MySchema
    end
  end

  describe "apply_version/3" do
    test "will apply the version using a specificied header" do
      conn = conn(:get, "/") |> put_req_header("x-version", "1.0.0")
      conn = Versioning.Controller.apply_version(conn, "x-version")

      assert conn.private[:versioning_request] == "1.0.0"
    end

    test "will apply the version using a fallback module and function" do
      defmodule Fallback do
        def call(_conn) do
          "1.0.0"
        end
      end

      conn = conn(:get, "/")
      conn = Versioning.Controller.apply_version(conn, "x-version", {Fallback, :call})

      assert conn.private[:versioning_request] == "1.0.0"
    end

    test "will apply the version using the latest if no header is present" do
      conn =
        conn(:get, "/")
        |> Versioning.Controller.put_schema(MySchema)
        |> Versioning.Controller.apply_version()

      assert conn.private[:versioning_request] == "2.0.1"
    end
  end
end

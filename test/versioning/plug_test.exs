defmodule Versioning.PlugTest do
  use ExUnit.Case
  use Plug.Test

  setup_all do
    Application.ensure_all_started(:plug)
    :ok
  end

  defmodule MyChange do
    use Versioning.Change

    def up(versioning, _opts) do
      do_change(versioning, "_change_up")
    end

    def down(versioning, _opts) do
      do_change(versioning, "_change_down")
    end

    defp do_change(versioning, addition) do
      Versioning.update_data(versioning, "foo", fn val ->
        val <> addition
      end)
    end
  end

  defmodule MySchema do
    use Versioning.Schema, adapter: Versioning.Adapter.Semantic

    version "1.0.1" do
      type "Foo" do
        change(MyChange)
      end
    end

    version("1.0.0", do: [])
  end

  describe "init/1" do
    test "will raise an error if a schema is not provided" do
      assert_raise KeyError, fn ->
        Versioning.Plug.init(type: "Foo")
      end
    end

    test "will raise an error if a type is not provided" do
      assert_raise KeyError, fn ->
        Versioning.Plug.init(schema: MySchema)
      end
    end
  end

  describe "call/2" do
    test "will version POST request params" do
      opts = Versioning.Plug.init(schema: MySchema, type: "Foo")

      conn =
        conn(:post, "/", %{foo: "foo"})
        |> put_req_header("x-api-version", "1.0.0")
        |> Versioning.Plug.call(opts)

      assert conn.params == %{"foo" => "foo_change_up"}
    end

    test "will version PUT request params" do
      opts = Versioning.Plug.init(schema: MySchema, type: "Foo")

      conn =
        conn(:put, "/", %{foo: "foo"})
        |> put_req_header("x-api-version", "1.0.0")
        |> Versioning.Plug.call(opts)

      assert conn.params == %{"foo" => "foo_change_up"}
    end

    test "will version PATCH request params" do
      opts = Versioning.Plug.init(schema: MySchema, type: "Foo")

      conn =
        conn(:patch, "/", %{foo: "foo"})
        |> put_req_header("x-api-version", "1.0.0")
        |> Versioning.Plug.call(opts)

      assert conn.params == %{"foo" => "foo_change_up"}
    end

    test "will not version GET request params" do
      opts = Versioning.Plug.init(schema: MySchema, type: "Foo")

      conn =
        conn(:get, "/", %{foo: "foo"})
        |> put_req_header("x-api-version", "1.0.0")
        |> Versioning.Plug.call(opts)

      assert conn.params == %{"foo" => "foo"}
    end

    test "will not version DELETE request params" do
      opts = Versioning.Plug.init(schema: MySchema, type: "Foo")

      conn =
        conn(:delete, "/", %{foo: "foo"})
        |> put_req_header("x-api-version", "1.0.0")
        |> Versioning.Plug.call(opts)

      assert conn.params == %{"foo" => "foo"}
    end

    test "will not version params if method is not included in methods option" do
      opts = Versioning.Plug.init(schema: MySchema, type: "Foo", methods: [])

      conn =
        conn(:patch, "/", %{foo: "foo"})
        |> put_req_header("x-api-version", "1.0.0")
        |> Versioning.Plug.call(opts)

      assert conn.params == %{"foo" => "foo"}
    end

    test "will add the schema to the conn private map" do
      opts = Versioning.Plug.init(schema: MySchema, type: "Foo")

      conn =
        conn(:get, "/", %{foo: "foo"})
        |> put_req_header("x-api-version", "1.0.0")
        |> Versioning.Plug.call(opts)

      assert conn.private.versioning_schema == MySchema
    end

    test "will add the type to the conn private map" do
      opts = Versioning.Plug.init(schema: MySchema, type: "Foo")

      conn =
        conn(:get, "/", %{foo: "foo"})
        |> put_req_header("x-api-version", "1.0.0")
        |> Versioning.Plug.call(opts)

      assert conn.private.versioning_type == "Foo"
    end

    test "will add the version request to the conn private map" do
      opts = Versioning.Plug.init(schema: MySchema, type: "Foo")

      conn =
        conn(:get, "/", %{foo: "foo"})
        |> put_req_header("x-api-version", "1.0.0")
        |> Versioning.Plug.call(opts)

      assert conn.private.versioning_request == "1.0.0"
    end

    test "will default to the latest version if no header or fallback is present" do
      opts = Versioning.Plug.init(schema: MySchema, type: "Foo")

      conn =
        conn(:get, "/", %{foo: "foo"})
        |> Versioning.Plug.call(opts)

      assert conn.private.versioning_request == "1.0.1"
    end

    test "will use the fallback module function if provided" do
      defmodule Fallback do
        def call(_conn) do
          "1.0.0"
        end
      end

      opts = Versioning.Plug.init(schema: MySchema, type: "Foo", fallback: {Fallback, :call})

      conn =
        conn(:get, "/", %{foo: "foo"})
        |> Versioning.Plug.call(opts)

      assert conn.private.versioning_request == "1.0.0"
    end

    test "will set the status as a bad request if a schema error occurs" do
      opts = Versioning.Plug.init(schema: MySchema, type: "Foo")

      conn =
        conn(:patch, "/", %{foo: "foo"})
        |> put_req_header("x-api-version", "foo")
        |> Versioning.Plug.call(opts)

      assert conn.status == 400
      assert conn.resp_body == "Bad Request"
    end

    test "will use the error module function if provided" do
      defmodule Error do
        def call(conn) do
          Plug.Conn.resp(conn, :bad_request, "Bad Request!")
        end
      end

      opts = Versioning.Plug.init(schema: MySchema, type: "Foo", error: {Error, :call})

      conn =
        conn(:patch, "/", %{foo: "foo"})
        |> put_req_header("x-api-version", "foo")
        |> Versioning.Plug.call(opts)

      assert conn.status == 400
      assert conn.resp_body == "Bad Request!"
    end
  end
end

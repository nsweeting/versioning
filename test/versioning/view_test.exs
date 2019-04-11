defmodule Versioning.ViewTest do
  use ExUnit.Case
  use Plug.Test

  defmodule MyView do
    use Phoenix.View, root: "test/versioning"

    import Versioning.View

    def render("index.json", %{conn: conn, foos: foos}) do
      %{
        foos: render_versions(conn, "Foo", foos, MyView, "foo.json")
      }
    end

    def render("show.json", %{conn: conn, foo: foo}) do
      %{
        foo: render_version(conn, "Foo", foo, MyView, "foo.json")
      }
    end

    def render("foo.json", _assign) do
      %{
        foo: "bar"
      }
    end
  end

  test "will render many versions" do
    conn =
      conn(:get, "/")
      |> Phoenix.Controller.put_view(MyView)
      |> Versioning.Controller.put_schema(MySchema)
      |> Versioning.Controller.put_version("1.0.0")

    conn = Phoenix.Controller.render(conn, "index.json", foos: [%{foo: "bar"}, %{foo: "bar"}])
    body = Poison.decode!(conn.resp_body)

    assert Enum.count(body["foos"]) == 2
    assert List.first(body["foos"])["down"] == [15, 14, 13, 12, 11, 10, 7, 6, 5, 4, 1]
    assert List.last(body["foos"])["down"] == [15, 14, 13, 12, 11, 10, 7, 6, 5, 4, 1]
  end

  test "will render a version" do
    conn =
      conn(:get, "/")
      |> Phoenix.Controller.put_view(MyView)
      |> Versioning.Controller.put_schema(MySchema)
      |> Versioning.Controller.put_version("1.0.0")

    conn = Phoenix.Controller.render(conn, "show.json", foo: %{foo: "bar"})
    body = Poison.decode!(conn.resp_body)

    assert body["foo"]["down"] == [15, 14, 13, 12, 11, 10, 7, 6, 5, 4, 1]
  end
end

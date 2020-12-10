if Code.ensure_loaded?(Phoenix) do
  defmodule Versioning.View do
    @moduledoc """
    A set of functions used with `Phoenix` views.

    Typically, this module should be imported into your view modules. In a normal
    phoenix application, this can usually be done with the following:

        defmodule YourAppWeb do
        # ...

          def view do
            quote do
              use Phoenix.View, root: "lib/your_app_web/templates", namespace: "web"

              # ...

              import Versioning.View

              # ...
            end
          end
        end

    Please see the documentation at `Phoenix.View` for details on how to set up
    a typical view.

    In places that you would use `Phoenix.View.render_one/4`, this module provides
    `render_version/6`. In places that you would use `Phoenix.View.render_many/4`,
    this module provides `render_versions/6`.

    In order to use these functions, you must already have applied the schema and
    requested version to the conn. This is typically done with `Versioning.Plug`
    or through the helpers available in `Versioning.Controller`.

    ## Example

    Below is an example of how to use versioning in a typical view:

        defmodule YourApp.UserView do
          use YourApp.View

          def render("index.json", %{conn: conn, users: users}) do
            %{
              "users" => render_versions(conn, users, "User", UserView, "user.json"),
            }
          end

          def render("show.json", %{conn: conn, users: users}) do
            %{
              "user" => render_version(conn, users, "User", UserView, "user.json"),
            }
          end

          def render("user.json", %{user: user}) do
            %{"name" => user.name, "address" => user.address}
          end
        end

    A typical call, such as:

        render_many(users, UserView, "user.json")

    Is replaced by the following:

        render_versions(conn, users, "User", UserView, "user.json")

    In order to render versions of our data, we must pass the conn struct, our
    data to be versioned, the type the data represents in our schema, the view
    module to use, the template to use, as well as an additional assigns.

    The contents of the "user.json" template represent the latest version of your
    data. They will be run through your versioning schema to the version requested
    by the user. The output returned by your schema is what will be finally
    rendered.

    """

    @doc """
    Renders a versioned collection.

    A collection is any enumerable of structs. This function returns the
    rendered versioned collection in a list:

        render_versions(conn, users, "User", UserView, "show.json")

    Under the hood, this will render each item using `Phoenix.View.render/3` - so
    the latest version of the data should be represented in your view using typical
    view standards.

    After the data has been rendered, it will be passed to your schema and
    versioned to the version that has been requested.

    """
    @spec render_versions(Plug.Conn.t(), list(), binary(), module(), binary(), map()) :: [any()]
    def render_versions(conn, collection, type, view, template, assigns \\ %{}) do
      Enum.map(collection, fn resource ->
        data = Phoenix.View.render_one(resource, view, template, assigns)
        do_versioning(conn, data, type)
      end)
    end

    @doc """
    Renders a single versioned item if not nil.

        render_version(conn, user, "User", UserView, "show.json")

    This require

    Under the hood, this will render the item using `Phoenix.View.render/3` - so
    the latest version of the data should be represented in your view using typical
    view standards.

    After the data has been rendered, it will be passed to your schema and
    versioned to requested target version.

    """
    @spec render_version(Plug.Conn.t(), any(), binary(), module(), binary(), map()) :: any()
    def render_version(conn, resource, type, view, template, assigns \\ %{})
    def render_version(_conn, _type, nil, _view, _template, _assigns), do: nil

    def render_version(conn, resource, type, view, template, assigns) do
      data = Phoenix.View.render_one(resource, view, template, assigns)
      do_versioning(conn, data, type)
    end

    defp do_versioning(conn, data, type) do
      {schema, current, target} = get_versioning(conn)
      versioning = Versioning.new(data, current, target, type)

      case schema.run(versioning) do
        {:ok, versioning} -> versioning.data
        {:error, error} -> raise error
      end
    end

    defp get_versioning(conn) do
      schema = Versioning.Controller.fetch_schema!(conn)
      current = schema.__schema__(:latest, :string)
      target = Versioning.Controller.fetch_version!(conn)

      {schema, current, target}
    end
  end
end

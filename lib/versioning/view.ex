if Code.ensure_loaded?(Phoenix) do
  defmodule Versioning.View do
    @moduledoc """
    A set of functions typically used with `Phoenix` views.


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
    @spec render_versions(Plug.Conn.t(), binary(), list(), module(), binary(), map()) :: [any()]
    def render_versions(conn, collection, type, view, template, assigns \\ %{}) do
      assigns = to_map(assigns)
      {schema, current, target} = get_versioning(conn)

      Enum.map(collection, fn resource ->
        do_versioning(schema, current, target, type, resource, view, template, assigns)
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
    @spec render_version(Plug.Conn.t(), binary(), any(), module(), binary(), map()) :: any()
    def render_version(conn, type, resource, view, template, assigns \\ %{})
    def render_version(_conn, _type, nil, _view, _template, _assigns), do: nil

    def render_version(conn, resource, type, view, template, assigns) do
      assigns = to_map(assigns)
      {schema, current, target} = get_versioning(conn)
      do_versioning(schema, current, target, type, resource, view, template, assigns)
    end

    defp to_map(assigns) when is_map(assigns), do: assigns
    defp to_map(assigns) when is_list(assigns), do: :maps.from_list(assigns)

    defp assign_resource(assigns, view, resource) do
      as = Map.get(assigns, :as) || view.__resource__
      Map.put(assigns, as, resource)
    end

    defp do_versioning(schema, current, target, type, resource, view, template, assigns) do
      data = Phoenix.View.render(view, template, assign_resource(assigns, view, resource))
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

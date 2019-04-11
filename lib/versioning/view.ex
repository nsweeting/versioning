if Code.ensure_loaded?(Phoenix.View) do
  defmodule Versioning.View do
    @spec render_versions(Plug.Conn.t(), binary(), list(), module(), binary(), map()) :: [any()]
    def render_versions(conn, type, collection, view, template, assigns \\ %{}) do
      assigns = to_map(assigns)
      {schema, current, target} = get_versioning(conn)

      Enum.map(collection, fn resource ->
        do_versioning(schema, current, target, type, resource, view, template, assigns)
      end)
    end

    @spec render_version(Plug.Conn.t(), binary(), any(), module(), binary(), map()) :: any()
    def render_version(conn, type, resource, view, template, assigns \\ %{})
    def render_version(_conn, _type, nil, _view, _template, _assigns), do: nil

    def render_version(conn, type, resource, view, template, assigns) do
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

    defp get_schema(conn) do
      conn.private.versioning_schema ||
        raise ArgumentError, "expected versioning schema to be available in conn"
    end

    defp get_target(conn) do
      conn.private.versioning_request ||
        raise ArgumentError, "expected versioning request to be available in conn"
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
      schema = get_schema(conn)
      current = schema.__schema__(:latest, :string)
      target = get_target(conn)

      {schema, current, target}
    end
  end
end

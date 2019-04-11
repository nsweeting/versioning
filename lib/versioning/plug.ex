if Code.ensure_loaded?(Plug) do
  defmodule Versioning.Plug do
    @behaviour Plug

    import Plug.Conn

    @impl Plug
    def init(opts \\ []) do
      %{
        schema: Keyword.fetch!(opts, :schema),
        type: Keyword.fetch!(opts, :type),
        header: Keyword.get(opts, :header, "x-api-version"),
        fallback: Keyword.get(opts, :fallback, :latest),
        methods: Keyword.get(opts, :methods, ["POST", "PUT", "PATCH"]),
        error: Keyword.get(opts, :error, {__MODULE__, :bad_request})
      }
    end

    @impl Plug
    def call(conn, %{
          schema: schema,
          type: type,
          header: header,
          fallback: fallback,
          methods: methods,
          error: error
        }) do
      conn
      |> put_schema(schema)
      |> put_type(type)
      |> put_version(header, fallback)
      |> maybe_modify_params(methods, error)
    end

    @doc false
    def bad_request(conn) do
      resp(conn, :bad_request, "Bad Request")
    end

    defp put_schema(conn, schema) do
      put_private(conn, :versioning_schema, schema)
    end

    defp put_type(conn, type) do
      put_private(conn, :versioning_type, type)
    end

    defp put_version(conn, header, fallback) do
      version = get_version(conn, header, fallback)
      put_private(conn, :versioning_request, version)
    end

    defp get_version(conn, header, fallback) do
      case get_req_header(conn, header) do
        [version] ->
          version

        _ ->
          case fallback do
            :latest ->
              schema = conn.private.versioning_schema
              schema.__schema__(:latest, :string)

            {mod, fun} ->
              apply(mod, fun, [conn])
          end
      end
    end

    defp maybe_modify_params(conn, methods, error) do
      if conn.method in methods do
        modify_params(conn, error)
      else
        conn
      end
    end

    defp modify_params(conn, {mod, fun}) do
      schema = conn.private.versioning_schema
      request = conn.private.versioning_request
      latest = schema.__schema__(:latest, :string)
      type = conn.private.versioning_type
      versioning = Versioning.new(conn.params, request, latest, type)

      case schema.run(versioning) do
        {:ok, versioning} -> %{conn | params: versioning.data}
        {:error, _error} -> apply(mod, fun, [conn])
      end
    end
  end
end

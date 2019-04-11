if Code.ensure_loaded?(Plug) do
  defmodule Versioning.Controller do
    import Plug.Conn, only: [put_private: 3, get_req_header: 2]

    @type fallback :: :latest | {module(), atom()}
    @type methods :: [binary()]
    @type error :: {module(), atom()}

    @spec put_schema(Plug.Conn.t(), Versioning.Schema.t()) :: Plug.Conn.t()
    def put_schema(conn, schema) when is_atom(schema) do
      put_private(conn, :versioning_schema, schema)
    end

    def put_version(conn, version) do
      put_private(conn, :versioning_request, version)
    end

    @spec apply_version(Plug.Conn.t(), binary(), fallback()) :: Plug.Conn.t()
    def apply_version(conn, header \\ "x-api-version", fallback \\ :latest) do
      version = get_version(conn, header, fallback)
      put_version(conn, version)
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

    @spec update_params(Plug.Conn.t(), map(), binary()) :: {:ok, map()} | {:error, :bad_version}
    def update_params(conn, params, type) do
      schema = conn.private.versioning_schema
      request = conn.private.versioning_request
      latest = schema.__schema__(:latest, :string)
      versioning = Versioning.new(params, request, latest, type)

      case schema.run(versioning) do
        {:ok, versioning} -> {:ok, versioning.data}
        {:error, _error} -> {:error, :bad_version}
      end
    end
  end
end

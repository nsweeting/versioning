if Code.ensure_loaded?(Plug) do
  defmodule Versioning.Plug do
    @behaviour Plug

    @impl Plug
    def init(opts \\ []) do
      %{
        schema: Keyword.fetch!(opts, :schema),
        header: Keyword.get(opts, :header, "x-api-version"),
        fallback: Keyword.get(opts, :fallback, :latest)
      }
    end

    @impl Plug
    def call(conn, %{schema: schema, header: header, fallback: fallback}) do
      conn
      |> Versioning.Controller.put_schema(schema)
      |> Versioning.Controller.apply_version(header, fallback)
    end
  end
end

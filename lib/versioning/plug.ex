if Code.ensure_loaded?(Plug) do
  defmodule Versioning.Plug do
    @moduledoc """
    A Plug to assist with versioning an API.

    It requires one option:

      * `:schema`- the versioning schema to use when changing data.

    We can easily add our plug to a pipeline with the following:

        plug Versioning.Plug, schema: MySchema

    The above will store the schema within the conn struct, as well as attempt
    to apply a version to the request. This information can then be used when changing
    data to and from the latest version.

    ## Options

    * `:header` - the header to read when getting the version requested. This
      defaults to `"x-api-version"`.
    * `:fallback` - the fallback to occur if no version can be found in the header.
      This defaults to `:latest` - which is the latest version in our schema.

      Alternatively, you can specify a `{module, function}`. This enables more
      dynamic behaviour - such as fetching a version from a current user or token.
      The module and function must have an arity of 1 - the conn struct will be
      passed to it.

    ## Examples
    This plug can be mounted in a `Plug.Builder` pipeline as follows:

        defmodule MyPlug do
          use Plug.Builder

          plug Versioning.Plug, schema: MySchema, header: "myapi-version", fallback: {MyFallback, :call}
          plug :not_found

          def not_found(conn, _) do
            send_resp(conn, 404, "not found")
          end
        end

    """

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

if Code.ensure_loaded?(Plug) do
  defmodule Versioning.Controller do
    @moduledoc """
    A set of functions used with `Phoenix` controllers.

    Typically, this module should be imported into your controller modules. In a normal
    phoenix application, this can usually be done with the following:

        defmodule YourAppWeb do
        # ...

          def controller do
            quote do
              use Phoenix.Controller, namespace: MyAppWeb

              # ...

              import Versioning.Controller

              # ...
            end
          end
        end

    Please see the documentation at `Phoenix.Controller` for details on how to
    set up a typical controller.

    This module is mainly used to convert raw params from the version that the
    request data represents, to the latest version that your "context" application
    expects.

    ## Example

    Below is an example of how to use versioning in a typical controller:

        defmodule MyController do
          use MyAppWeb, :controller

          plug Versioning.Plug, schema: MyVersioningSchema

          def update(conn, %{"id" => id, "user" => params}) do
            with {:ok, params} <- params_version(conn, params, "User"),
                 {:ok, user} <- Blog.fetch_user(id),
                 {:ok, user} <- Blog.update_user(user) do
              render(conn, "show.json", user: user)
            end
          end
        end

    The `params_version/3` function accepts a conn, a set of params representing
    whatever version of the data the user uses, as well as the type of the data.
    It will run the params through your schema, returning the results.

    """

    @doc """
    Stores the schema for versioning.

    ## Examples

        Versioning.Controller.put_schema(conn, MySchema)

    """
    @spec put_schema(Plug.Conn.t(), Versioning.Schema.t()) :: Plug.Conn.t()
    def put_schema(conn, schema) when is_atom(schema) do
      Plug.Conn.put_private(conn, :versioning_schema, schema)
    end

    @doc """
    Fetches the current schema.

    Returns `{:ok, schema}` on success, or `:error` if no schema exists.

    ## Examples

        iex> conn = Versioning.Controller.put_schema(conn, MySchema)
        iex> Versioning.Controller.fetch_schema(conn)
        {:ok, MySchema}

    """
    @spec fetch_schema(Plug.Conn.t()) :: {:ok, Versioning.Schema.t()} | :error
    def fetch_schema(conn) do
      Map.fetch(conn.private, :versioning_schema)
    end

    @doc """
    Fetches the current schema or errors if empty.

    Returns `schema` or raises a `Versioning.MissingSchemaError`.

    ## Examples

        iex> conn = Versioning.Controller.put_schema(conn, MySchema)
        iex> Versioning.Controller.fetch_schema!(conn)
        MySchema

    """
    @spec fetch_schema!(Plug.Conn.t()) :: Versioning.Schema.t()
    def fetch_schema!(conn) do
      Map.get(conn.private, :versioning_schema) || raise Versioning.MissingSchemaError
    end

    @doc """
    Stores the request version.

    ## Examples

        Versioning.Controller.put_version(conn, "1.0.0")

    """
    @spec put_version(Plug.Conn.t(), binary()) :: Plug.Conn.t()
    def put_version(conn, version) do
      Plug.Conn.put_private(conn, :versioning_version, version)
    end

    @doc """
    Fetches the current request version.

    Returns `{:ok, version}` on success, or `:error` if no version exists.

    ## Examples

        iex> conn = Versioning.Controller.put_version(conn, "1.0.0")
        iex> Versioning.Controller.fetch_version(conn)
        {:ok, "1.0.0"}

    """
    @spec fetch_version(Plug.Conn.t()) :: {:ok, binary()} | :error
    def fetch_version(conn) do
      Map.fetch(conn.private, :versioning_version)
    end

    @doc """
    Fetches the current request version or errors if empty.

    Returns `version` or raises a `Versioning.MissingVersionError`.

    ## Examples

        iex> conn = Versioning.Controller.put_schema(conn, "1.0.0")
        iex> Versioning.Controller.fetch_version!(conn)
        "1.0.0"

    """
    @spec fetch_version!(Plug.Conn.t()) :: Versioning.Schema.t()
    def fetch_version!(conn) do
      Map.get(conn.private, :versioning_version) || raise Versioning.MissingVersionError
    end

    @doc """
    Applies a version using the header or fallback.

    The schema must already be stored on the conn to use this function.

    The fallback is used if the header is not present. Its value can be `:latest`,
    representing the latest version on the schema, or a `{module, function}`.
    This module and function will be called with the conn.

    """
    @spec apply_version(Plug.Conn.t(), binary(), :latest | {module(), atom()}) :: Plug.Conn.t()
    def apply_version(conn, header \\ "x-api-version", fallback \\ :latest) do
      version = get_version(conn, header, fallback)
      put_version(conn, version)
    end

    defp get_version(conn, header, fallback) do
      case Plug.Conn.get_req_header(conn, header) do
        [version] ->
          version

        _ ->
          case fallback do
            :latest ->
              schema = fetch_schema!(conn)
              schema.__schema__(:latest, :string)

            {mod, fun} ->
              apply(mod, fun, [conn])
          end
      end
    end

    @doc """
    Performs versioning on the `params` using the given `type`.

    The schema and request version must already be stored on the conn to use
    this function.

    Returns `{:ok, params}` with the new versioned params, or `{:error, :bad_version}`
    if the schema does not contain the version requested.

    """
    @spec params_version(Plug.Conn.t(), map(), binary()) :: {:ok, map()} | {:error, :bad_version}
    def params_version(conn, params, type) do
      schema = fetch_schema!(conn)
      current = fetch_version!(conn)
      target = schema.__schema__(:latest, :string)
      versioning = Versioning.new(params, current, target, type)

      case schema.run(versioning) do
        {:ok, versioning} -> {:ok, versioning.data}
        {:error, _error} -> {:error, :bad_version}
      end
    end
  end
end

defmodule Versioning do
  @moduledoc """
  Versionings allow data to be changed to different versions of itself.

  A the heart of our versioning is the `Versioning` struct. A `Versioning` struct
  contains the following fields:

    - `:current` - The current version that our data represents.
    - `:target` - The version that we want our data to be changed into.
    - `:type` - The type of data we are working with. If we are working with structs,
    this will typically be the struct name in string format, eg: `"Post"`
    - `:data` - The underlying data that we want to change. For structs, like our
    `Post`, be aware that we typically have our data as a bare map since it
    is easier to transform.
    - `:changes` - A list of change modules that have been applied against the versioning.
    The first change module would be the most recent module run.
    - `:changed` - A boolean representing if change modules have been applied.
    - `:assigns` - A map of arbitrary data we can use to store additonal information in.

  ## Example

      Versioning.new(%Post{}, "2.0.0", "1.0.0")

  With the above, we have created a versioning of a `Post` struct. This represents
  us wanting to transform our post from a version "2.0.0" to an older "1.0.0"
  version.

  ## Schemas

  The versioning struct is used in combination with a `Versioning.Schema`, which
  allows us to map out the changes that should occur through versions. Please see
  the `Versioning.Schema` documentation for more details.
  """

  @derive {Inspect, only: [:type, :current, :target, :data, :changed]}
  defstruct [
    :current,
    :target,
    :parsed_current,
    :parsed_target,
    :type,
    :schema,
    data: %{},
    assigns: %{},
    changed: false,
    changes: []
  ]

  @type version :: binary() | nil
  @type type :: binary() | nil
  @type data :: %{optional(binary()) => any()}
  @type assigns :: %{optional(atom()) => any()}
  @type t :: %__MODULE__{
          current: version(),
          target: version(),
          type: type(),
          data: map(),
          schema: Versioning.Schema.t(),
          assigns: assigns(),
          changed: boolean(),
          changes: [Versioning.Change.t()]
        }

  @doc """
  Creates a new versioning using the data provided.

  If a struct is the data, and no type is provided, the struct module is set as
  the versioning `:type` (as described in `put_type/2`), and the struct is turned
  into a string-key map that is used for the `:data`.

  ## Examples

      # These are equivalent
      Versioning.new(%{"foo" => "bar"}, "2.0.0", "1.0.0", SomeData)
      Versioning.new(%{foo: "bar"}, "2.0.0", "1.0.0", "SomeData")
      Versioning.new(%SomeData{foo: "bar"}, "2.0.0", "1.0.0")

  """
  @spec new(map(), version(), version(), type()) :: Verisoning.t()
  def new(data \\ %{}, current \\ nil, target \\ nil, type \\ nil)

  def new(%{__struct__: struct_type} = data, current, target, type) do
    data = Map.from_struct(data)
    new(data, current, target, type || struct_type)
  end

  def new(data, current, target, type) when is_map(data) do
    %Versioning{}
    |> put_data(data)
    |> put_current(current)
    |> put_target(target)
    |> put_type(type)
  end

  @doc """
  Puts the current version that the data represents.

  The version should be represented somewhere within your `Versioning.Schema`.
  This will become the "starting" point from which change modules will be run.

  ## Examples

      Versioning.put_current(versioning, "0.1.0")

  """
  @spec put_current(Versioning.t(), version()) :: Versioning.t()
  def put_current(%Versioning{} = versioning, current) do
    %{versioning | current: current}
  end

  @doc """
  Puts the target version that the data will be transformed to.

  The version should be represented somewhere within your `Versioning.Schema`.
  Once the change modules in the target version are run, no more changes will
  be made.

  ## Examples

      Versioning.put_target(versioning, "0.1.0")

  """
  @spec put_target(Versioning.t(), version()) :: Versioning.t()
  def put_target(%Versioning{} = versioning, target) do
    %{versioning | target: target}
  end

  @doc """
  Puts the type of the versioning data.

  Typically, if working with data that is associated with a struct, this will
  be the struct trailing module name in binary format. For example,
  `MyApp.Foo` will be represented as `"Foo"`.

  When running a versioning through a schema, only the changes that match the
  type set on the versioning will be run.

  ## Examples

      # These are equivalent
      Versioning.put_type(versioning, "Post")
      Versioning.put_type(versioning, MyApp.Post)

  """
  @spec put_type(Versioning.t(), type() | atom()) :: Versioning.t()
  def put_type(%Versioning{} = versioning, nil) do
    %{versioning | type: nil}
  end

  def put_type(%Versioning{} = versioning, type) when is_atom(type) do
    type =
      type
      |> to_string()
      |> String.split(".")
      |> List.last()

    put_type(versioning, type)
  end

  def put_type(%Versioning{} = versioning, type) when is_binary(type) do
    %{versioning | type: type}
  end

  @doc """
  Assigns a value to a key in the versioning.

  The “assigns” storage is meant to be used to store values in the versioning so
  that change modules in your schema can access them. The assigns storage is a map.

  ## Examples

      iex> versioning.assigns[:hello]
      nil
      iex> versioning = Versioning.assign(versioning, :hello, :world)
      iex> versioning.assigns[:hello]
      :world

  """
  @spec assign(Versioning.t(), atom(), any()) :: Versioning.t()
  def assign(%Versioning{assigns: assigns} = versioning, key, value) do
    %{versioning | assigns: Map.put(assigns, key, value)}
  end

  @doc """
  Returns and removes the value associated with `key` within the `data` of `versioning`.

  If `key` is present in `data` with value `value`, `{value, new_versioning}` is
  returned where `new_versioning` is the result of removing `key` from `data`. If `key`
  is not present in `data`, `{default, new_versioning}` is returned.

  ## Examples

      iex> Versioning.pop_data(versioning, "foo")
      {"bar", versioning}
      iex> Versioning.pop_data(versioning, "foo")
      {nil, versioning}

  """
  @spec pop_data(Versioning.t(), any()) :: {any(), Versioning.t()}
  def pop_data(%Versioning{data: data} = versioning, key, default \\ nil) do
    {result, data} = Map.pop(data, key, default)
    {result, %{versioning | data: data}}
  end

  @doc """
  Gets the value for a specific `key` in the `data` of `versioning`.

  If `key` is present in `data` with value `value`, then `value` is returned.
  Otherwise, `default` is returned (which is `nil` unless specified otherwise).

  ## Examples

      iex> Versioning.get_data(versioning, "foo")
      "bar"
      iex> Versioning.get_data(versioning, "bar")
      nil
      iex> Versioning.get_data(versioning, "bar", "baz")
      "baz"

  """
  @spec get_data(Versioning.t(), binary(), term()) :: any()
  def get_data(%Versioning{data: data}, key, default \\ nil) do
    Map.get(data, key, default)
  end

  @doc """
  Fetches the value for a specific `key` in the `data` of `versioning`.

  If `data` contains the given `key` with value `value`, then `{:ok, value}` is
  returned. If `data` doesn't contain `key`, `:error` is returned.

  ## Examples

      iex> Versioning.fetch_data(versioning, "foo")
      {:ok, "bar"}
      iex> Versioning.fetch_data(versioning, "bar")
      :error

  """
  @spec fetch_data(Versioning.t(), binary()) :: {:ok, any()} | :error
  def fetch_data(%Versioning{data: data}, key) do
    Map.fetch(data, key)
  end

  @doc """
  Puts the full data in the versioning.

  The data represents the base of what will be modified when a versioning is
  run through a schema.

  Data must be a map. If a struct is provided, the struct will be turned into
  a basic map - though its type information will not be inferred.

  The keys of data will always be strings. If passed an

  ## Examples

      iex> versioning = Versioning.put_data(versioning, %{"foo" => "bar"})
      iex> versioning.data
      %{"foo" => "bar"}

  """
  @spec put_data(Versioning.t(), map()) :: Versioning.t()
  def put_data(%Versioning{} = versioning, data) when is_map(data) do
    data = deep_stringify(data)
    %{versioning | data: data}
  end

  @doc """
  Puts the given `value` under `key` within the `data` of `versioning`.

  ## Examples
      iex> Versioning.put_data(versioning, "foo", "bar")
      iex> versioning.data["foo"]
      "bar"

  """
  @spec put_data(Versioning.t(), binary(), any()) :: Versioning.t()
  def put_data(%Versioning{data: data} = versioning, key, value)
      when is_map(data) and is_binary(key) do
    value = if is_map(value), do: deep_stringify(value), else: value
    %{versioning | data: Map.put(data, key, value)}
  end

  @doc """
  Updates the `key` within the `data` of `versioning` using the given function.

  If the `data` does not contain `key` - nothing occurs. If it does, the `fun`
  is invoked with argument `value` and its result is used as the new value of
  `key`.

  ## Examples
      iex> Versioning.update_data(versioning, "foo", fn _val -> "bar" end)
      iex> versioning.data["foo"]
      "bar"

  """
  @spec update_data(Versioning.t(), binary(), (any() -> any())) :: Versioning.t()
  def update_data(%Versioning{} = versioning, key, fun)
      when is_binary(key) and is_function(fun, 1) do
    if Map.has_key?(versioning.data, key) do
      val = fun.(versioning.data[key])
      put_data(versioning, key, val)
    else
      versioning
    end
  end

  defp deep_stringify(%{__struct__: _} = struct) do
    struct |> Map.from_struct() |> deep_stringify()
  end

  defp deep_stringify(map) when is_map(map) do
    Enum.reduce(map, %{}, fn
      {key, val}, acc when is_map(val) ->
        val = deep_stringify(val)
        Map.put(acc, to_string(key), val)

      {key, val}, acc ->
        Map.put(acc, to_string(key), val)
    end)
  end
end

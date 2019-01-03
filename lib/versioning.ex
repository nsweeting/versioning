defmodule Versioning do
  @moduledoc """
  Versionings allow data to be manipulated to different versions of itself.

  A the heart of our versioning is the `Versioning` struct. A `Versioning` struct
  contains the following fields:

    - `:current` - The current version that our data represents.
    - `:target` - The version that we want our data to be changed into.
    - `:type` - The type of data we are working with. If we are working with structs,
    this will typically be the struct name, eg: `Post`
    - `:data` - The underlying data that we want to change. For structs, like our
    `Post`, be aware that we typically have our data as a bare map since it
    is easier to transform.
    - `:changed` - A boolean representing whether a change operation has occured.
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

  @type version :: Version.t() | binary() | nil
  @type type :: atom() | nil
  @type data :: map() | nil
  @type assigns :: %{optional(atom()) => any()}
  @type t :: %__MODULE__{
          current: Version.t() | nil,
          target: Version.t() | nil,
          type: type(),
          data: data(),
          changed: boolean(),
          assigns: assigns()
        }

  defstruct [
    :current,
    :target,
    :type,
    :data,
    changed: false,
    assigns: %{}
  ]

  @doc """
  Creates a new versioning using the data provided.

  If a struct is the data, and no type is provided, the struct module is set as
  the versioning `:type`, and the struct is turned into a map that is used for
  the `:data`.

  ## Examples

      Versioning.new(%{}, "2.0.0", "1.0.0", SomeData)
      Versioning.new(%SomeData{}, "2.0.0", "1.0.0")

  """
  @spec new(data(), version(), version(), type()) :: Verisoning.t()
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

  def put_current(%Versioning{} = versioning, current) do
    current = parse_version(current)
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
    target = parse_version(target)
    %{versioning | target: target}
  end

  @doc """
  Puts the type of the versioning data.

  Typically, if working with data that is associated with a struct, this will
  be the struct module name.

  When running a versioning through a schema, only the changes that match the
  type set on the versioning will be run.

  ## Examples

      Versioning.put_type(versioning, Article)

  """
  @spec put_type(Versioning.t(), type()) :: Versioning.t()
  def put_type(%Versioning{} = versioning, type) do
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

      iex> Versioning.pop_data(versioning, :a)
      {1, versioning}
      iex> Versioning.pop_data(versioning, :a)
      {nil, versioning}

  """
  @spec pop_data(Versioning.t(), any()) :: {any(), Versioning.t()}
  def pop_data(%Versioning{data: data} = versioning, key, default \\ nil) do
    {result, data} = Map.pop(data, key, default)
    {result, %{versioning | data: data}}
  end

  @doc """
  Puts the full data in the versioning.

  The data represents what will be modified when a versioning is run through a
  schema.

  Data must be a map. If a struct is provided, the struct will be turned into
  a basic map - though its type information will not be inferred.

  ## Examples

      iex> versioning = Versioning.put_data(versioning, %{foo: :bar})
      iex> versioning.data
      %{foo: :bar}

  """
  @spec put_data(Versioning.t(), map()) :: Versioning.t()
  def put_data(%Versioning{} = versioning, %{__struct__: _} = data) do
    data = Map.from_struct(data)
    %{versioning | data: data}
  end

  def put_data(%Versioning{} = versioning, data) when is_map(data) do
    %{versioning | data: data}
  end

  @doc """
  Puts the given `value` under `key` within the `data` of `versioning`.

  ## Examples
      iex> Versioning.put_data(versioning, :a, 1)
      iex> versioning.data.a
      1

  """
  @spec put_data(Versioning.t(), atom(), any()) :: Versioning.t()
  def put_data(%Versioning{data: data} = versioning, key, value) when is_map(data) do
    %{versioning | data: Map.put(data, key, value)}
  end

  defp parse_version(%Version{} = version) do
    version
  end

  defp parse_version(version) when is_binary(version) do
    case Version.parse(version) do
      {:ok, version} -> version
      _ -> nil
    end
  end

  defp parse_version(_version) do
    nil
  end

  defimpl Inspect do
    import Inspect.Algebra

    @doc false
    def inspect(versioning, opts) do
      list =
        for attr <- [:current, :target, :type, :changed] do
          {attr, Map.get(versioning, attr)}
        end

      surround_many("#Versioning<", list, ">", opts, fn
        {:current, nil}, _opts -> concat("current: ", to_doc(nil, opts))
        {:current, current}, _opts -> concat("current: ", to_string(current))
        {:target, nil}, _opts -> concat("target: ", to_doc(nil, opts))
        {:target, target}, _opts -> concat("target: ", to_string(target))
        {:type, type}, opts -> concat("type: ", to_doc(type, opts))
        {:changed, changed}, _opts -> concat("changed: ", to_doc(changed, opts))
      end)
    end
  end
end

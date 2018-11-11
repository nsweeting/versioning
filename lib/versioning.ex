defmodule Versioning do
  @moduledoc """
  Documentation to come.
  """

  @type target :: binary()
  @type type :: atom()
  @type data :: any()
  @type t :: %__MODULE__{
          target: target(),
          type: type(),
          data: data(),
          changed: boolean(),
          assigns: map()
        }

  defstruct [
    :target,
    :type,
    :data,
    changed: false,
    assigns: %{}
  ]

  @doc """
  Creates a new versioning struct using the version and data provided.

  If provided a struct as the data, the struct module is set as the versioning
  `:type`, and the struct is turned into a map that is used for the `:data`.

  ## Parameters
    - target: The target version that our data should be transformed to.
    - data: The data to be changed.
  """
  @spec new(binary(), any()) :: Versioning.t()
  def new(target, %{__struct__: type} = data) do
    data = Map.from_struct(data)
    new(target, type, data)
  end

  def new(target, data) when is_map(data) do
    new(target, Map, data)
  end

  def new(target, data) when is_list(data) do
    new(target, List, data)
  end

  def new(target, data) when is_integer(data) do
    new(target, Integer, data)
  end

  def new(target, data) when is_float(data) do
    new(target, Float, data)
  end

  @doc """
  Creates a new versioning struct using the version, type and data provided.

  ## Parameters
    - target: The target version that our data should be transformed to.
    - type: The type of the data.
    - data: The data to be changed.
  """
  @spec new(target(), type(), data()) :: Versioning.t()
  def new(target, type, data) do
    %Versioning{
      target: target,
      type: type,
      data: data
    }
  end

  @doc """
  Puts a key and value into the versioning assigns.

  ## Parameters
    - versioning: A `Versioning` struct.
    - key: The key to be used for the assigns.
    - value: The value to be assigned to the key.
  """
  @spec assign(Versioning.t(), atom(), any()) :: Versioning.t()
  def assign(%Versioning{assigns: assigns} = versioning, key, value) do
    %{versioning | assigns: Map.put(assigns, key, value)}
  end

  @doc """
  Transforms a versioning using the provided changes. Changes can represent a single
  module or list modules that adhere to the `Versioning.Change` behaviour.

  ## Parameters
    - versioning: A `Versioning` struct.
    - change: The changes to be applied to the versioning.
  """
  @spec change(Versioning.t(), atom() | [atom()]) :: Versioning.t()
  def change(%Versioning{} = versioning, change) when is_atom(change) do
    versioning = %{versioning | changed: true}
    apply(change, :change, [versioning])
  end

  def change(%Versioning{} = versioning, changes) when is_list(changes) do
    Enum.reduce(changes, versioning, fn change, versioning ->
      change(versioning, change)
    end)
  end

  defimpl Inspect, for: Versioning do
    import Inspect.Algebra

    @doc false
    def inspect(versioning, opts) do
      list =
        for attr <- [:target, :type, :changed] do
          {attr, Map.get(versioning, attr)}
        end

      surround_many("#Versioning<", list, ">", opts, fn
        {:target, target}, opts -> concat("target: ", to_doc(target, opts))
        {:type, type}, opts -> concat("type: ", to_doc(type, opts))
        {:changed, changed}, _opts -> concat("changed: ", to_doc(changed, opts))
      end)
    end
  end
end

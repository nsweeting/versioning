defmodule Versioning.Change do
  @moduledoc """
  Defines a versioning change.

  A versioning change is used to make small changes to data of a certain type.
  They are used within a `Versioning.Schema`. Changes should attempt to be as
  focused as possible to ensure complexity is kept to a minimum.

  ## Example

      defmodule MyApp.V1.Post.StatusChange do
        use Versioning.Change

        @desc "The 'active' attribute has been changed in favour of the 'status' attribute"

        @impl Versioning.Change
        def down(versioning, _opts) do
          case Versioning.pop_data(versioning, :status) do
            {:active, versioning} -> Versioning.put_data(versioning, :active, true)
            {_, versioning} -> Versioning.put_data(versioning, :active, false)
          end
        end

        @impl Versioning.Change
        def up(versioning, _opts) do
          case Versioning.pop_data(versioning, "active") do
            {true, versioning} -> Versioning.put_data(versioning, "status", "active")
            {false, versioning} -> Versioning.put_data(versioning, "status", "hidden")
            {_, versioning} -> versioning
          end
        end
      end

  The above change module represents us modifying our `Post` data to support a
  new attribute - `status` - which replaces the previous `active` attribute.

  When changing data "down", we must remove the `status` attribte, and replace it
  with a value that represents the previous `active` attribute. When changing
  data "up", we must remove the `active` attribute and replace it with a value that
  represents the new `status` attribute.

  ## Descriptions

  Change modules can optionally include a `@desc` module attribute. This will be
  used to describe the changes made in the change module when constructing changelogs.
  Please see the `Versioning.Changelog` documentation for more information on changelogs.
  """

  @doc """
  Accepts a `Versioning` struct, and applies changes upward.

  ## Examples

      MyApp.Change.up(versioning)

  """
  @callback up(versioning :: Versioning.t(), opts :: any()) :: Versioning.t()

  @doc """
  Accepts a `Versioning` struct and applies changes downward.

  ## Examples

      MyApp.Change.down(versioning)

  """
  @callback down(versioning :: Versioning.t(), opts :: any()) :: Versioning.t()

  defmacro __using__(_opts) do
    quote do
      @behaviour Versioning.Change

      @desc "No Description"

      @before_compile Versioning.Change
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def __description__ do
        @desc
      end
    end
  end
end

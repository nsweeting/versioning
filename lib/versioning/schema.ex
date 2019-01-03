defmodule Versioning.Schema do
  @moduledoc """
  Defines a versioning schema.

  A versioning schema is used to translate data through a series of steps from
  a "current" version to a "target" version. This is useful in maintaining backwards
  compatability with older versions of API's without enormous complication.

  ## Example

      defmodule MyApp.Versioning do
        use Versioning.Schema

        version("2.0.0", do: [])

        version "1.1.0" do
          type User do
            change(MyApp.V1.User.SomeChange)
          end
        end

        version "1.0.1" do
          type Post do
            change(MyApp.V1.Post.StatusChange)
          end

          type Any do
            change(MyApp.V1.Any.TimestampChange)
          end
        end

        version("1.0.0", do: [])
      end

  In the example above, we have 4 versions. Our current version is represented by
  the top version - `"2.0.0"`. Our oldest version is at the bottom - `"1.0.0"`.

  We define a version with the `version/2` macro. Within a version, we specify types
  that have been manipulated. We define a type with the `type/2` macro. Within
  a type, we specify changes that have occured. We define a change with the `change/2`
  macro.

  ## Running Schemas

  Lets say we have a `%Post{}` struct that we would like to run through our schema.

      post = %Post{status: :enabled}
      Versioning.new(post, "2.0.0", "1.0.0")

  We have created a new versioning of our post struct. The versioning sets the
  data, current version, target version, as well as type. We can now run our
  versioning through our schema.

      MyApp.Versioning.run(versioning)

  With the above, our versioning struct will first be run through our MyApp.V1.PostStatusChange
  change module as the type matches our versioning type. It will then be run through
  our MyApp.V1.TimestampChange as it also matches on the `Any` type (more detail
  available at the `change/2` macro).

  With the above, we are transforming our data "down" through our schema. But we
  can also transform it "up".

      post = %{"status" => "some_status"}
      Versioning.new(post, "1.0.0", "2.0.0", Post)

  Typically, when transforming "up", data is coming from external sources, so is
  string-based maps. This should be considered when bulding our change modules.

  If we were to run our new versioning through the schema, the same change modules
  would be run, but in reverse order.

  ## Change Modules

  At the heart of versioning schemas are change modules. You can find more information
  about creating change modules at the `Versioning.Change` documentation.
  """

  alias Versioning.Schema.{Compiler, Executer}

  @type direction :: :up | :down

  @type change :: {atom(), list()}

  @type type :: {atom(), [change()]}

  @type version :: {binary(), [type()]}

  @type schema :: [version()]

  @type result :: Versioning.t() | [Versioning.t()] | no_return()

  defmacro __using__(_opts) do
    quote do
      def run(versioning_or_versionings) do
        Executer.run(__MODULE__, versioning_or_versionings)
      end

      def schema(direction) do
        __schema__(direction)
      end

      import Versioning.Schema

      Module.register_attribute(__MODULE__, :_schema, accumulate: true)

      @before_compile Versioning.Schema
    end
  end

  @doc """
  Defines a version in the schema.

  A version must be in string format, and must adhere to requirements of the
  Elixir `Version` module. This means SemVer 2.0.

  A version can only be represented once within a schema. The most recent version
  should be at the top of your schema, and the oldest at the bottom.

  Any issue with the above will raise a `Versioning.CompileError` during schema
  compilation.

  ## Example

      version "1.0.1" do

      end

      version("1.0.0", do: [])
  """
  defmacro version(version, do: block) do
    quote do
      @_schema {:version, unquote(version)}
      unquote(block)
    end
  end

  @doc """
  Defines a type within a version.

  A type can only be represented once within a version, and must be an atom. Any
  issue with this will raise a `Versioning.CompileError` during schema compilation.

  Any changes within a type that matches the type on a `Versioning` struct will
  be run. There is also the special case `Any` type, which lets you define changes that
  will be run against any versioning - regardless of type.

  ## Example

      version "1.0.1" do
        type Any do

        end

        type Foo do

        end
      end
  """
  defmacro type(object, do: block) do
    quote do
      @_schema {:type, unquote(object)}
      unquote(block)
    end
  end

  @doc """
  Defines a change within a type.

  A change must be represented by a module that implements the `Versioning.Change`
  behaviour. You can also set options that will be passed along to the change module.

  Changes are run in the order they are placed, based on the direction of the
  version change. For instance, if a schema was being run "down" for the example below,
  MyChangeModule would be run first, followed by MyOtherChangeModule. This would
  be reversed if running "up" a schema.

  ## Example

      version "1.0.1" do
        type Foo do
          change(MyChangeModule)
          change(MyOtherChangeModule, [foo: :bar])
        end
      end
  """
  defmacro change(change, init \\ []) do
    quote do
      @_schema {:change, unquote(change), unquote(init)}
    end
  end

  defmacro __before_compile__(env) do
    {schema_down, schema_up} = Compiler.build(env)

    quote do
      @schema_down unquote(schema_down)
      @schema_up unquote(schema_up)

      def __schema__(:down) do
        @schema_down
      end

      def __schema__(:up) do
        @schema_up
      end
    end
  end
end

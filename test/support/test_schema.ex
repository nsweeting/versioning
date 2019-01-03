for x <- 1..15 do
  contents =
    quote do
      use Versioning.Change

      @desc to_string(unquote(x))

      @impl true
      def up(versioning, _opts) do
        {up, versioning} = Versioning.pop_data(versioning, :up, [])
        Versioning.put_data(versioning, :up, up ++ [unquote(x)])
      end

      @impl true
      def down(versioning, _opts) do
        {down, versioning} = Versioning.pop_data(versioning, :down, [])
        Versioning.put_data(versioning, :down, down ++ [unquote(x)])
      end
    end

  Module.create(:"Elixir.TestChange#{x}", contents, Macro.Env.location(__ENV__))
end

defmodule(Foo, do: defstruct(down: [], up: []))
defmodule(Bar, do: defstruct(down: [], up: []))

defmodule TestSchema do
  use Versioning.Schema

  version("2.0.1", do: [])

  version "2.0.0" do
    type Any do
      change(TestChange15)
      change(TestChange14)
    end

    type Foo do
      change(TestChange13)
      change(TestChange12)
    end
  end

  version "1.1.1" do
    type Any do
      change(TestChange11)
      change(TestChange10)
    end
  end

  version "1.1.0" do
    type Bar do
      change(TestChange9)
      change(TestChange8)
    end
  end

  version "1.0.2" do
    type Foo do
      change(TestChange7)
      change(TestChange6)
    end
  end

  version "1.0.1" do
    type Any do
      change(TestChange5)
      change(TestChange4)
    end

    type Bar do
      change(TestChange3)
      change(TestChange2)
    end

    type Foo do
      change(TestChange1)
    end
  end

  version("1.0.0", do: [])
end

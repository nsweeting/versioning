for x <- 1..15 do
  contents =
    quote do
      use Versioning.Change

      @desc to_string(unquote(x))

      @impl true
      def up(versioning, _opts) do
        {up, versioning} = Versioning.pop_data(versioning, "up", [])
        Versioning.put_data(versioning, "up", up ++ [unquote(x)])
      end

      @impl true
      def down(versioning, _opts) do
        {down, versioning} = Versioning.pop_data(versioning, "down", [])
        Versioning.put_data(versioning, "down", down ++ [unquote(x)])
      end
    end

  Module.create(:"Elixir.TestChange#{x}", contents, Macro.Env.location(__ENV__))
end

defmodule(Foo, do: defstruct(down: [], up: []))
defmodule(Bar, do: defstruct(down: [], up: []))

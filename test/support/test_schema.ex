for x <- 1..17 do
  contents =
    quote do
      use Versioning.Change

      @desc "#{unquote(x)}"
      def change(version) do
        %{version | data: [:"#{unquote(x)}" | version.data]}
      end
    end

  Module.create(:"Elixir.TestChange#{x}", contents, Macro.Env.location(__ENV__))
end

defmodule Versioning.TestSchema do
  use Versioning.Schema

  version "5" do
    change_all do
      TestChange16
    end

    change Foo do
      TestChange15
    end

    change Bar do
      [TestChange13, TestChange14]
    end

    change Baz do
      [TestChange17]
    end
  end

  version "4" do
    change Foo do
      TestChange12
    end

    change Bar do
      [TestChange11]
    end

    change Baz do
      TestChange10
    end
  end

  version "3" do
    change Foo do
      [TestChange9]
    end

    change Bar do
      [TestChange8]
    end

    change Baz do
      []
    end
  end

  version "2" do
    change Foo do
      [TestChange6, TestChange7]
    end

    change Bar do
      [TestChange5]
    end

    change Baz do
      [TestChange4]
    end
  end

  version "1" do
    change_all do
      TestChange3
    end

    change Foo do
      [TestChange2]
    end

    change Bar do
      [TestChange1]
    end

    change Baz do
      []
    end
  end
end

defmodule MySchema do
  use Versioning.Schema, adapter: Versioning.Adapter.Semantic

  version("2.0.1", do: [])

  version "2.0.0" do
    type "All!" do
      change(TestChange15)
      change(TestChange14)
    end

    type "Foo" do
      change(TestChange13)
      change(TestChange12)
    end
  end

  version "1.1.1" do
    type "All!" do
      change(TestChange11)
      change(TestChange10)
    end
  end

  version "1.1.0" do
    type "Bar" do
      change(TestChange9)
      change(TestChange8)
    end
  end

  version "1.0.2" do
    type "Foo" do
      change(TestChange7)
      change(TestChange6)
    end
  end

  version "1.0.1" do
    type "All!" do
      change(TestChange5)
      change(TestChange4)
    end

    type "Bar" do
      change(TestChange3)
      change(TestChange2)
    end

    type "Foo" do
      change(TestChange1)
    end
  end

  version("1.0.0", do: [])
end

defmodule MySchemaLatest do
  use Versioning.Schema, adapter: Versioning.Adapter.Semantic

  @latest "1.0.0"

  version("1.0.1", do: [])

  version("1.0.0", do: [])
end

defmodule DateSchema do
  use Versioning.Schema, adapter: Versioning.Adapter.Date

  version("2019-01-07", do: [])

  version "2019-01-06" do
    type "All!" do
      change(TestChange15)
      change(TestChange14)
    end

    type "Foo" do
      change(TestChange13)
      change(TestChange12)
    end
  end

  version "2019-01-05" do
    type "All!" do
      change(TestChange11)
      change(TestChange10)
    end
  end

  version "2019-01-04" do
    type "Bar" do
      change(TestChange9)
      change(TestChange8)
    end
  end

  version "2019-01-03" do
    type "Foo" do
      change(TestChange7)
      change(TestChange6)
    end
  end

  version "2019-01-02" do
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

  version("2019-01-01", do: [])
end

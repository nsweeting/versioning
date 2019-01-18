defmodule Versioning.Adapter.DateTest do
  use ExUnit.Case

  alias Versioning.Adapter.Date, as: DateAdapter

  describe "parse/1" do
    test "will parse string dates" do
      assert {:ok, ~D[2019-01-01]} = DateAdapter.parse("2019-01-01")
    end

    test "will parse date dates" do
      assert {:ok, ~D[2019-01-01]} = DateAdapter.parse(~D[2019-01-01])
    end

    test "will return :error on bad values" do
      assert :error = DateAdapter.parse(1)
      assert :error = DateAdapter.parse("1")
      assert :error = DateAdapter.parse(:foo)
      assert :error = DateAdapter.parse(%{})
    end
  end

  describe "compare/2" do
    test "will return :eq if two versions are equal for strings" do
      assert :eq = DateAdapter.compare("2019-01-01", "2019-01-01")
    end

    test "will return :eq if two versions are equal for dates" do
      assert :eq = DateAdapter.compare(~D[2019-01-01], ~D[2019-01-01])
    end

    test "will return :gt if version1 is greater than version2 for strings" do
      assert :gt = DateAdapter.compare("2019-01-02", "2019-01-01")
    end

    test "will return :gt if version1 is greater than version2 for dates" do
      assert :gt = DateAdapter.compare(~D[2019-01-02], ~D[2019-01-01])
    end

    test "will return :lt if version1 is less than than version2 for strings" do
      assert :lt = DateAdapter.compare("2019-01-01", "2019-01-02")
    end

    test "will return :lt if version1 is less than than version2 for dates" do
      assert :lt = DateAdapter.compare(~D[2019-01-01], ~D[2019-01-02])
    end

    test "will return :error if version1 is a bad value" do
      assert :error = DateAdapter.compare(1, "2019-01-02")
    end

    test "will return :error if version2 is a bad value" do
      assert :error = DateAdapter.compare("2019-01-01", 1)
    end
  end
end

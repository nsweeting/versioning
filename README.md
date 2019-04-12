# Versioning

[![Build Status](https://travis-ci.org/nsweeting/versioning.svg?branch=master)](https://travis-ci.org/nsweeting/versioning)
[![Versioning Version](https://img.shields.io/hexpm/v/versioning.svg)](https://hex.pm/packages/versioning)

Versioning provides a way for API's to remain backward compatible without the headache.

This is done through use of a "versioning schema" that translates data through a series
of steps from its current version to the target version. This technique is well
described in the  article [APIs as infrastructure: future-proofing Stripe with versioning](https://stripe.com/blog/api-versioning).

The basic rule is each API version in the schema must only ever concern itself with
creating a set of change modules associated with the version below/above it. This
contract ensures that we can continue to translate data to legacy versions without
enormous effort.

## Installation

The package can be installed by adding `versioning` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:versioning, "~> 0.2.1"}
  ]
end
```

## Documentation

See [HexDocs](https://hexdocs.pm/versioning) for additional documentation.

## Example

For a more in-depth example, please check out the [Getting Started](https://hexdocs.pm/versioning/getting-started.html) page.

We build a schema to describe updates to our API through versions, types, and changes.

```elixir
defmodule MyAPI.Versioning do
  use Versioning.Schema

  version("1.2.0", do: [])

  version "1.1.0" do
    type "Post" do
      change(MyAPI.Changes.PostStatusChange)
    end
  end

  version("1.0.0", do: [])
end
```

We build a change module to perform data modifications.

```elixir
defmodule MyAPI.Changes.PostStatusChange do
  use Versioning.Change

  @desc """
  The boolean field "active" was removed in favour of the enum "status".
  """

  def down(versioning, _opts) do
    case Versioning.pop_data(versioning, "status") do
      {"active", versioning} -> Versioning.put_data(versioning, "active", true)
      {_, versioning} -> Versioning.put_data(versioning, "active", false)
    end
  end

  def up(versioning, _opts) do
    case Versioning.pop_data(versioning, "active") do
      {true, versioning} -> Versioning.put_data(versioning, "status", "active")
      {false, versioning} -> Versioning.put_data(versioning, "status", "hidden")
      {_, versioning} -> versioning
    end
  end
end
```

We create versionings to run against our schema. Here, we want to change our
post data from version 1.2.0 to 1.0.0. We can then run our versioning against
the schema, which will return a modified versioning with our change modules run.

```elixir
versioning = Versioning.new(%Post{}, "1.2.0", "1.0.0")
MyAPI.Versioning.run(versioning)
```

## Phoenix Usage

Versioning provides extensive support for usage with Phoenix. Checkout the [Phoenix Usage](https://hexdocs.pm/versioning/phoenix-usage.html) page for more details.

# Versioning
[![Build Status](https://travis-ci.org/nsweeting/versioning.svg?branch=master)](https://travis-ci.org/nsweeting/versioning)
[![Versioning Version](https://img.shields.io/hexpm/v/versioning.svg)](https://hex.pm/packages/versioning)

Versioning provides a way for API's to remain backward compatible without the headache.

This is done through use of a "versioning schema" that translates data through a series
of steps to the target version. This technique is well described in the  article [APIs as infrastructure: future-proofing Stripe with versioning](https://stripe.com/blog/api-versioning).

The basic rule is each API version in the schema must only ever concern itself with creating a
set of change modules associated with the version ahead of it. This contract ensures
that we can continue to translate data to legacy versions without enormous effort.

## Installation

The package can be installed by adding `versioning` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:versioning, "~> 0.1.1"}
  ]
end
```

## Documentation

See [HexDocs](https://hexdocs.pm/versioning) for additional documentation.

## Getting Started

Lets say we have an `Article` struct that contains the boolean field `:active`. As time goes by, we recognize that there may be more kinds of statuses that our `Article`'s may have.

To keep up with the times, we add the enum field `:status`. One of the values could be `"active"` - among many others.

### Versioning Struct

A the heart of our versioning is the `Versioning` struct. A `Versioning` sruct contains the following fields: 

 - `:target` - The version that we want our data to be changed into.
 - `:type` - The type of data we are working with. If we are working with structs, this will typically be the struct name, eg: `Article`
 - `:data` - The underlying data that we want to change. For structs, like our `Article`, be aware that we typically have our data as a bare map since it is easier to transform.
 - `:changed` - A boolean representing whether a change operation has occured.
 - `:assigns` - A map of arbitrary data we can use to store additonal information in.

Let's create a versioning of an `Article` struct.

```elixir
# Fetch an article
arcticle = get_article(id)
versioning = Versioning.new("2019-01-01", article)
#Versioning<target: "2019-01-01", type: Article, changed: false>
```

We now have a versioning of our `Article`

### Versioning Change

Lets create of first "versioning change". This change module will accept a `Versioning` struct, and must return a `Versioning` struct.

```elixir
defmodule MyAPI.Versioning.ArticleStatus do
  use Versioning.Change

  @desc """
  The boolean field "active" was removed in favour of the enum "status".
  """
  def change(versioning) do
    {status, data} = Map.pop(versioning.data, :status)
    
    case status do
      "active" -> put_active(versioning, data, true)
      "archived" -> put_active(versioning, data, true)
      _ -> put_active(versioning, data, false)
    end
  end
  
  defp put_active(versioning, data, active) do
    %{versioning | data: Map.put(data, :active, active)}
  end
end
```

As you can see, our change module accepts the versioning, removes the new `:status` value, translates the status to our `:active` requirements, and updates the versioning data - returning a modified versioning.

We can also use the `@desc` module attribute to attach a description of the change. This will be used when generating
a changelog.

### Versioning Schema

With our first change module in place, its time to tie it all together with our "versioning schema". The schema provides a DSL to describe and route our versioning.

```elixir
defmodule MyAPI.Versioning do
  use Versioning.Schema

  version "2019-01-01" do
    change Article do
      MyAPI.Versioning.ArticleStatus
    end
    
    change User do
      [
        MyAPI.Versioning.UserChange1,
        MyAPI.Versioning.UserChange2
      ]
    end
  end
  
  version "2018-12-01" do
    change Article do
      [
        MyAPI.Versioning.OtherArticleChange,
        MyAPI.Versioning.SomeOtherArticleChange,
      ]
    end
    
    change Payment do
      [
        MyAPI.Versioning.PaymentChange1,
        MyAPI.Versioning.PaymentChange2,
        MyAPI.Versioning.PaymentChange3
      ]
    end
  end
end
```

The schema above shows we currently support 2 versions. Our latest version `"2019-01-01"` is where our new article change is held. The schema DSL describes a flow, whereby the "top" version represents the most recent, and each subsequent version is one step older.

### Running our Versioning

With our versioning in place, we can now translate our `Article` struct to the requirements of our users "pinned" API version.

```elixir
#For the sake of example, lets say the user is pinned at the older "2018-12-01" version.
version = get_api_version(user) 
article = get_article(id)
versioning = Versioning.new(version, article)

MyAPI.Versioning.run(versioning)
#Versioning<target: "2018-12-01", type: Article, changed: true>
```

Calling `run/1` on our schema with a versioning struct will execute our schema. It will "walk" through each version, running any changes held within it that match the change `:type` on our versioning struct.

Once a matching version is found, it will run the changes within, but will stop execution afterwards.

We can then access the underlying data through our `versioning.data`.

For the example above, this would mean our `Article` struct would have been run through the following change modules in the order:

1. `MyAPI.Versioning.ArticleStatus`
2. `MyAPI.Versioning.OtherArticleChange`
3. `MyAPI.Versioning.SomeOtherArticleChange`

### Versioning Changelog

A changelog of our schema is also generated. This changelog represents a list of maps in the format (shortend for brevity):

```elixir
[
  %{
    version: "2019-01-01",
    changes: [
      %{
        type: Article,
        descriptions: [
          "The boolean field `:active` was removed in favour of the enum `:status`."
        ]
      },
      %{
        type: User,
        descriptions: [
          "Some description 1.",
          "Some description 2.",
        ]
      }
    ]
  }
]
```

You can access the changelog through your schema:

```elixir
MyAPI.Versioning.changelog()
```

You can also access the changelog while providing options such as a formatter. Included with
`Versioning` is a basic markdown formatter.

```elixir
MyAPI.Versioning.changelog(formatter: Versioning.Changelog.Markdown)
```

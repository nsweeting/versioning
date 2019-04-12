# Getting Started

Lets say we have a `Post` struct that contains the boolean field `:active`. As time goes by, we recognize that there may be more kinds of statuses that our `Post`'s may have.

To keep up with the times, we replace our `:active` field with the enum field `:status`.
One of the values could be `"active"` - among many others.

We arent ready to release this feature into the the wild yet though. So, while we change the internal structure of our `Post` data, we must ensure we dont break the API contract we made with our users. Versioning to the rescue...

## Versioning Struct

A the heart of our versioning is the `Versioning` struct. A `Versioning` struct contains the following fields:

- `:current` - The current version that our data represents.
- `:target` - The version that we want our data to be changed into.
- `:type` - The type of data we are working with. If we are working with structs, this will typically be the struct name, eg: `Post`
- `:data` - The underlying data that we want to change. For structs, like our `Post`, be aware that we typically have our data as a bare map since it is easier to transform.
- `:changed` - A boolean representing whether a change operation has occured.
- `:assigns` - A map of arbitrary data we can use to store additonal information in.

Let's see a couple different ways we can create a versioning a `Post`.

```elixir
# The type is automatically inferred from the struct module.
Versioning.new(%Post{}, "2.0.0", "1.0.0")

# We can also explicely set the type.
Versioning.new(%{}, "2.0.0", "1.0.0", Post)

# We can also build up our versioning using helpers.
|> Versioning.new()
|> Versioning.put_data(post)
|> Versioning.put_type(Post)
|> Versioning.put_current("2.0.0")
|> Versioning.put_target("1.0.0")
```

We now have a versioning of our `Post`.

## Versioning Change

Lets create of first "versioning change". This is a module that adheres to the
`Versioning.Change` behaviour. From it, we must implement the callbacks `up/2`
and `down/2`.

```elixir
defmodule MyAPI.Changes.PostStatusChange do
  use Versioning.Change

  @desc """
  The boolean field "active" was removed in favour of the enum "status".
  """

  def down(versioning, _opts) do
    case Versioning.pop_data(versioning, :status) do
      {:active, versioning} -> Versioning.put_data(versioning, :active, true)
      {_, versioning} -> Versioning.put_data(versioning, :active, false)
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

Our `down/2` function accepts a versioning, removes the new `:status` value, and
translates it to the old `:active` requirements - returning a modified versioning.

Our `up/2` function accepts a versioning, removes the old `"active"` value, and
translates it to our new `"status"` requirements - returning a modified versioning.

We can also use the `@desc` module attribute to attach a description of the change.
This will be used when generating a changelog.

## Versioning Schema

With our first change module in place, its time to tie it all together with our
"versioning schema". The schema provides a DSL to describe and route our versioning.

```elixir
defmodule MyAPI.Versioning do
  use Versioning.Schema

  version("2.0.0", do: [])

  version "1.1.0" do
    type "Post" do
      change(MyAPI.Changes.PostStatusChange)
    end
  end
  
  version("1.0.0", do: [])
end
```

The schema above shows we currently support 3 versions. Our top version `"2.0.0"`
represents the current version. `"1.1.0"` is where our new article change is held.
The schema DSL describes a flow, whereby the "top" version represents the most recent,
and each subsequent version is one step older.

## Running our Versioning

With our versioning in place, we can now translate our `Post` struct to the requirements
of our users "pinned" API version.

```elixir
#For the sake of example, lets say the user is pinned at the older "1.0.0" version.
version = get_api_version(user)
post = get_post(id)
versioning = Versioning.new(post, "2.0.0", version)

MyAPI.Versioning.run(versioning)
#Versioning<current: "2.0.0", target: "1.0.0", type: Post, changed: true>
```

Calling `run/1` on our schema with a versioning struct will execute our schema
downwards/upwards depending on the order of our current and target versions. It
will "walk" through each version, running any changes held within it that match
the `:type` on our versioning struct. A schema is typically run "downwards" when
converting local data to external data. A schema is typically run "updwards" when
converting external data to local data.

Once a matching version is found, it will run the changes within, but will stop
execution afterwards.

We can then access the underlying data through our `versioning.data`.

## Versioning Changelog

A changelog of our schema can also be generated. This changelog represents a list
of maps in the format (shortend for brevity):

```elixir
[
  %{
    version: "2.0.0",
    changes: []
  },
  %{
    version: "1.1.0",
    changes: [
      %{
        type: Post,
        descriptions: [
          "The boolean field `:active` was removed in favour of the enum `:status`."
        ]
      }
    ]
  },
  %{
    version: "1.0.0",
    changes: []
  }
]
```

You can access the changelog while providing options such as a formatter.
Included with `Versioning` is a basic markdown formatter.

```elixir
Versioning.Changelog.build(MyAPI.Versioning, formatter: Versioning.Changelog.Markdown)
```

defmodule VersioningError do
  defexception [:message]
end

defmodule Versioning.MissingSchemaError do
  defexception message: """
               no schema has been applied to the conn.

               please use Versioning.Controller.put_schema/2 or Versioning.Plug to apply a schema.
               """
end

defmodule Versioning.MissingVersionError do
  defexception message: """
               no version has been applied to the conn.

               please use Versioning.Controller.put_version/2 or Versioning.Plug to apply a version.
               """
end

defmodule Versioning.CompileError do
  defexception [:message]
end

defmodule Versioning.ChangelogError do
  defexception [:message]
end

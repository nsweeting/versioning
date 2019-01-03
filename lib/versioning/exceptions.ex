defmodule Versioning.CompileError do
  defexception [:message]
end

defmodule Versioning.ExecutionError do
  defexception [:message]
end

defmodule Versioning.ChangelogError do
  defexception [:message]
end

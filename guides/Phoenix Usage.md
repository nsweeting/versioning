# Phoenix Usage

Versioning provides extensive support for its usage with `Phoenix`. The best way
to get started is by adding some helper functions to your controllers and views.

    defmodule YourAppWeb do
    # ...

      def controller do
        quote do
          use Phoenix.Controller, namespace: MyAppWeb

          # ...

          import Versioning.Controller

          # ...
        end
      end

      def view do
        quote do
          use Phoenix.View, root: "lib/your_app_web/templates", namespace: "web"

          # ...

          import Versioning.View

          # ...
        end
      end
    end

Followed by adding a plug to your endpoint. Typically, you'll want this plug to
be added after you have access to the "current user".

    defmodule YourAppWeb.Endpoint do
      use Phoenix.Endpoint, otp_app: :your_app

      # plug ...

      plug Versioning.Plug, schema: YourAppWeb.Versioning
      plug YourAppWeb.Router
    end

Beyond the above, you'll of course need to setup your versioning schema and changes.

But with the above, you should be good to go! Please consult the documentation
available at `Versioning.Controller` for help on how to version params. And please
see the documentation available at `Versioning.View` for help on how to version
responses.

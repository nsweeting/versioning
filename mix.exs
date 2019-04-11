defmodule Versioning.MixProject do
  use Mix.Project

  @version "0.2.1"

  def project do
    [
      app: :versioning,
      version: @version,
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "Versioning",
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp description do
    """
    Versioning provides a way for API's to remain backward compatible without the headache.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["Nicholas Sweeting"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/nsweeting/versioning"}
    ]
  end

  defp docs do
    [
      main: "Versioning",
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/versioning",
      main: "readme",
      extras: [
        "README.md",
        "guides/Getting Started.md"
      ],
      source_url: "https://github.com/nsweeting/versioning",
      source_url_pattern: "https://github.com/nsweeting/versioning/blob/master/%{path}#L%{line}",
      groups_for_modules: [
        Adapters: [
          Versioning.Adapter,
          Versioning.Adapter.Semantic,
          Versioning.Adapter.Date
        ],
        Changelogs: [
          Versioning.Changelog,
          Versioning.Changelog.Formatter,
          Versioning.Changelog.Markdown
        ]
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix, "~> 1.4", optional: true},
      {:poison, "~> 3.1", optional: true},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end

defmodule Mimzy.MixProject do
  use Mix.Project

  @source_url "https://github.com/bryanenders/mimzy"
  @version "2.1.0"

  def application,
    do: [
      extra_applications: [:logger]
    ]

  def project,
    do: [
      app: :mimzy,
      deps: deps(),
      description: "A finite-state machine library for Elixir",
      docs: docs(),
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      name: "Mimzy",
      package: package(),
      start_permanent: Mix.env() === :prod,
      test_paths: ["lib"],
      version: @version
    ]

  defp deps,
    do: [
      {:ex_doc, "~> 0.20", only: :docs}
    ]

  defp docs,
    do: [
      extras: ["CHANGELOG.md", "README.md"],
      main: "Mimzy",
      source_ref: "v#{@version}",
      source_url: @source_url
    ]

  defp elixirc_paths(:test),
    do: ["lib", "test"]

  defp elixirc_paths(_),
    do: ["lib"]

  defp package,
    do: [
      licenses: ["MPL-2.0"],
      links: %{"GitHub" => @source_url}
    ]
end

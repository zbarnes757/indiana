defmodule Indiana.Mixfile do
  use Mix.Project

  def project do
    [
      app: :indiana,
      version: "0.1.0",
      elixir: "~> 1.3",
      elixirc_paths: elixirc_paths(Mix.env),
      name: "indiana",
      description: description,
      package: package,
      source_url: "https://github.com/zbarnes757/indiana",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      applications: apps(Mix.env),
      mod: {Indiana, []}
    ]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp apps(_), do: apps
  defp apps do
    [
      :logger,
      :httpoison
    ]
  end

  defp deps do
    [
      {:bureaucrat, "~> 0.1.2"},
      {:ecto, "~> 1.1", optional: true},
      {:httpoison, "~> 0.9.0"},
      {:mix_test_watch, "~> 0.2", only: :dev},
      {:phoenix, "~> 1.1", optional: true},
      {:phoenix_ecto, "~> 2.0", only: :test},
      {:phoenix_html, "~> 2.3", only: :test},
    ]
  end

  defp description do
    """
    A metrics library to make connecting with New Relic easier.
    """
  end

  defp package do
    [
      maintainers: ["Zac Barnes"],
      links: %{
        "GitHub" => "http://github.com/zbarnes757/indiana",
        "Docs" => "http://hexdocs.pm/indiana/"
      }
    ]
  end
end

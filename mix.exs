defmodule Indiana.Mixfile do
  use Mix.Project

  def project do
    [
      app: :indiana,
      version: "0.1.2",
      elixir: "~> 1.2",
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
      :httpoison,
      :atmo
    ]
  end

  defp deps do
    [
      {:atmo, "~> 0.1.0"},
      {:bureaucrat, "~> 0.1.2"},
      {:ecto, "~> 2.0", optional: true},
      {:exvcr, "~> 0.7", only: :test},
      {:httpoison, "~> 0.9.0"},
      {:mix_test_watch, "~> 0.2", only: :dev},
      {:phoenix, "~> 1.1", optional: true},
      {:postgrex, ">= 0.0.0", only: [:test]},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp description do
    """
    A metrics library to make connecting with New Relic easier.
    """
  end

  defp package do
    [
      maintainers: ["Zac Barnes <zac.barnes89@gmail.com>"],
      files: ["lib", "mix.exs", "README.md", "LICENSE",],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "http://github.com/zbarnes757/indiana"
      }
    ]
  end
end

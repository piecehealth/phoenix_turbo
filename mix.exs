defmodule PhoenixTurbo.MixProject do
  use Mix.Project

  def project do
    [
      app: :phoenix_turbo,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      description: description(),
      name: "PhoenixTurbo",
      package: packages(),
      deps: deps(),
      source_url: "https://github.com/piecehealth/phoenix_turbo"
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:phoenix, "~> 1.5"},
      {:phoenix_html, ">= 2.0.0"},
      {:ex_doc, "~> 0.23", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    Use Turbo in your Phoenix app.
    """
  end

  defp packages do
    [
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Zhang Kang"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/piecehealth/phoenix_turbo"}
    ]
  end
end

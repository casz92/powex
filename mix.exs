defmodule Powex.MixProject do
  use Mix.Project

  def project do
    [
      app: :powex,
      version: "0.1.0",
      elixir: "~> 1.14",
      description: "Proof of Work implementation in Rust for Elixir",
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:rustler, "~> 0.34.0"},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      name: "powex",
      maintainers: ["Carlos Suarez"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/casz92/powex"
      }
    ]
  end
end

defmodule RendevousHash.MixProject do
  use Mix.Project

  def project do
    [
      app: :rendevous_hash,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      rustler_crates: rustler_crates()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:usage_rules, "~> 0.1", only: [:dev]},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:rustler, "~> 0.36.2"},
      {:murmur3, "~> 0.1.2"}
    ]
  end

  defp rustler_crates do
    [
      rendevous_hash: [
        path: "native/rendevous_hash",
        mode: if(Mix.env() == :prod, do: :release, else: :debug)
      ]
    ]
  end
end

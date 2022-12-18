defmodule Potatolink.MixProject do
  use Mix.Project

  def project do
    [
      app: :potatolink,
      version: "0.0.1",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Potatolink, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4"},
      {:postgrex, "~> 0.16.5"},
      {:plug_cowboy, "~> 2.0"},
      {:bcrypt_elixir, "~> 3.0"}
    ]
  end

  
  # Setting up test env
  defp aliases do
    [
      test: "test --no-start" #(2)
    ]
  end
end

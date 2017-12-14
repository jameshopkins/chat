defmodule Server.Mixfile do
  use Mix.Project

  def project do
    [
      app: :server,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :plug, :cowboy],
      mod: {Bootstrap, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "1.1.0"},
      {:plug, "1.4.3"},
      {:slime, "1.1.0"},
      {:socket, "~> 0.3"},
      {:poison, "~> 3.1"}
    ]
  end
end

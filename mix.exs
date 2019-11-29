defmodule CredoSonarqube.MixProject do
  use Mix.Project

  def project do
    [
      app: :credo_sonarqube,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.1"},
      {:optimus, "~> 0.1.9"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end

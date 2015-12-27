defmodule Sinclair.Mixfile do
  use Mix.Project

  def project do
    [app: :sinclair,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:oauth, github: "tim/erlang-oauth"},
      {:extwitter, "~> 0.5"}
    ]
  end
end

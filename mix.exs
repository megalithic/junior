defmodule Junior.MixProject do
  use Mix.Project

  def project do
    [
      app: :junior,
      version: "0.1.0",
      elixir: "~> 1.8",
      escript: [main_module: Junior.CLI],
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

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_cli, "~> 0.1.2"},
      {:pdf2htmlex, "~> 0.1"},
      {:floki, "~> 0.20.0"},
      {:html5ever, "~> 0.7.0"},
      {:progress_bar, "~> 2.0.0"},
    ]
  end
end

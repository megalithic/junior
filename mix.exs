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

  def application do
    [
      extra_applications: [:logger, :nimble_csv]
    ]
  end

  defp deps() do
    [
      {:ex_cli, "~> 0.1.2"},
      {:pdf2htmlex, "~> 0.1"},
      {:floki, "~> 0.20.0"},
      {:html5ever, "~> 0.7.0"},
      # {:meeseeks, "~> 0.13.1"},
      # {:meeseeks_html5ever, "~> 0.12.1"},
      # {:rustler, "~> 0.21.0", override: true},
      # {:modest_ex, "~> 1.0.4"},
      {:nodex, "~> 0.1.1"},
      {:progress_bar, "~> 2.0.0"},
      {:nimble_csv, "~> 0.3"}
    ]
  end
end

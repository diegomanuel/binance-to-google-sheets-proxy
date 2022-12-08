defmodule BtgsProxy.MixProject do
  @moduledoc false
  use Mix.Project

  def project do
    [
      app: :http_proxy,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {HttpProxy, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # https://hexdocs.pm/http_proxy/readme.html
      # https://github.com/KazuCocoa/http_proxy
      # {:http_proxy, "~> 1.6"}
      {:plug_cowboy, "~> 2.6"},
      {:hackney, "~> 1.18"},
      {:exjsx, "~> 4.0.0", runtime: false},
      {:earmark, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false},
      {:ex_parameterized, "~> 1.0", only: :test, runtime: false},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:stream_data, "~> 0.1", only: :test}
    ]
  end
end

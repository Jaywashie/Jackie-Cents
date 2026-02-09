defmodule Insurance.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      InsuranceWeb.Telemetry,
      # Start the Ecto repository
      Insurance.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Insurance.PubSub},
      # Start Finch
      {Finch, name: Insurance.Finch},
      # Start the Endpoint (http/https)
      InsuranceWeb.Endpoint
      # Start a worker by calling: Insurance.Worker.start_link(arg)
      # {Insurance.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Insurance.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    InsuranceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

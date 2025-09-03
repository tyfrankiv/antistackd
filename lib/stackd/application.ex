defmodule Stackd.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      StackdWeb.Telemetry,
      Stackd.Repo,
      {DNSCluster, query: Application.get_env(:stackd, :dns_cluster_query) || :ignore},
      {Oban,
       AshOban.config(
         Application.fetch_env!(:stackd, :ash_domains),
         Application.fetch_env!(:stackd, Oban)
       )},
      {Phoenix.PubSub, name: Stackd.PubSub},
      # Start a worker by calling: Stackd.Worker.start_link(arg)
      # {Stackd.Worker, arg},
      # Start to serve requests, typically the last entry
      StackdWeb.Endpoint,
      {AshAuthentication.Supervisor, [otp_app: :stackd]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Stackd.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    StackdWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

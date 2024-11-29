defmodule VideoStreamingPoc.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      VideoStreamingPocWeb.Telemetry,
      {DNSCluster,
       query: Application.get_env(:video_streaming_poc, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: VideoStreamingPoc.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: VideoStreamingPoc.Finch},
      # Start a worker by calling: VideoStreamingPoc.Worker.start_link(arg)
      # {VideoStreamingPoc.Worker, arg},
      # Start to serve requests, typically the last entry
      VideoStreamingPocWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: VideoStreamingPoc.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    VideoStreamingPocWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

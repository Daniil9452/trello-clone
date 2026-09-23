defmodule Doski.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        Doski.Repo,
        {Phoenix.PubSub, name: Doski.PubSub},
        DoskiWeb.Presence,
        DoskiWeb.Endpoint
      ] ++ ipv6_loopback()

    Supervisor.start_link(children, strategy: :one_for_one, name: Doski.Supervisor)
  end

  defp ipv6_loopback do
    if Application.get_env(:doski, :bind_ipv6_loopback) do
      [
        {Bandit,
         plug: DoskiWeb.Endpoint,
         scheme: :http,
         ip: {0, 0, 0, 0, 0, 0, 0, 1},
         port: 4000}
      ]
    else
      []
    end
  end

  @impl true
  def config_change(changed, _new, removed) do
    DoskiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

defmodule DoskiWeb.Presence do
  use Phoenix.Presence,
    otp_app: :doski,
    pubsub_server: Doski.PubSub
end

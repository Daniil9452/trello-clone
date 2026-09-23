defmodule DoskiWeb.ChannelCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Phoenix.ChannelTest
      import DoskiWeb.ChannelCase

      @endpoint DoskiWeb.Endpoint
    end
  end

  setup tags do
    Doski.DataCase.setup_sandbox(tags)
    :ok
  end
end

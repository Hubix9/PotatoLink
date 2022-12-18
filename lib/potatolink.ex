defmodule Potatolink do
  use Application

  @moduledoc """
  Documentation for `Potatolink`.
  """

  def start(_type, _args) do
    {:ok, _} = DbManager.init()

    children = [
      {Plug.Cowboy, scheme: :http, plug: Router, options: [port: 3000]},
      SessionGb,
      LinkGb
    ]

    opts = [strategy: :one_for_one, name: Potatolink.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

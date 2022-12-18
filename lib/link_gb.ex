defmodule LinkGb do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(_) do
    DbManager.garbage_collect_links()
    :timer.send_interval(:timer.seconds(12 * 3600), self(), {:gb_start})
    {:ok, %{}}
  end

  def handle_info({:gb_start}, state) do
    DbManager.garbage_collect_links()
    {:noreply, state}
  end
end

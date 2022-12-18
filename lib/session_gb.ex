defmodule SessionGb do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(_) do
    DbManager.garbage_collect_sessions()
    :timer.send_interval(:timer.seconds(600), self(), {:gb_start})
    {:ok, %{}}
  end

  def handle_info({:gb_start}, state) do
    DbManager.garbage_collect_sessions()
    {:noreply, state}
  end

end

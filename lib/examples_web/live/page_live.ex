defmodule ExamplesWeb.PageLive do
  use ExamplesWeb, :live_view
  alias Examples.Gauge

  @impl true
  def mount(_params, _session, socket) do
    generate_value()

    {:ok, assign(socket, gauge: Gauge.setup([]))}
  end

  @impl true
  def handle_info(:gen_val, socket) do
    g = Gauge.put(socket.assigns.gauge, Enum.random(1..100))
    generate_value()

    {:noreply, assign(socket, gauge: g)}
  end

  @impl true
  def render(assigns) do
    assigns = [gauge_graph: Gauge.render(assigns.gauge)]

    Phoenix.View.render(ExamplesWeb.PageView, "page_live.html", assigns)
  end

  # Private

  defp generate_value() do
    Process.send_after(self(), :gen_val, 1_000)
  end
end

defmodule ExamplesWeb.PageLive do
  use ExamplesWeb, :live_view
  alias Grafex.Gauge

  @impl true
  def mount(_params, _session, socket) do
    generate_value()

    config = [
      # gauge_value_colors: [
      #   {[0, 50], "gauge-value-warning"},
      #   {[50, 250], "gauge-value-normal"},
      #   {[250, 300], "gauge-value-critical"}
      # ],
      major_ticks_count: 7,
      thresholds: [{50, "treshold_low"}, {250, "treshold_high"}]
    ]

    {:ok, assign(socket, gauge: Gauge.setup(config))}
  end

  @impl true
  def handle_info(:gen_val, socket) do
    g = Gauge.put(socket.assigns.gauge, Enum.random(0..300))
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

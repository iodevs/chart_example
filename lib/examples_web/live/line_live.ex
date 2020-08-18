defmodule ExamplesWeb.LineLive do
  use ExamplesWeb, :live_view
  alias Chart.Gauge
  alias Chart.Line

  @impl true
  def mount(_params, _session, socket) do
    # generate_value()

    {:ok, assign(socket, line: Line.setup())}
  end

  @impl true
  def handle_info(:gen_val, socket) do
    g = Line.put(socket.assigns.line, Enum.random(0..300))
    generate_value()

    {:noreply, assign(socket, line: g)}
  end

  @impl true
  def render(assigns) do
    assigns = [graph: Line.render(assigns.line)]

    Phoenix.View.render(ExamplesWeb.PageView, "line_live.html", assigns)
  end

  # Private

  defp generate_value() do
    Process.send_after(self(), :gen_val, 1_000)
  end
end

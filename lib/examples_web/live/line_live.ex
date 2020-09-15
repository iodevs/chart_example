defmodule ExamplesWeb.LineLive do
  use ExamplesWeb, :live_view
  alias Chart.Line

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(Examples.PubSub, "line_chart")
    # generate_value()

    # data = [[{1, 2}, {1.5, 5}, {2.2, 3.4}, {3, 3}]]
    # data = [[{1, 2}, {2, 5}, {3, 3.4}, {8, 3}]]

    data = [
      [{1, 2}, {1.5, 5}, {2.2, 3.4}, {3, 3}],
      [{0.3, 0.2}, {3.5, 6.5}, {5, 3.4}, {8, 3}]
      # [{1.8, 2.4}, {7.2, 2.4}]
    ]

    {:ok, assign(socket, line: Line.setup() |> Line.put(data))}
  end

  @impl true
  def handle_info(:gen_val, socket) do
    g = Line.put(socket.assigns.line, Enum.random(0..300))
    # generate_value()

    {:noreply, assign(socket, line: g)}
  end

  def handle_info({:gen, num}, socket) do
    # PubSub.broadcast(Examples.PubSub, "line_chart", {:gen, 23})
    data = [[{num, Enum.random(0..10)}], [{num, Enum.random(-10..10)}]]
    g = Line.put(socket.assigns.line, data)

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

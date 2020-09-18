defmodule ExamplesWeb.LineLive do
  use ExamplesWeb, :live_view
  alias Chart.Line

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(Examples.PubSub, "line_chart")
    # generate_value()

    # data = [[{1, 2}, {1.5, 5}, {2.2, 3.4}, {3, 3}]]
    # data = [[{1, 2}, {2, 5}, {3, 3.4}, {8, 3}]]

    # data = [
    #   [{1, 2}, {1.5, 5}, {2.2, 3.4}, {3, 3}],
    #   [{0.3, 0.2}, {3.5, 6.5}, {5, 3.4}, {8, 3}]
    #   # [{1.8, 2.4}, {7.2, 2.4}]
    # ]

    {:ok, assign(socket, line: line_setup())}
  end

  @impl true
  def handle_info({:gen, x}, socket) do
    # PubSub.broadcast(Examples.PubSub, "line_chart", {:gen, 23})
    data = [[{x, Enum.random(0..10)}], [{x, Enum.random(-10..10)}]]
    g = Line.put(socket.assigns.line, data)

    {:noreply, assign(socket, line: g)}
  end

  @impl true
  def render(assigns) do
    assigns = [graph: Line.render(assigns.line)]

    Phoenix.View.render(ExamplesWeb.PageView, "line_live.html", assigns)
  end

  # Private

  defp line_setup() do
    Line.setup()
    |> Line.set_title_text("Graph")
    |> Line.set_title_position({400, 50})
    |> Line.set_grid(:x_major)
    |> Line.set_grid(:y_major)
    |> Line.set_axis_label(:x_axis, "Axis X")
    |> Line.set_axis_label(:y_axis, "Axis Y")
    |> Line.set_axis_major_ticks_count(:x_axis, 5)
    |> Line.set_axis_ticks_text_format(:x_axis, {:datetime, "%X"})
    # |> Line.set_axis_ticks_text_range_offset(:x_axis, {1, 1})
    # |> Line.set_axis_ticks_text_range_offset(:x_axis, :auto)
    |> Line.add_axis_minor_ticks(:x_axis)
    |> Line.add_axis_minor_ticks(:y_axis)
    |> Line.set_axis_minor_ticks_count(:y_axis, 3)
  end
end

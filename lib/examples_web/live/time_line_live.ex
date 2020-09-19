defmodule ExamplesWeb.TimeLineLive do
  use ExamplesWeb, :live_view
  alias Chart.TimeLine

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(Examples.PubSub, "timeline_chart")

    {:ok, assign(socket, timeline: timeline_setup())}
  end

  @impl true
  def handle_info({:gen, x}, socket) do
    data = [[{x, Enum.random(0..10)}], [{x, Enum.random(-10..10)}]]
    g = TimeLine.put(socket.assigns.timeline, data)

    {:noreply, assign(socket, timeline: g)}
  end

  @impl true
  def render(assigns) do
    assigns = [graph: TimeLine.render(assigns.timeline)]

    Phoenix.View.render(ExamplesWeb.PageView, "time_line_live.html", assigns)
  end

  # Private

  defp timeline_setup() do
    TimeLine.setup()
    |> TimeLine.set_title_text("Time Series")
    |> TimeLine.set_title_position({400, 50})
    |> TimeLine.set_grid(:x_major)
    |> TimeLine.set_grid(:y_major)
    |> TimeLine.set_axis_label(:x_axis, "Axis X")
    |> TimeLine.set_axis_label(:y_axis, "Axis Y")
    |> TimeLine.set_axis_major_ticks_count(:x_axis, 5)
    |> TimeLine.set_axis_ticks_text_format(:x_axis, {:datetime, "%X"})
    # |> TimeLine.set_axis_ticks_text_range_offset(:x_axis, {1, 1})
    # |> TimeLine.set_axis_ticks_text_range_offset(:x_axis, :auto)
    |> TimeLine.add_axis_minor_ticks(:y_axis)
    |> TimeLine.set_axis_minor_ticks_count(:y_axis, 3)
    |> TimeLine.set_count_data(20)
  end
end

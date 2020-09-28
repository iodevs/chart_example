defmodule ExamplesWeb.DasboardChartLive do
  use ExamplesWeb, :live_view

  alias Chart.Bar
  alias Chart.Line
  alias Chart.TimeLine
  alias Chart.Gauge

  @gen_time_bar 800
  @gen_time_line 1_000
  @gen_time_timeline 1000
  @gen_time_gauge_a 400
  @gen_time_gauge_b 500

  @impl true
  def mount(_params, _session, socket) do
    generate_bar_values()
    generate_line_values()
    generate_timeline_values()
    generate_gauge_a_values()
    generate_gauge_b_values()

    socket =
      socket
      |> assign(bar: bar_setup())
      |> assign(line: line_setup())
      |> assign(timeline: timeline_setup())
      |> assign(gauge_a: gauge_setup())
      |> assign(gauge_b: gauge_setup())

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    assigns = [
      bar: Bar.render(assigns.bar),
      line: Line.render(assigns.line),
      timeline: TimeLine.render(assigns.timeline),
      gauge_a: Gauge.render(assigns.gauge_a),
      gauge_b: Gauge.render(assigns.gauge_b)
    ]

    Phoenix.View.render(ExamplesWeb.PageView, "dashboard_chart_live.html", assigns)
  end

  @impl true
  def handle_info(:gen_bar_values, socket) do
    generate_bar_values(@gen_time_bar)

    data = %{
      city_1: Enum.random(0..10),
      city_2: Enum.random(4..12),
      city_3: Enum.random(0..15),
      city_4: Enum.random(1..5),
      city_5: Enum.random(0..10),
      city_6: Enum.random(4..12),
      city_7: Enum.random(0..15),
      city_8: Enum.random(1..5),
      city_9: Enum.random(0..15),
      city_10: Enum.random(1..5)
    }

    g = Bar.put(socket.assigns.bar, data)

    {:noreply, assign(socket, bar: g)}
  end

  @impl true
  def handle_info({:gen_line_values, val}, socket) do
    generate_line_values(val, @gen_time_line)

    data = [[{val, Enum.random(0..10)}], [{val, Enum.random(-10..10)}]]
    g = Line.put(socket.assigns.line, data)

    {:noreply, assign(socket, line: g)}
  end

  @impl true
  def handle_info({:gen_timeline_values, dt}, socket) do
    generate_timeline_values(@gen_time_timeline)

    data = [
      [{dt, Enum.random(0..10)}],
      [{dt, Enum.random(-10..10)}],
      [{dt, Enum.random(-1..7)}]
    ]

    g = TimeLine.put(socket.assigns.timeline, data)

    {:noreply, assign(socket, timeline: g)}
  end

  @impl true
  def handle_info(:gen_gauge_a_values, socket) do
    generate_gauge_a_values(@gen_time_gauge_a)

    g = Gauge.put(socket.assigns.gauge_a, Enum.random(0..300))

    {:noreply, assign(socket, gauge_a: g)}
  end

  @impl true
  def handle_info(:gen_gauge_b_values, socket) do
    generate_gauge_b_values(@gen_time_gauge_b)

    g = Gauge.put(socket.assigns.gauge_b, Enum.random(0..300))

    {:noreply, assign(socket, gauge_b: g)}
  end

  # Private

  defp bar_setup() do
    Bar.setup()
    |> Bar.set_title_text("Bar chart")
    |> Bar.set_title_position({400, 50})
    |> Bar.set_grid(:y_major)
    |> Bar.set_axis_label(:y_axis, "Axis Y")
    |> Bar.set_axis_range({0, 9})
    |> Bar.set_axis_range_limit(:fixed)

    # |> Bar.set_width(50)
    # |> Bar.set_axis_ticks_labels(["Foo 1", "Foo 2", "Foo 3", "Bar 4", "Bar 5"])
  end

  defp line_setup() do
    Line.setup()
    |> Line.set_title_text("Line chart")
    |> Line.set_title_position({400, 50})
    |> Line.set_grid(:x_major)
    |> Line.set_grid(:y_major)
    |> Line.set_axis_label(:x_axis, "Axis X")
    |> Line.set_axis_label(:y_axis, "Axis Y")
    |> Line.set_axis_major_ticks_count(:x_axis, 5)
    # |> Line.set_axis_ticks_text_format(:x_axis, {:datetime, "%X"})
    # |> Line.set_axis_ticks_text_range_offset(:x_axis, {1, 1})
    # |> Line.set_axis_ticks_text_range_offset(:x_axis, :auto)
    |> Line.add_axis_minor_ticks(:x_axis)
    |> Line.add_axis_minor_ticks(:y_axis)
    |> Line.set_axis_minor_ticks_count(:y_axis, 3)
  end

  defp timeline_setup() do
    TimeLine.setup()
    |> TimeLine.set_viewbox({1400, 600})
    |> TimeLine.set_plot_size({1200, 400})
    |> TimeLine.set_title_text("Time Series")
    |> TimeLine.set_title_position({700, 50})
    |> TimeLine.set_grid(:x_major)
    |> TimeLine.set_grid(:y_major)
    |> TimeLine.set_axis_label(:x_axis, "Axis X")
    |> TimeLine.set_axis_label(:y_axis, "Axis Y")
    |> TimeLine.set_axis_major_ticks_count(:x_axis, 8)
    |> TimeLine.set_axis_ticks_text_format(:x_axis, {:datetime, "%X"})
    |> TimeLine.set_axis_major_ticks_count(:y_axis, 5)
    # |> TimeLine.set_axis_ticks_text_range_offset(:x_axis, {1, 1})
    # |> TimeLine.set_axis_ticks_text_range_offset(:x_axis, :auto)
    |> TimeLine.add_axis_minor_ticks(:y_axis)
    |> TimeLine.set_axis_minor_ticks_count(:y_axis, 3)
    |> TimeLine.set_count_data(20)
  end

  defp gauge_setup() do
    [
      # gauge_value_class: [
      #   {[0, 50], "gauge-value-warning"},
      #   {[50, 250], "gauge-value-normal"},
      #   {[250, 300], "gauge-value-critical"}
      # ],
      major_ticks_count: 7,
      thresholds: [{50, "treshold_low"}, {250, "treshold_high"}]
    ]
    |> Gauge.setup()
  end

  defp generate_bar_values(time \\ 1000) do
    Process.send_after(self(), :gen_bar_values, time)
  end

  defp generate_line_values(init_val \\ -1, time \\ 1000) do
    Process.send_after(self(), {:gen_line_values, init_val + 1}, time)
  end

  defp generate_timeline_values(time \\ 1000) do
    dt = DateTime.utc_now() |> DateTime.to_unix()

    Process.send_after(self(), {:gen_timeline_values, dt}, time)
  end

  defp generate_gauge_a_values(time \\ 1000) do
    Process.send_after(self(), :gen_gauge_a_values, time)
  end

  defp generate_gauge_b_values(time \\ 1000) do
    Process.send_after(self(), :gen_gauge_b_values, time)
  end
end

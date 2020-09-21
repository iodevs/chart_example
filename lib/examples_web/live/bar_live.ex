defmodule ExamplesWeb.BarLive do
  use ExamplesWeb, :live_view
  alias Chart.Bar

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(Examples.PubSub, "line_chart")
    # generate_value()

    data = %{
      city_1: 3,
      city_2: 2,
      city_3: 5,
      city_4: 6
    }

    new_data = %{city_1: 10}

    {:ok, assign(socket, bar: bar_setup() |> Bar.put(data, new_data))}
  end

  @impl true
  def handle_info({:gen, _x}, socket) do
    # PubSub.broadcast(Examples.PubSub, "line_chart", {:gen, 23})
    data =
      %{
        city_1: Enum.random(0..10),
        city_2: Enum.random(4..12),
        city_3: Enum.random(0..15),
        city_4: Enum.random(1..5)
      }
      |> IO.inspect()

    g = Bar.put(socket.assigns.bar, data)

    {:noreply, assign(socket, bar: g)}
  end

  @impl true
  def render(assigns) do
    assigns = [graph: Bar.render(assigns.bar)]

    Phoenix.View.render(ExamplesWeb.PageView, "bar_live.html", assigns)
  end

  # Private

  defp bar_setup() do
    Bar.setup()
    |> Bar.set_title_text("Bar graph")
    |> Bar.set_title_position({400, 50})
    |> Bar.set_grid(:y_major)
    |> Bar.set_axis_label(:x_axis, "Axis X")
    |> Bar.set_axis_label(:y_axis, "Axis Y")
    |> Bar.set_axis_major_ticks_count(:x_axis, 5)
  end
end

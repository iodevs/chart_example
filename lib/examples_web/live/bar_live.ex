defmodule ExamplesWeb.BarLive do
  use ExamplesWeb, :live_view
  alias Chart.Bar

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(Examples.PubSub, "line_chart")

    {:ok, assign(socket, bar: bar_setup())}
  end

  @impl true
  def handle_info({:gen, _x}, socket) do
    # Examples.Tmp.gen_numbers(1000, 100)

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
  def render(assigns) do
    assigns = [graph: Bar.render(assigns.bar)]

    Phoenix.View.render(ExamplesWeb.PageView, "bar_live.html", assigns)
  end

  # Private

  defp bar_setup() do
    Bar.setup()
    |> Bar.set_title_text("Bar chart")
    |> Bar.set_title_position({400, 50})
    |> Bar.set_grid(:y_major)
    |> Bar.set_axis_label(:y_axis, "Axis Y")

    # |> Bar.set_width(50)
    # |> Bar.set_axis_ticks_labels(["Foo 1", "Foo 2", "Foo 3", "Bar 4", "Bar 5"])
  end
end

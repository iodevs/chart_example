defmodule Examples.Gauge.Utils do
  @moduledoc false

  alias Examples.Gauge.Settings
  require Integer

  @from_left 20

  def value_to_angle(val, a, b) do
    :math.pi() - (val - a) * :math.pi() / :erlang.abs(b - a)
  end

  def linspace([min, max], step), do: linspace(min, max, step)

  def linspace(min, max, step) do
    delta = :erlang.abs(max - min) / (step - 1)

    Enum.reduce(1..(step - 1), [min], fn x, acc ->
      acc ++ [x * delta]
    end)
  end

  #  OLD CODE

  def vb_width() do
    Map.get(%Settings{}, :vb_width)
  end

  def vb_height() do
    Map.get(%Settings{}, :vb_height)
  end

  def get_gauge() do
    # Map.get(%Settings{}, :gauge)
    %Settings{}.gauge
  end

  def major_ticks() do
    %Settings{}.major_ticks
  end

  def get_value() do
    Map.get(%Settings{}, :value)
  end

  def bg_arc() do
    [cx, from_bottom] = center_half_circles()

    # radius of outer circle
    # rx_o = radius_bg_outer()
    # ry_o = rx_o
    rx_o = 50
    ry_o = 50

    # radius of inner circle
    # rx_i = radius_bg_inner()
    # ry_i = rx_i
    rx_i = radius_bg_inner()
    ry_i = rx_i

    "M#{cx - rx_o}, #{from_bottom} A#{rx_o}, #{ry_o} 0 0,1 #{cx + rx_o}, #{from_bottom} L#{
      cx + rx_i
    }, #{from_bottom} A#{rx_i}, #{ry_i} 0 0,0 #{cx - rx_i}, #{from_bottom} Z"
  end

  def value_arc(val) do
    [cx, from_bottom] = center_half_circles()
    gbw = %Settings{}.gauge.border_width
    [_, max] = %Settings{}.range

    phi = val_to_angle(val)

    # radius of outer circle
    rx_o = radius_value_outer()
    ry_o = rx_o

    # radius of inner circle
    rx_i = radius_value_inner()
    ry_i = rx_i

    # ends of radius value
    end_rx_o = :math.cos(phi) * rx_o
    end_ry_o = if(val < max, do: from_bottom - :math.sin(phi) * ry_o, else: from_bottom - gbw / 2)

    end_rx_i = :math.cos(phi) * rx_i
    end_ry_i = if(val < max, do: from_bottom - :math.sin(phi) * ry_i, else: from_bottom - gbw / 2)

    "M#{cx - rx_o}, #{from_bottom - gbw / 2} A#{rx_o}, #{ry_o} 0 0,1 #{cx + end_rx_o}, #{end_ry_o} L#{
      cx + end_rx_i
    }, #{end_ry_i} A#{rx_i}, #{ry_i} 0 0,0 #{cx - rx_i}, #{from_bottom - gbw / 2} Z"
  end

  def tick_text() do
    tick_values = linspace(%Settings{}.range, major_ticks().count)

    count = %Settings{}.major_ticks.count
    is_odd_count = Integer.is_odd(count)

    # https://svgwg.org/svg-next/text.html#TextPathAttributes
    # <text text-anchor="start" x="60" y="40">A</text>
    # <text text-anchor="middle" x="60" y="75">A</text>
    # <text text-anchor="end" x="60" y="110">A</text>
  end

  def center_half_circles() do
    [vb_width() / 2, vb_height() / 2 + @from_bottom]
  end

  # Private

  defp radius_value_outer() do
    [a, b] = %Settings{}.range

    :erlang.abs(transform(b) - transform(a)) / 2
  end

  defp radius_value_inner() do
    radius_value_outer() - %Settings{}.value.annulus_width
  end

  defp radius_bg_outer() do
    radius_value_outer() + (%Settings{}.gauge.annulus_width - %Settings{}.value.annulus_width) / 2
  end

  defp radius_bg_inner() do
    radius_bg_outer() - %Settings{}.gauge.annulus_width
  end

  defp scale() do
    [a, b] = %Settings{}.range

    radius_orig = :erlang.abs(b - a)
    radius_at_svg = :erlang.abs(vb_width() - 2 * @from_left)

    radius_at_svg / radius_orig
  end

  defp transform(x) when is_number(x) do
    [a, b] = %Settings{}.range

    scale() * x + :erlang.abs(@from_left - scale() * a)
  end

  defp val_to_angle(val) do
    [a, b] = %Settings{}.range

    :math.pi() - (val - a) * :math.pi() / :erlang.abs(b - a)
  end
end

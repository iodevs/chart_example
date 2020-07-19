defmodule Examples.Gauge.Settings do
  @moduledoc false

  alias Examples.Gauge.Utils

  @from_bottom 30

  defmodule MajorTicks do
    @moduledoc false

    @type t() :: %__MODULE__{
            count: pos_integer(),
            length: number(),
            gap: number(),
            translate: String.t(),
            positions: list()
          }

    defstruct count: 7,
              length: 4,
              gap: 0,
              translate: "",
              positions: []
  end

  @type t() :: %__MODULE__{
          viewbox: nil | {pos_integer(), pos_integer()},
          range: nil | {number(), number()},
          gauge_radius: {number(), number()},
          gauge_center: {number(), number()},
          d_gauge_half_circle: String.t(),
          d_value: String.t(),
          major_ticks: nil | MajorTicks.t()
          # text_ticks: nil | String.t(),
          # text_value: nil | String.t()
        }

  defstruct viewbox: nil,
            range: nil,
            gauge_radius: {50, 50},
            gauge_center: {0, 0},
            d_gauge_half_circle: "",
            d_value: "",
            major_ticks: nil

  # text_ticks: nil,
  # text_value: nil

  @spec set(list()) :: t()
  def set(config) do
    %__MODULE__{
      viewbox: key_guard(config, :viewbox, {160, 80}, &set_viewbox/1),
      range: key_guard(config, :range, {0, 300}, &set_range/1),
      major_ticks:
        key_guard(
          config,
          :major_ticks_count,
          Map.put(%MajorTicks{}, :count, 7),
          &set_major_ticks_count/1
        ),
      major_ticks:
        key_guard(
          config,
          :major_ticks_length,
          Map.put(%MajorTicks{}, :length, 4),
          &set_major_ticks_length/1
        ),
      major_ticks:
        key_guard(
          config,
          :major_ticks_gap,
          Map.put(%MajorTicks{}, :gap, 0),
          &set_major_ticks_gap/1
        )
    }
    |> put_gauge_center_circle()
    |> put_gauge_half_circle()
    |> put_major_ticks_translate()
    |> put_major_ticks_positions()
  end

  # Private

  defp key_guard(kw, key, default_val, fun) do
    fun.(Keyword.get(kw, key, default_val))
  end

  defp set_viewbox({width, height} = viewbox)
       when 0 < width and 0 < height and is_number(width) and is_number(height) do
    viewbox
  end

  defp set_range({min, max} = range) when min < max and is_number(min) and is_number(max) do
    range
  end

  defp set_major_ticks_count(%MajorTicks{count: c} = major_ticks) when 1 < c and is_integer(c) do
    major_ticks
  end

  defp set_major_ticks_length(%MajorTicks{length: l} = major_ticks) when 0 < l and is_number(l) do
    major_ticks
  end

  defp set_major_ticks_gap(%MajorTicks{gap: g} = major_ticks) when is_number(g) do
    major_ticks
  end

  defp put_gauge_center_circle(%__MODULE__{viewbox: {w, h}} = settings) do
    %{
      settings
      | gauge_center: {w / 2, h / 2 + @from_bottom}
    }
  end

  defp put_gauge_half_circle(
         %__MODULE__{gauge_center: {cx, cy}, gauge_radius: {rx, ry}} = settings
       ) do
    %{
      settings
      | d_gauge_half_circle: "M#{cx - rx}, #{cy} A#{rx}, #{ry} 0 0,1 #{cx + rx}, #{cy}"
    }
  end

  defp put_major_ticks_translate(settings) do
    {_cx, cy} = settings.gauge_center

    Kernel.put_in(
      settings.major_ticks.translate,
      "translate(#{16.5 - settings.major_ticks.gap}, #{cy})"
    )
  end

  defp put_major_ticks_positions(settings) do
    angles = Utils.linspace(0, 180, settings.major_ticks.count)

    Kernel.put_in(settings.major_ticks.positions, angles)
  end
end

defmodule Examples.Gauge.Settings do
  @moduledoc false

  alias Examples.Gauge.Utils

  @offset_from_bottom 35
  @offset_radius_major_ticks_text 15

  defmodule MajorTicks do
    @moduledoc false

    @type t() :: %__MODULE__{
            count: pos_integer(),
            length: number(),
            gap: number(),

            # Internal
            translate: String.t(),
            positions: list()
          }

    defstruct count: 7,
              length: 4,
              gap: 0,
              translate: "",
              positions: []
  end

  defmodule MajorTicksText do
    @moduledoc false

    @type t() :: %__MODULE__{
            gap: number(),
            decimals: non_neg_integer(),

            # Internal
            positions: list()
          }

    defstruct gap: 0,
              decimals: 0,
              positions: []
  end

  @type t() :: %__MODULE__{
          viewbox: nil | {pos_integer(), pos_integer()},
          range: nil | {number(), number()},
          text_value_position: nil | {number(), number()},
          text_value_decimals: nil | non_neg_integer(),
          major_ticks: nil | MajorTicks.t(),
          major_ticks_text: nil | MajorTicksText.t(),

          # Internal
          gauge_radius: {number(), number()},
          gauge_center: {number(), number()},
          d_gauge_half_circle: String.t(),
          d_value: String.t(),
          text_value: String.t()
        }

  defstruct viewbox: nil,
            range: nil,
            text_value_position: nil,
            text_value_decimals: nil,
            major_ticks: nil,
            major_ticks_text: nil,

            # Internal
            gauge_radius: {50, 50},
            gauge_center: {0, 0},
            d_gauge_half_circle: "",
            d_value: "",
            text_value: ""

  @spec set(list()) :: t()
  def set(config) do
    %__MODULE__{
      viewbox: key_guard(config, :viewbox, {160, 80}, &set_viewbox/1),
      range: key_guard(config, :range, {0, 300}, &set_range/1),
      text_value_position:
        key_guard(config, :text_value_position, {0, -5}, &set_text_value_position/1),
      text_value_decimals: key_guard(config, :text_value_decimals, 0, &set_text_value_decimals/1),
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
        ),
      major_ticks_text:
        key_guard(
          config,
          :major_ticks_text_gap,
          Map.put(%MajorTicksText{}, :gap, 0),
          &set_major_ticks_text_gap/1
        ),
      major_ticks_text:
        key_guard(
          config,
          :major_ticks_value_decimals,
          Map.put(%MajorTicksText{}, :decimals, 0),
          &set_major_ticks_text_decimals/1
        )
    }
    |> put_gauge_center_circle()
    |> put_gauge_half_circle()
    |> put_text_value_position()
    |> put_major_ticks_translate()
    |> put_major_ticks_positions()
    |> put_major_ticks_text_positions()
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

  defp set_text_value_position({x, y} = position) when is_number(x) and is_number(y) do
    position
  end

  defp set_text_value_decimals(decimals) when 0 <= decimals and is_integer(decimals) do
    decimals
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

  defp set_major_ticks_text_gap(%MajorTicksText{gap: g} = major_ticks_text) when is_number(g) do
    major_ticks_text
  end

  defp set_major_ticks_text_decimals(%MajorTicksText{decimals: d} = major_ticks_value)
       when 0 <= d and is_integer(d) do
    major_ticks_value
  end

  defp put_gauge_center_circle(%__MODULE__{viewbox: {w, h}} = settings) do
    %{
      settings
      | gauge_center: {w / 2, h / 2 + @offset_from_bottom}
    }
  end

  defp put_text_value_position(
         %__MODULE__{gauge_center: {cx, cy}, text_value_position: {x, y}} = settings
       ) do
    Kernel.put_in(settings.text_value_position, {cx + x, cy + y})
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

  defp put_major_ticks_text_positions(settings) do
    count = settings.major_ticks.count

    ticks_text_pos =
      settings.range
      |> Utils.linspace(count)
      |> Utils.split_major_tick_values(count)
      |> parse_tick_values(settings)

    Kernel.put_in(settings.major_ticks_text.positions, ticks_text_pos)
  end

  defp parse_tick_values([left, center, right], settings)
       when is_list(left) and is_list(center) and is_list(right) do
    l = left |> compute_positions_with_text_anchor(settings, "end")
    c = center |> compute_positions_with_text_anchor(settings, "middle")
    r = right |> compute_positions_with_text_anchor(settings, "start")

    [l, c, r] |> List.flatten()
  end

  defp parse_tick_values([left, right], settings) when is_list(left) and is_list(right) do
    l = left |> compute_positions_with_text_anchor(settings, "end")
    r = right |> compute_positions_with_text_anchor(settings, "start")

    [l, r] |> List.flatten()
  end

  defp compute_positions_with_text_anchor(val_list, settings, text_anchor) do
    {cx, cy} = settings.gauge_center
    {rx, _ry} = settings.gauge_radius

    radius = rx + @offset_radius_major_ticks_text + settings.major_ticks_text.gap

    val_list
    |> Enum.map(fn tick_val ->
      phi = Utils.value_to_angle(tick_val, settings.range)
      {x, y} = Utils.polar_to_cartesian(radius, phi)

      {cx + x, cy - y,
       :erlang.float_to_list(1.0 * tick_val, decimals: settings.major_ticks_text.decimals),
       text_anchor}
    end)
  end
end

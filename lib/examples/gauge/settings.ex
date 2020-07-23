defmodule Examples.Gauge.Settings do
  @moduledoc false

  alias Examples.Gauge.Utils

  @offset_from_bottom 35
  @offset_radius_major_ticks_text 15

  defmodule MajorTicks do
    @moduledoc false

    @type t() :: %__MODULE__{
            count: pos_integer(),
            gap: number(),
            length: number(),

            # Internal
            positions: list(),
            translate: String.t()
          }

    defstruct count: 0,
              gap: 0,
              length: 0,
              positions: [],
              translate: ""
  end

  defmodule MajorTicksText do
    @moduledoc false

    @type t() :: %__MODULE__{
            decimals: nil | non_neg_integer(),
            gap: nil | number(),

            # Internal
            positions: nil | list()
          }

    defstruct decimals: nil,
              gap: nil,
              positions: nil
  end

  defmodule ValueText do
    @moduledoc false

    @type t() :: %__MODULE__{
            decimals: nil | non_neg_integer(),
            position: nil | {number(), number()}
          }

    defstruct decimals: nil,
              position: nil
  end

  defmodule Thresholds do
    @moduledoc false

    @type t() :: %__MODULE__{
            positions_with_class_name: nil | list(tuple()),
            width: nil | non_neg_integer(),

            # Internal
            d_thresholds_with_class: list(tuple())
          }

    defstruct positions_with_class_name: nil,
              width: nil,
              d_thresholds_with_class: [{"", "", ""}]
  end

  @type t() :: %__MODULE__{
          gauge_bottom_width_lines: nil | number(),
          gauge_value_colors: nil | list(tuple()),
          major_ticks: nil | MajorTicks.t(),
          major_ticks_text: nil | MajorTicksText.t(),
          range: nil | {number(), number()},
          thresholds: nil | Thresholds.t(),
          value_text: nil | ValueText.t(),
          viewbox: nil | {pos_integer(), pos_integer()},

          # Internal
          d_gauge_bg_border_bottom_lines: list(String.t()),
          d_gauge_half_circle: String.t(),
          d_value: String.t(),
          gauge_center: {number(), number()},
          gauge_radius: {number(), number()},
          gauge_value_class: String.t(),
          text_value: String.t()
        }

  defstruct gauge_bottom_width_lines: nil,
            gauge_value_colors: nil,
            major_ticks: nil,
            major_ticks_text: nil,
            range: nil,
            thresholds: nil,
            value_text: nil,
            viewbox: nil,

            # Internal
            d_gauge_bg_border_bottom_lines: ["", ""],
            d_gauge_half_circle: "",
            d_value: "",
            gauge_center: {0, 0},
            gauge_radius: {50, 50},
            gauge_value_class: "",
            text_value: ""

  @spec set(list()) :: t()
  def set(config) do
    %__MODULE__{
      gauge_bottom_width_lines:
        key_guard(config, :gauge_bottom_width_lines, 1.25, &validate_number/1),
      gauge_value_colors: key_guard(config, :gauge_value_colors, [], &validate_list_of_tuples/1),
      range: key_guard(config, :range, {0, 300}, &validate_range/1),
      viewbox: key_guard(config, :viewbox, {160, 80}, &validate_viewbox/1)
    }
    |> set_gauge_center_circle()
    |> set_gauge_half_circle()
    |> set_gauge_bg_border_bottom_lines()
    |> put_major_ticks(
      count: key_guard(config, :major_ticks_count, 7, &validate_major_ticks_count/1),
      gap: key_guard(config, :major_ticks_gap, 0, &validate_number/1),
      length: key_guard(config, :major_ticks_length, 7, &validate_positive_number/1)
    )
    |> put_major_ticks_text(
      decimals: key_guard(config, :major_ticks_value_decimals, 0, &validate_decimals/1),
      gap: key_guard(config, :major_ticks_text_gap, 0, &validate_number/1)
    )
    |> put_value_text(
      decimals: key_guard(config, :value_text_decimals, 0, &validate_decimals/1),
      position: key_guard(config, :value_text_position, {0, -10}, &validate_value_text_position/1)
    )
    |> put_thresholds(
      positions_with_class_name: key_guard(config, :thresholds, [], &validate_list_of_tuples/1),
      width: key_guard(config, :treshold_width, 1, &validate_positive_number/1)
    )
  end

  # Private

  defp put_major_ticks(%__MODULE__{} = settings, keywords) do
    major_ticks =
      keywords
      |> set_map(%MajorTicks{})
      |> set_major_ticks_translate(settings.gauge_center)
      |> set_major_ticks_positions()

    Kernel.put_in(settings.major_ticks, major_ticks)
  end

  defp put_major_ticks_text(%__MODULE__{} = settings, keywords) do
    major_ticks_text =
      keywords
      |> set_map(%MajorTicksText{})
      |> set_major_ticks_text_positions(settings)

    Kernel.put_in(settings.major_ticks_text, major_ticks_text)
  end

  defp put_value_text(%__MODULE__{} = settings, keywords) do
    value_text =
      keywords
      |> set_map(%ValueText{})
      |> set_value_text_position(settings.gauge_center)

    Kernel.put_in(settings.value_text, value_text)
  end

  defp put_thresholds(%__MODULE__{} = settings, keywords) do
    thresholds =
      keywords
      |> set_map(%Thresholds{})
      |> set_thresholds(settings)

    Kernel.put_in(settings.thresholds, thresholds)
  end

  # Setters for map keys

  defp set_gauge_center_circle(%__MODULE__{viewbox: {w, h}} = settings) do
    Kernel.put_in(settings.gauge_center, {w / 2, h / 2 + @offset_from_bottom})
  end

  defp set_gauge_half_circle(
         %__MODULE__{gauge_center: {cx, cy}, gauge_radius: {rx, ry}} = settings
       ) do
    Kernel.put_in(
      settings.d_gauge_half_circle,
      "M#{cx - rx}, #{cy} A#{rx}, #{ry} 0 0,1 #{cx + rx}, #{cy}"
    )
  end

  defp set_gauge_bg_border_bottom_lines(
         %__MODULE__{gauge_center: {cx, cy}, gauge_radius: {rx, _ry}} = settings
       ) do
    width = settings.gauge_bottom_width_lines

    Kernel.put_in(
      settings.d_gauge_bg_border_bottom_lines,
      [
        "M#{cx - rx}, #{cy - 0.5} l0, #{width}",
        "M#{cx + rx}, #{cy - 0.5} l0, #{width}"
      ]
    )
  end

  defp set_major_ticks_translate(major_ticks, {_cx, cy}) do
    Map.put(major_ticks, :translate, "translate(#{16.5 - major_ticks.gap}, #{cy})")
  end

  defp set_major_ticks_positions(major_ticks) do
    angles = Utils.linspace(0, 180, major_ticks.count)

    Map.put(major_ticks, :positions, angles)
  end

  defp set_major_ticks_text_positions(major_ticks_text, settings) do
    count = settings.major_ticks.count

    ticks_text_pos =
      settings.range
      |> Utils.linspace(count)
      |> Utils.split_major_tick_values(count)
      |> parse_tick_values(settings, major_ticks_text.gap, major_ticks_text.decimals)

    Map.put(major_ticks_text, :positions, ticks_text_pos)
  end

  defp set_thresholds(thresholds, settings) do
    {cx, cy} = settings.gauge_center
    {rx, _ry} = settings.gauge_radius
    width = thresholds.width

    d_thresholds_with_class =
      thresholds.positions_with_class_name
      |> Enum.map(fn {val, class} ->
        phi = Utils.value_to_angle(val, settings.range)
        angle = 180.0 - Utils.radian_to_degree(phi) + width / 2.0

        {"M#{cx - rx}, #{cy} l0, #{width}", angle, class}
      end)

    Map.put(thresholds, :d_thresholds_with_class, d_thresholds_with_class)
  end

  defp set_value_text_position(value_text, {cx, cy}) do
    {x, y} = value_text.position

    Map.put(value_text, :position, {cx + x, cy + y})
  end

  #  Validators
  defp validate_decimals(decimals) when 0 <= decimals and is_integer(decimals) do
    decimals
  end

  defp validate_number(number) when is_number(number) do
    number
  end

  defp validate_list_of_tuples([]), do: []

  defp validate_list_of_tuples([tpl | tl] = val_colors)
       when is_tuple(tpl) and is_list(tl) do
    val_colors
  end

  defp validate_value_text_position({x, y} = position) when is_number(x) and is_number(y) do
    position
  end

  defp validate_major_ticks_count(count) when 1 < count and is_integer(count) do
    count
  end

  defp validate_range({min, max} = range) when min < max and is_number(min) and is_number(max) do
    range
  end

  defp validate_positive_number(number) when 0 < number and is_number(number) do
    number
  end

  defp validate_viewbox({width, height} = viewbox)
       when 0 < width and 0 < height and is_number(width) and is_number(height) do
    viewbox
  end

  # Helpers

  defp key_guard(kw, key, default_val, fun) do
    fun.(Keyword.get(kw, key, default_val))
  end

  defp set_map(keywords, map) do
    Enum.reduce(keywords, map, fn {key, val}, map -> Map.put(map, key, val) end)
  end

  defp parse_tick_values([left, center, right], settings, gap, decimals)
       when is_list(left) and is_list(center) and is_list(right) do
    l = left |> compute_positions_with_text_anchor(settings, gap, decimals, "end")
    c = center |> compute_positions_with_text_anchor(settings, gap, decimals, "middle")
    r = right |> compute_positions_with_text_anchor(settings, gap, decimals, "start")

    [l, c, r] |> List.flatten()
  end

  defp parse_tick_values([left, right], settings, gap, decimals)
       when is_list(left) and is_list(right) do
    l = left |> compute_positions_with_text_anchor(settings, gap, decimals, "end")
    r = right |> compute_positions_with_text_anchor(settings, gap, decimals, "start")

    [l, r] |> List.flatten()
  end

  defp compute_positions_with_text_anchor(val_list, settings, gap, decimals, text_anchor) do
    {cx, cy} = settings.gauge_center
    {rx, _ry} = settings.gauge_radius

    radius = rx + @offset_radius_major_ticks_text + gap

    val_list
    |> Enum.map(fn tick_val ->
      phi = Utils.value_to_angle(tick_val, settings.range)
      {x, y} = Utils.polar_to_cartesian(radius, phi)

      {cx + x, cy - y, :erlang.float_to_list(1.0 * tick_val, decimals: decimals), text_anchor}
    end)
  end
end

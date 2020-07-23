defmodule Examples.Gauge do
  @moduledoc """
  Gauge graph
  """

  alias Examples.Gauge.{Settings, Svg, Utils}

  @type data() :: nil | number() | list() | map()
  @type t() :: %__MODULE__{
          settings: Settings.t(),
          data: data()
        }

  defstruct settings: %Settings{},
            data: nil

  @doc """
  Setup a visual view of gauge graph.

  """
  @spec setup(list()) :: t()
  def setup(config_keywords) do
    %__MODULE__{settings: Settings.set(config_keywords)}
  end

  def put(%__MODULE__{} = gauge, data) do
    %{gauge | data: data}
  end

  def render(%__MODULE__{} = gauge) do
    gauge
    |> put_gauge_value_half_circle()
    |> put_value_as_text()
    |> put_color_value()
    |> Svg.generate()
  end

  # Private

  defp put_gauge_value_half_circle(
         %__MODULE__{settings: %Settings{range: {a, _b}}, data: value} = gauge
       )
       when is_nil(value) or value < a do
    Kernel.put_in(gauge.settings.d_value, "")
  end

  defp put_gauge_value_half_circle(
         %__MODULE__{
           settings: %Settings{range: {_a, b}, gauge_center: {cx, cy}, gauge_radius: {rx, ry}},
           data: value
         } = gauge
       )
       when b < value do
    Kernel.put_in(
      gauge.settings.d_value,
      "M#{cx - rx}, #{cy} A#{rx}, #{ry} 0 0,1 #{cx + rx}, #{cy}"
    )
  end

  defp put_gauge_value_half_circle(
         %__MODULE__{
           settings: %Settings{range: {a, b}, gauge_center: {cx, cy}, gauge_radius: {rx, ry}},
           data: value
         } = gauge
       ) do
    phi = Utils.value_to_angle(value, a, b)
    {end_rx, end_ry} = Utils.polar_to_cartesian(rx, phi)

    Kernel.put_in(
      gauge.settings.d_value,
      "M#{cx - rx}, #{cy} A#{rx}, #{ry} 0 0,1 #{cx + end_rx}, #{cy - end_ry}"
    )
  end

  defp put_value_as_text(%__MODULE__{data: nil} = gauge) do
    Kernel.put_in(gauge.settings.text_value, "")
  end

  defp put_value_as_text(%__MODULE__{data: value} = gauge) do
    rounded_val = :erlang.float_to_list(1.0 * value, decimals: gauge.settings.value_text.decimals)

    Kernel.put_in(gauge.settings.text_value, rounded_val)
  end

  defp put_color_value(%__MODULE__{data: value} = gauge) do
    class =
      gauge.settings.gauge_value_colors
      |> Enum.find({[], ""}, fn {interval, _class} -> Utils.is_in_interval?(value, interval) end)
      |> Kernel.elem(1)

    Kernel.put_in(gauge.settings.gauge_value_class, class)
  end
end

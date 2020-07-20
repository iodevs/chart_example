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
    |> Svg.generate()
  end

  # Private

  defp put_value_as_text(%__MODULE__{data: nil} = gauge) do
    Kernel.put_in(gauge.settings.text_value, "")
  end

  defp put_value_as_text(%__MODULE__{data: value} = gauge) do
    Kernel.put_in(gauge.settings.text_value, "#{value}")
  end

  defp put_gauge_value_half_circle(%__MODULE__{data: nil} = gauge) do
    Kernel.put_in(gauge.settings.d_value, "")
  end

  defp put_gauge_value_half_circle(%__MODULE__{settings: settings, data: value} = gauge) do
    {cx, cy} = settings.gauge_center
    {rx, ry} = settings.gauge_radius

    phi = Utils.value_to_angle(value, 0, 100)

    end_rx = :math.cos(phi) * rx
    end_ry = cy - :math.sin(phi) * ry

    Kernel.put_in(
      gauge.settings.d_value,
      "M#{cx - rx}, #{cy} A#{rx}, #{ry} 0 0,1 #{cx + end_rx}, #{end_ry}"
    )
  end
end

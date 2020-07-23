defmodule Examples.Gauge.Utils do
  @moduledoc false

  def value_to_angle(val, {a, b}), do: value_to_angle(val, a, b)

  def value_to_angle(val, a, b) do
    :math.pi() - (val - a) * :math.pi() / :erlang.abs(b - a)
  end

  def linspace({min, max}, step), do: linspace(min, max, step)

  def linspace(min, max, step) do
    delta = :erlang.abs(max - min) / (step - 1)

    Enum.reduce(1..(step - 1), [min], fn x, acc ->
      acc ++ [x * delta]
    end)
  end

  def is_in_interval?(val, [a, b]) when a <= val and val <= b, do: true
  def is_in_interval?(_val, _interval), do: false

  def polar_to_cartesian(radius, phi) do
    {radius * :math.cos(phi), radius * :math.sin(phi)}
  end

  def radian_to_degree(rad) do
    rad * 180 / :math.pi()
  end

  def split_major_tick_values([l, r], 2) do
    [[l], [r]]
  end

  def split_major_tick_values(lst_values, count) do
    lst_values
    |> Enum.split(div(count, 2))
    |> rearrange()
  end

  # Private

  defp rearrange({l, r}) when length(l) == length(r), do: [l, r]
  defp rearrange({l, [center | r]}), do: [l, [center], r]
end

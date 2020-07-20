defmodule Examples.Gauge.Svg do
  @moduledoc false

  alias Examples.Gauge

  use Phoenix.HTML

  def generate(%Gauge{} = gauge) do
    assigns = Map.from_struct(gauge)

    ~E"""
    <svg version="1.2" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
      viewbox="0 0 <%= elem(@settings.viewbox, 0) %> <%= elem(@settings.viewbox, 1) %>" >

      <defs>
        <line id="major-line-ticks"
          x1="<%= @settings.major_ticks.length %>"
          transform="<%= @settings.major_ticks.translate %>" />
      </defs>
      <g class="major-ticks">
        <%= for angle <- @settings.major_ticks.positions do %>
          <use xlink:href="#major-line-ticks"
            transform="rotate(<%= angle %>, <%= elem(@settings.gauge_center, 0) %>, <%= elem(@settings.gauge_center, 1) %>)" />
        <% end %>
      </g>

      <g class="gauge">
        <path id="gauge-bg-border"
          d="<%= @settings.d_gauge_half_circle %>">
        </path>
        <path id="gauge-bg"
          d="<%= @settings.d_gauge_half_circle %>">
        </path>
        <path id="gauge-value"
          d="<%= @settings.d_value %>">
        </path>
      </g>

      <text class="value-text"
        x="<%= elem(@settings.text_value_position, 0) %>" y = "<%= elem(@settings.text_value_position, 1) %>"
        text-anchor="middle" alignment-baseline="middle" dominant-baseline="central">
          <%= @settings.text_value %>
      </text>

    </svg>
    """
  end
end

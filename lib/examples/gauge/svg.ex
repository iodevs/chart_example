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

      <g class="major-ticks-text">
        <%= for {x, y, tick_value, text_anchor} <- @settings.major_ticks_text.positions do %>
          <text class="major-text"
            x="<%= x %>" y="<%= y %>"
            text-anchor="<%= text_anchor %>"
            ><%= tick_value %>
          </text>
        <% end %>
      </g>

      <g class="gauge">
        <g class="gauge-bg-border-bottom-lines">
          <path id="gauge-bg-border"
            d="<%= @settings.d_gauge_half_circle %>">
          </path>
          <%= for lines <- @settings.d_gauge_bg_border_bottom_lines do %>
            <path class="gauge-bg-border-bottom-lines"
              d="<%= lines %>">
            </path>
          <% end %>
        </g>
        <path id="gauge-bg"
          d="<%= @settings.d_gauge_half_circle %>">
        </path>
        <path id="gauge-value"
          <%= if String.length(@settings.gauge_value_class) != 0 do %>
            class="<%= @settings.gauge_value_class %>"
          <% end %>
          d="<%= @settings.d_value %>">
        </path>
      </g>

      <%= if !Enum.empty?(@settings.thresholds.positions_with_class_name) do %>
        <g class="thresholds">
          <%= for {treshold, angle, class} <- @settings.thresholds.d_thresholds_with_class do %>
            <path class="<%= class %>"
              d="<%= treshold %>"
              transform="rotate(<%= angle %>, <%= elem(@settings.gauge_center, 0) %>, <%= elem(@settings.gauge_center, 1) %>)">
            </path>
          <% end %>
        </g>
      <% end %>

      <text class="value-font value-text"
        x="<%= elem(@settings.value_text.position, 0) %>" y = "<%= elem(@settings.value_text.position, 1) %>"
        text-anchor="middle" alignment-baseline="middle" dominant-baseline="central"
        ><%= @settings.text_value %>
      </text>

    </svg>
    """
  end
end

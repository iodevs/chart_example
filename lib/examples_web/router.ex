defmodule ExamplesWeb.Router do
  use ExamplesWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ExamplesWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ExamplesWeb do
    pipe_through :browser

    live "/", BarLive, :index
    live "/line", LineLive
    live "/timeline", TimeLineLive
    live "/gauge", GaugeLive
    live "/dashboard_chart", DasboardChartLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", ExamplesWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: ExamplesWeb.Telemetry
    end
  end
end

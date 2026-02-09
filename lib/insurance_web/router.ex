defmodule InsuranceWeb.Router do
  use InsuranceWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {InsuranceWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", InsuranceWeb do
    pipe_through :browser


    live"/pension", PensionLive
    live "/motor", MotorLive
    live "/life", LifeLive
    live "/medical", MedicalLive
    live "/quote", QuoteLive
    live "/home", HomeLive
    live "/admin", AdminLive
    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", InsuranceWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:insurance, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: InsuranceWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end

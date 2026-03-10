defmodule InsuranceWeb.Router do
  use InsuranceWeb, :router

  import InsuranceWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {InsuranceWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # All public live routes — wrapped in live_session so @current_user is always available
  scope "/", InsuranceWeb do
    pipe_through :browser

    live_session :public,
      on_mount: [{InsuranceWeb.UserAuth, :mount_current_user}] do
      live "/", HomeLive
      live "/medical", MedicalLive
      live "/life", LifeLive
      live "/motor", MotorLive
      live "/pension", PensionLive
      live "/admin", AdminLive
    end
  end

  # Protected routes (auth required)
  scope "/", InsuranceWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{InsuranceWeb.UserAuth, :ensure_authenticated}] do
      live "/quote", QuoteLive, :show
      live "/policies", PolicyLive.Index
      live "/my-quotes", MyQuotesLive, :index
      live "/policies/new", PolicyLive.New
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  # Auth routes (redirect if already logged in)
  scope "/", InsuranceWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{InsuranceWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", InsuranceWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{InsuranceWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  if Application.compile_env(:insurance, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: InsuranceWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end

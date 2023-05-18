defmodule PipesineWeb.Router do
  use PipesineWeb, :router

  import PipesineWeb.ComposerAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PipesineWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_composer
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PipesineWeb do
    pipe_through :browser

    live "/", PipesineLive, :index
    live "/about", PipesineLive, :about
    live "/ethos", PipesineLive, :ethos
    live "/label", PipesineLive, :label
    live "/compositions", CompositionLive.Index, :index
    # live "/instructions", CompositionLive.Index, :instructions

    live "/compositions/:id", CompositionLive.Show, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", PipesineWeb do
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

      live_dashboard "/dashboard", metrics: PipesineWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", PipesineWeb do
    pipe_through [:browser, :redirect_if_composer_is_authenticated]

    get "/composers/register", ComposerRegistrationController, :new
    post "/composers/register", ComposerRegistrationController, :create
    get "/composers/log_in", ComposerSessionController, :new
    post "/composers/log_in", ComposerSessionController, :create
    get "/composers/reset_password", ComposerResetPasswordController, :new
    post "/composers/reset_password", ComposerResetPasswordController, :create
    get "/composers/reset_password/:token", ComposerResetPasswordController, :edit
    put "/composers/reset_password/:token", ComposerResetPasswordController, :update
  end

  scope "/", PipesineWeb do
    pipe_through [:browser, :require_authenticated_composer]

    live "/compositions/new", CompositionLive.Index, :new
    live "/compositions/:id/edit", CompositionLive.Index, :edit
    live "/compositions/:id/show/edit", CompositionLive.Show, :edit
    get "/composers/settings", ComposerSettingsController, :edit
    put "/composers/settings", ComposerSettingsController, :update
    get "/composers/settings/confirm_email/:token", ComposerSettingsController, :confirm_email
  end

  scope "/", PipesineWeb do
    pipe_through [:browser]

    delete "/composers/log_out", ComposerSessionController, :delete
    get "/composers/confirm", ComposerConfirmationController, :new
    post "/composers/confirm", ComposerConfirmationController, :create
    get "/composers/confirm/:token", ComposerConfirmationController, :edit
    post "/composers/confirm/:token", ComposerConfirmationController, :update
  end
end

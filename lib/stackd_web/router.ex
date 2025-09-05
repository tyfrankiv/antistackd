defmodule StackdWeb.Router do
  use StackdWeb, :router

  import Oban.Web.Router
  use AshAuthentication.Phoenix.Router

  import AshAuthentication.Plug.Helpers

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {StackdWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
    plug :set_actor, :user
  end

  scope "/", StackdWeb do
    pipe_through :browser

    ash_authentication_live_session :authenticated_routes,
      on_mount: [{StackdWeb.LiveUserAuth, :live_user_required}] do
      # Protected routes that require completed profile
      live "/dashboard", Dashboard.DashboardLive, :index
    end

    ash_authentication_live_session :profile_setup_routes,
      on_mount: [{StackdWeb.LiveUserAuth, :live_user_profile_setup}] do
      # Profile setup - only for authenticated users without completed profiles
      live "/complete-profile", Onboarding.OnboardingLive
    end

    ash_authentication_live_session :public_profile_routes,
      on_mount: [{StackdWeb.LiveUserAuth, :live_user_optional}] do
      # Public profile pages - viewable by anyone
      live "/@:username", Profile.UserProfileLive
      # Redirects to own profile
      live "/profile", Profile.UserProfileLive
    end

    ash_authentication_live_session :public_media_routes,
      on_mount: [{StackdWeb.LiveUserAuth, :live_user_optional}] do
      # Public media pages - anyone can view, logged-in users can interact
      live "/movie/:id", Media.MediaLive, :show
      live "/tv-show/:id", Media.MediaLive, :show
      live "/game/:id", Media.MediaLive, :show
      live "/album/:id", Media.MediaLive, :show
    end
  end

  scope "/", StackdWeb do
    pipe_through :browser

    get "/", PageController, :home
    auth_routes AuthController, Stackd.Accounts.User, path: "/auth"
    sign_out_route AuthController

    # Remove these if you'd like to use your own authentication views
    sign_in_route register_path: "/register",
                  reset_path: "/reset",
                  auth_routes_prefix: "/auth",
                  on_mount: [{StackdWeb.LiveUserAuth, :live_no_user}],
                  overrides: [
                    StackdWeb.AuthOverrides,
                    AshAuthentication.Phoenix.Overrides.Default
                  ]

    # Remove this if you do not want to use the reset password feature
    reset_route auth_routes_prefix: "/auth",
                overrides: [StackdWeb.AuthOverrides, AshAuthentication.Phoenix.Overrides.Default]

    # Remove this if you do not use the confirmation strategy
    confirm_route Stackd.Accounts.User, :confirm_new_user,
      auth_routes_prefix: "/auth",
      overrides: [StackdWeb.AuthOverrides, AshAuthentication.Phoenix.Overrides.Default]

    # Remove this if you do not use the magic link strategy.
    magic_sign_in_route(Stackd.Accounts.User, :magic_link,
      auth_routes_prefix: "/auth",
      overrides: [StackdWeb.AuthOverrides, AshAuthentication.Phoenix.Overrides.Default]
    )
  end

  # Other scopes may use custom stacks.
  # scope "/api", StackdWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:stackd, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: StackdWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end

    scope "/" do
      pipe_through :browser

      oban_dashboard("/oban")
    end
  end

  if Application.compile_env(:stackd, :dev_routes) do
    import AshAdmin.Router

    scope "/admin" do
      pipe_through :browser

      ash_admin "/"
    end
  end
end

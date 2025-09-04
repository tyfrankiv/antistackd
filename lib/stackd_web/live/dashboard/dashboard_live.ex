defmodule StackdWeb.Dashboard.DashboardLive do
  use StackdWeb, :live_view

  on_mount {StackdWeb.LiveUserAuth, :live_user_required}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:page_title, "Dashboard")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={assigns[:current_scope]}>
      <div class="min-h-screen bg-base-200">
        <div class="hero min-h-screen">
          <div class="hero-content text-center">
            <div class="max-w-md">
              <h1 class="text-5xl font-bold text-primary">Dashboard</h1>
              <p class="py-6 text-base-content">
                Welcome back! Your profile is all set up. Start exploring the platform!
              </p>
              <.link navigate={~p"/profile"} class="btn btn-primary">
                View My Profile
              </.link>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end

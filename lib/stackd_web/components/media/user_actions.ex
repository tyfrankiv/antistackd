defmodule StackdWeb.Media.Components.UserActions do
  use StackdWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-wrap gap-3 mt-6">
      <button
        class="btn btn-primary"
        phx-click="show_log_modal"
        phx-target={@myself}
        disabled={!@current_user}
      >
        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
        </svg>
        <%= get_log_button_text(@media_type) %>
      </button>

      <%= if @current_user do %>
        <div class="rating rating-sm">
          <%= for i <- 1..10 do %>
            <input
              type="radio"
              name="rating"
              class="mask mask-star-2 bg-orange-400"
              checked={@user_rating && @user_rating.rating == i}
              phx-click="quick_rate"
              phx-value-rating={i}
              phx-target={@myself}
            />
          <% end %>
        </div>
      <% else %>
        <div class="text-sm opacity-75">
          <a href="/auth/sign_in" class="link">Sign in</a> to rate and log
        </div>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("show_log_modal", _params, socket) do
    send(self(), {:show_log_modal})
    {:noreply, socket}
  end

  @impl true
  def handle_event("quick_rate", %{"rating" => rating}, socket) do
    send(self(), {:quick_rate, rating})
    {:noreply, socket}
  end

  defp get_log_button_text(media_type) do
    case media_type do
      :movie -> "Log Watch"
      :tv_show -> "Log Watch"
      :game -> "Log Play"
      :album -> "Log Listen"
    end
  end
end

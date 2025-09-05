defmodule StackdWeb.Media.Components.UserActions do
  use StackdWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="card bg-base-200 shadow-xl">
      <div class="card-body">
        <%= if @current_user do %>
          <h3 class="card-title mb-4">Quick Actions</h3>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <!-- Quick Rating (if not already rated) -->
            <%= if !@user_stats[:rating] do %>
              <div class="card bg-base-300">
                <div class="card-body p-4">
                  <h4 class="card-title text-sm mb-3">Rate this <%= @media_type %></h4>
                  <div class="rating rating-md gap-1 justify-center">
                    <button
                      :for={i <- 1..10}
                      type="button"
                      phx-click="quick_rate"
                      phx-value-rating={i}
                      phx-target={@myself}
                      class="mask mask-star-2 bg-base-content/20 hover:bg-warning transition-all duration-200 hover:scale-110"
                      title={"Rate #{i}/10"}
                    >
                    </button>
                  </div>
                  <div class="text-center text-xs text-base-content/60 mt-2">
                    Click stars to rate
                  </div>
                </div>
              </div>
            <% else %>
              <!-- Current Rating Display -->
              <div class="card bg-gradient-to-r from-secondary/20 to-secondary/10">
                <div class="card-body p-4 text-center">
                  <h4 class="card-title text-sm justify-center mb-2">Your Rating</h4>
                  <div class="flex items-center justify-center gap-3">
                    <div class="text-2xl font-bold text-secondary">
                      <%= @user_stats[:rating] %>
                    </div>
                    <div class="rating rating-sm">
                      <%= render_user_stars(@user_stats[:rating]) %>
                    </div>
                  </div>
                  <button
                    type="button"
                    phx-click="edit_rating"
                    class="btn btn-xs btn-outline btn-secondary mt-2"
                  >
                    Edit Rating
                  </button>
                </div>
              </div>
            <% end %>

            <!-- Log Entry Button -->
            <div class="card bg-base-300 hover:bg-primary/10 transition-colors cursor-pointer" phx-click="show_interaction_modal">
              <div class="card-body p-4 text-center">
                <div class="text-3xl mb-2">📝</div>
                <h4 class="card-title text-sm justify-center mb-2">
                  Log <%= activity_verb(@media_type) %>
                </h4>
                <p class="text-xs text-base-content/70">
                  Add to your <%= String.downcase(activity_verb(@media_type)) %> history
                </p>
              </div>
            </div>
          </div>

          <!-- Action Buttons Row -->
          <div class="flex flex-wrap gap-3 mt-6">
            <button
              type="button"
              phx-click="show_interaction_modal"
              class="btn btn-primary flex-1 md:flex-initial"
            >
              <span class="mr-2">📝</span>
              Full Log Entry
            </button>

            <button
              type="button"
              class="btn btn-outline btn-info flex-1 md:flex-initial"
              title="Add to watchlist (coming soon)"
              disabled
            >
              <span class="mr-2">📚</span>
              Watchlist
            </button>

            <button
              type="button"
              phx-click="share_media"
              class="btn btn-outline btn-success flex-1 md:flex-initial"
            >
              <span class="mr-2">🔗</span>
              Share
            </button>
          </div>

          <!-- Recent Activity Summary -->
          <%= if @user_stats[:log_count] && @user_stats[:log_count] > 0 do %>
            <div class="divider">Activity Summary</div>

            <div class="stats stats-horizontal shadow bg-base-300">
              <div class="stat place-items-center">
                <div class="stat-title text-xs">Total</div>
                <div class="stat-value text-lg text-primary">
                  <%= @user_stats[:log_count] %>
                </div>
                <div class="stat-desc text-xs">
                  <%= activity_plural(@media_type) %>
                </div>
              </div>

              <%= if @user_stats[:rating] do %>
                <div class="stat place-items-center">
                  <div class="stat-title text-xs">Your Rating</div>
                  <div class="stat-value text-lg text-secondary">
                    <%= @user_stats[:rating] %>
                  </div>
                  <div class="stat-desc text-xs">out of 10</div>
                </div>
              <% end %>

              <%= if @user_stats[:last_logged] do %>
                <div class="stat place-items-center">
                  <div class="stat-title text-xs">Last Time</div>
                  <div class="stat-value text-sm">
                    <%= format_last_logged(@user_stats[:last_logged]) %>
                  </div>
                  <div class="stat-desc text-xs">ago</div>
                </div>
              <% end %>
            </div>
          <% end %>
        <% else %>
          <!-- Sign in prompt for anonymous users -->
          <div class="text-center py-8">
            <div class="text-5xl mb-4 opacity-60">🔒</div>
            <h3 class="text-xl font-semibold mb-3 text-base-content">
              Sign in to track your progress
            </h3>
            <p class="text-base-content/70 mb-6">
              Rate, log, and review this <%= @media_type %> to build your personal library.
            </p>

            <div class="flex flex-col sm:flex-row gap-3 justify-center">
              <a href="/auth/sign-in" class="btn btn-primary">
                Sign In
              </a>
              <a href="/auth/register" class="btn btn-outline">
                Create Account
              </a>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("quick_rate", %{"rating" => rating_str}, socket) do
    rating = String.to_integer(rating_str)
    send(self(), {:rate_media, rating})
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit_rating", _params, socket) do
    send(self(), :show_rating_modal)
    {:noreply, socket}
  end

  @impl true
  def handle_event("share_media", _params, socket) do
    send(self(), :share_media)
    {:noreply, socket}
  end

  defp activity_verb("movie"), do: "Watch"
  defp activity_verb("tv_show"), do: "Watch"
  defp activity_verb("album"), do: "Listen"
  defp activity_verb("game"), do: "Play"

  defp activity_plural("movie"), do: "watches"
  defp activity_plural("tv_show"), do: "watches"
  defp activity_plural("album"), do: "listens"
  defp activity_plural("game"), do: "plays"

  defp render_user_stars(rating) when is_integer(rating) do
    # Convert 1-10 scale to 1-5 stars for display
    stars = rating / 2
    full_stars = floor(stars)
    has_half = stars - full_stars >= 0.5

    Phoenix.HTML.raw([
      for(_ <- 1..full_stars, do: ~s(<input type="radio" class="mask mask-star-2 bg-secondary" disabled />)),
      if(has_half, do: ~s(<input type="radio" class="mask mask-star-half bg-secondary" disabled />), else: ""),
      for(_ <- 1..(5 - full_stars - (if has_half, do: 1, else: 0)), do: ~s(<input type="radio" class="mask mask-star-2 bg-base-content/20" disabled />))
    ])
  end

  defp render_user_stars(_), do: ""

  defp format_last_logged(log) do
    now = Date.utc_today()
    days_ago = Date.diff(now, log.logged_date)

    cond do
      days_ago == 0 -> "Today"
      days_ago == 1 -> "1 day"
      days_ago < 7 -> "#{days_ago} days"
      days_ago < 30 -> "#{div(days_ago, 7)} weeks"
      days_ago < 365 -> "#{div(days_ago, 30)} months"
      true -> "#{div(days_ago, 365)} years"
    end
  end
end

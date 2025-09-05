defmodule StackdWeb.Media.Components.MediaStats do
  use StackdWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="card bg-base-200 shadow-xl">
      <div class="card-body">
        <h3 class="card-title flex items-center gap-2">
          <%= media_icon(@media_type) %>
          Your Activity
        </h3>

        <div class="stats stats-vertical">
          <!-- Average Rating Stat -->
          <%= if @media.average_rating do %>
            <div class="stat">
              <div class="stat-title">Community Rating</div>
              <div class="stat-value text-warning">
                <%= format_average_rating(@media.average_rating) %>
              </div>
              <div class="stat-desc">
                <%= @rating_count || 0 %> <%= if (@rating_count || 0) == 1, do: "rating", else: "ratings" %>
              </div>
            </div>
          <% end %>

          <!-- User Log Count -->
          <div class="stat">
            <div class="stat-title">Times <%= activity_verb(@media_type) %></div>
            <div class="stat-value text-primary">
              <%= @user_stats[:log_count] || 0 %>
            </div>
            <div class="stat-desc">
              <%= if (@user_stats[:log_count] || 0) > 0, do: "Great progress!", else: "Start tracking!" %>
            </div>
          </div>

          <!-- Your Rating -->
          <%= if @user_stats[:rating] do %>
            <div class="stat">
              <div class="stat-title">Your Rating</div>
              <div class="stat-value text-secondary">
                <%= @user_stats[:rating] %>
              </div>
              <div class="stat-desc">out of 10</div>
            </div>
          <% end %>
        </div>

        <!-- Last Activity Section -->
        <%= if @user_stats[:last_logged] do %>
          <div class="divider"></div>

          <div class="space-y-3">
            <h4 class="font-medium text-base-content/80">
              Last <%= String.downcase(activity_verb(@media_type)) %>
            </h4>

            <div class="flex items-center justify-between">
              <div class="flex items-center gap-2">
                <div class="avatar placeholder">
                  <div class="bg-primary text-primary-content rounded-full w-8 h-8">
                    <span class="text-xs">📅</span>
                  </div>
                </div>
                <div>
                  <div class="font-medium">
                    <%= format_date(@user_stats.last_logged.logged_date) %>
                  </div>
                  <div class="text-sm text-base-content/60">
                    <%= time_ago(@user_stats.last_logged.logged_date) %>
                  </div>
                </div>
              </div>

              <!-- Show rating if exists -->
              <%= if @user_stats.last_logged.rating do %>
                <div class="badge badge-secondary badge-lg">
                  <%= @user_stats.last_logged.rating %>/10
                </div>
              <% end %>
            </div>

            <!-- Show rewatch/relisten indicator -->
            <%= if get_rewatch_status(@user_stats.last_logged, @media_type) do %>
              <div class="alert alert-info">
                <div class="flex items-center gap-2">
                  <span>🔄</span>
                  <span><%= rewatch_label(@media_type) %></span>
                </div>
              </div>
            <% end %>

            <!-- Show notes if any -->
            <%= if @user_stats.last_logged.notes && String.trim(@user_stats.last_logged.notes) != "" do %>
              <div class="card bg-base-300">
                <div class="card-body p-3">
                  <h5 class="card-title text-sm">Your Notes</h5>
                  <p class="text-sm italic text-base-content/80">
                    "<%= @user_stats.last_logged.notes %>"
                  </p>
                </div>
              </div>
            <% end %>
          </div>
        <% else %>
          <!-- No Activity Message -->
          <div class="text-center py-6">
            <div class="text-6xl opacity-40 mb-3">
              <%= media_icon(@media_type) %>
            </div>
            <p class="text-base-content/60 mb-4">
              Haven't <%= String.downcase(activity_verb(@media_type)) %> this yet
            </p>
            <button
              type="button"
              phx-click="show_interaction_modal"
              class="btn btn-primary btn-sm"
            >
              Log Your First <%= String.capitalize(String.downcase(activity_verb(@media_type))) %>
            </button>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp format_average_rating(rating) when is_number(rating) do
    :erlang.float_to_binary(rating, decimals: 1)
  end
  defp format_average_rating(_), do: "—"

  defp activity_verb("movie"), do: "Watched"
  defp activity_verb("tv_show"), do: "Watched"
  defp activity_verb("album"), do: "Listened"
  defp activity_verb("game"), do: "Played"

  defp rewatch_label("movie"), do: "Rewatched"
  defp rewatch_label("tv_show"), do: "Rewatched"
  defp rewatch_label("album"), do: "Relistened"
  defp rewatch_label("game"), do: "Replayed"

  defp get_rewatch_status(log, "movie"), do: log.is_rewatch
  defp get_rewatch_status(log, "tv_show"), do: log.is_rewatch
  defp get_rewatch_status(log, "album"), do: log.is_relisten
  defp get_rewatch_status(log, "game"), do: log.is_replay

  defp media_icon("movie"), do: "🎬"
  defp media_icon("album"), do: "🎵"
  defp media_icon("game"), do: "🎮"
  defp media_icon("tv_show"), do: "📺"

  defp format_date(date) do
    Calendar.strftime(date, "%B %d, %Y")
  end

  defp time_ago(date) do
    now = Date.utc_today()
    days_ago = Date.diff(now, date)

    cond do
      days_ago == 0 -> "Today"
      days_ago == 1 -> "Yesterday"
      days_ago < 7 -> "#{days_ago} days ago"
      days_ago < 30 -> "#{div(days_ago, 7)} weeks ago"
      days_ago < 365 -> "#{div(days_ago, 30)} months ago"
      true -> "#{div(days_ago, 365)} years ago"
    end
  end
end

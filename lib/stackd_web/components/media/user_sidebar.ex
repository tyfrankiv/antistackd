defmodule StackdWeb.Media.Components.UserSidebar do
  use StackdWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <!-- User Activity Card -->
      <%= if @current_user && @user_logs && length(@user_logs) > 0 do %>
        <div class="card bg-base-200 shadow-lg">
          <div class="card-body">
            <h3 class="card-title text-lg">
              <%= media_icon(@media_type) %>
              Your <%= get_activity_title(@media_type) %>
            </h3>

            <div class="space-y-3">
              <%= for {log, index} <- Enum.with_index(Enum.take(@user_logs, 5)) do %>
                <div class="flex justify-between items-center p-3 bg-base-300 rounded-lg hover:bg-base-100 transition-colors">
                  <div class="flex items-center gap-3">
                    <div class="avatar placeholder">
                      <div class={["w-8 h-8 rounded-full text-xs", activity_color(@media_type, index)]}>
                        <%= index + 1 %>
                      </div>
                    </div>

                    <div>
                      <div class="font-medium text-sm">
                        <%= format_date(log.logged_date) %>
                      </div>
                      <div class="text-xs text-base-content/60">
                        <%= time_since(log.logged_date) %>
                      </div>
                    </div>
                  </div>

                  <div class="flex items-center gap-2">
                    <%= if get_rewatch_status(log, @media_type) do %>
                      <div class="tooltip" data-tip={rewatch_label(@media_type)}>
                        <div class="badge badge-info badge-sm">🔄</div>
                      </div>
                    <% end %>

                    <%= if log.rating do %>
                      <div class="badge badge-warning badge-sm font-medium">
                        <%= log.rating %>/10
                      </div>
                    <% end %>
                  </div>
                </div>

                <%= if log.notes && String.trim(log.notes) != "" do %>
                  <div class="bg-base-100 rounded p-2 ml-11 text-xs italic text-base-content/70">
                    "<%= String.slice(log.notes, 0, 80) %><%= if String.length(log.notes) > 80, do: "..." %>"
                  </div>
                <% end %>
              <% end %>

              <%= if length(@user_logs) > 5 do %>
                <div class="text-center pt-2">
                  <div class="text-xs text-base-content/60">
                    +<%= length(@user_logs) - 5 %> more <%= String.downcase(get_activity_title(@media_type)) %>
                  </div>
                  <button class="btn btn-xs btn-ghost btn-outline mt-1">
                    View All
                  </button>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      <% end %>

      <!-- Community Stats Card -->
      <%= if @media.average_rating do %>
        <div class="card bg-gradient-to-br from-primary/10 to-secondary/10 shadow-lg">
          <div class="card-body">
            <h3 class="card-title text-lg">Community Stats</h3>

            <div class="stats stats-vertical shadow-inner bg-base-200/50">
              <div class="stat place-items-center py-2">
                <div class="stat-title text-xs">Average Rating</div>
                <div class="stat-value text-2xl text-warning">
                  <%= format_average_rating(@media.average_rating) %>
                </div>
                <div class="rating rating-sm">
                  <%= render_stars_display(@media.average_rating) %>
                </div>
              </div>

              <div class="stat place-items-center py-2">
                <div class="stat-title text-xs">Total Ratings</div>
                <div class="stat-value text-lg">
                  <%= @rating_count || 0 %>
                </div>
                <div class="stat-desc">users rated this</div>
              </div>
            </div>
          </div>
        </div>
      <% end %>

      <!-- Media Details Card -->
      <div class="card bg-base-200 shadow-lg">
        <div class="card-body">
          <h3 class="card-title text-lg">Details</h3>
          <div class="space-y-3">
            <%= render_media_details(@media, @media_type) %>
          </div>
        </div>
      </div>

      <!-- Similar/Related Media (Placeholder for future feature) -->
      <div class="card bg-base-200 shadow-lg opacity-60">
        <div class="card-body">
          <h3 class="card-title text-lg text-base-content/60">
            Similar <%= String.capitalize(@media_type) %>s
          </h3>
          <div class="text-center py-8">
            <div class="text-3xl mb-2 opacity-40">🔍</div>
            <p class="text-sm text-base-content/60">
              Coming soon
            </p>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp get_activity_title(media_type) do
    case media_type do
      "movie" -> "Watches"
      "tv_show" -> "Watches"
      "game" -> "Plays"
      "album" -> "Listens"
    end
  end

  defp activity_color(media_type, index) do
    base_colors = case media_type do
      "movie" -> ["bg-red-500", "bg-red-400", "bg-red-300"]
      "tv_show" -> ["bg-blue-500", "bg-blue-400", "bg-blue-300"]
      "album" -> ["bg-purple-500", "bg-purple-400", "bg-purple-300"]
      "game" -> ["bg-green-500", "bg-green-400", "bg-green-300"]
    end

    color_index = rem(index, length(base_colors))
    "#{Enum.at(base_colors, color_index)} text-white"
  end

  defp media_icon("movie"), do: "🎬"
  defp media_icon("album"), do: "🎵"
  defp media_icon("game"), do: "🎮"
  defp media_icon("tv_show"), do: "📺"

  defp render_media_details(media, media_type) do
    case media_type do
      "movie" -> movie_details(media)
      "tv_show" -> tv_show_details(media)
      "game" -> game_details(media)
      "album" -> album_details(media)
    end
  end

  defp movie_details(movie) do
    assigns = %{movie: movie}

    ~H"""
    <%= if @movie.genres && length(@movie.genres) > 0 do %>
      <div class="flex flex-col gap-1">
        <span class="text-sm font-medium text-base-content/70">Genres</span>
        <div class="flex flex-wrap gap-1">
          <div :for={genre <- Enum.take(@movie.genres, 3)} class="badge badge-neutral badge-sm">
            <%= genre %>
          </div>
        </div>
      </div>
    <% end %>

    <%= if @movie.runtime do %>
      <div class="flex justify-between">
        <span class="text-sm text-base-content/70">Runtime</span>
        <span class="text-sm font-medium"><%= @movie.runtime %> min</span>
      </div>
    <% end %>

    <%= if @movie.release_date do %>
      <div class="flex justify-between">
        <span class="text-sm text-base-content/70">Released</span>
        <span class="text-sm font-medium"><%= Calendar.strftime(@movie.release_date, "%b %d, %Y") %></span>
      </div>
    <% end %>

    <%= if @movie.original_language do %>
      <div class="flex justify-between">
        <span class="text-sm text-base-content/70">Language</span>
        <span class="text-sm font-medium"><%= String.upcase(@movie.original_language) %></span>
      </div>
    <% end %>
    """
  end

  defp tv_show_details(show) do
    assigns = %{show: show}

    ~H"""
    <%= if @show.genres && length(@show.genres) > 0 do %>
      <div class="flex flex-col gap-1">
        <span class="text-sm font-medium text-base-content/70">Genres</span>
        <div class="flex flex-wrap gap-1">
          <div :for={genre <- Enum.take(@show.genres, 3)} class="badge badge-neutral badge-sm">
            <%= genre %>
          </div>
        </div>
      </div>
    <% end %>

    <%= if @show.number_of_seasons do %>
      <div class="flex justify-between">
        <span class="text-sm text-base-content/70">Seasons</span>
        <span class="text-sm font-medium"><%= @show.number_of_seasons %></span>
      </div>
    <% end %>

    <%= if @show.number_of_episodes do %>
      <div class="flex justify-between">
        <span class="text-sm text-base-content/70">Episodes</span>
        <span class="text-sm font-medium"><%= @show.number_of_episodes %></span>
      </div>
    <% end %>

    <%= if @show.first_air_date do %>
      <div class="flex justify-between">
        <span class="text-sm text-base-content/70">First Aired</span>
        <span class="text-sm font-medium"><%= Calendar.strftime(@show.first_air_date, "%b %d, %Y") %></span>
      </div>
    <% end %>

    <%= if @show.status do %>
      <div class="flex justify-between">
        <span class="text-sm text-base-content/70">Status</span>
        <div class={["badge badge-sm", status_badge_class(@show.status)]}>
          <%= @show.status %>
        </div>
      </div>
    <% end %>
    """
  end

  defp game_details(game) do
    assigns = %{game: game}

    ~H"""
    <%= if @game.platforms && length(@game.platforms) > 0 do %>
      <div class="flex flex-col gap-1">
        <span class="text-sm font-medium text-base-content/70">Platforms</span>
        <div class="flex flex-wrap gap-1">
          <div :for={platform <- Enum.take(@game.platforms, 4)} class="badge badge-neutral badge-xs">
            <%= platform %>
          </div>
        </div>
      </div>
    <% end %>

    <%= if @game.released do %>
      <div class="flex justify-between">
        <span class="text-sm text-base-content/70">Released</span>
        <span class="text-sm font-medium"><%= Calendar.strftime(@game.released, "%b %d, %Y") %></span>
      </div>
    <% end %>

    <%= if @game.developers && length(@game.developers) > 0 do %>
      <div class="flex justify-between">
        <span class="text-sm text-base-content/70">Developer</span>
        <span class="text-sm font-medium"><%= Enum.at(@game.developers, 0) %></span>
      </div>
    <% end %>

    <%= if @game.esrb_rating do %>
      <div class="flex justify-between">
        <span class="text-sm text-base-content/70">Rating</span>
        <div class="badge badge-warning badge-sm">
          <%= @game.esrb_rating %>
        </div>
      </div>
    <% end %>
    """
  end

  defp album_details(album) do
    assigns = %{album: album}

    ~H"""
    <%= if @album.artist do %>
      <div class="flex justify-between">
        <span class="text-sm text-base-content/70">Artist</span>
        <span class="text-sm font-medium"><%= @album.artist %></span>
      </div>
    <% end %>

    <%= if @album.release_date do %>
      <div class="flex justify-between">
        <span class="text-sm text-base-content/70">Released</span>
        <span class="text-sm font-medium"><%= Calendar.strftime(@album.release_date, "%b %d, %Y") %></span>
      </div>
    <% end %>

    <%= if @album.total_tracks do %>
      <div class="flex justify-between">
        <span class="text-sm text-base-content/70">Tracks</span>
        <span class="text-sm font-medium"><%= @album.total_tracks %></span>
      </div>
    <% end %>

    <%= if @album.label do %>
      <div class="flex justify-between">
        <span class="text-sm text-base-content/70">Label</span>
        <span class="text-sm font-medium"><%= @album.label %></span>
      </div>
    <% end %>

    <%= if @album.genres && length(@album.genres) > 0 do %>
      <div class="flex flex-col gap-1">
        <span class="text-sm font-medium text-base-content/70">Genres</span>
        <div class="flex flex-wrap gap-1">
          <div :for={genre <- Enum.take(@album.genres, 3)} class="badge badge-neutral badge-sm">
            <%= genre %>
          </div>
        </div>
      </div>
    <% end %>
    """
  end

  defp status_badge_class("Ended"), do: "badge-neutral"
  defp status_badge_class("Returning Series"), do: "badge-success"
  defp status_badge_class("In Production"), do: "badge-info"
  defp status_badge_class("Canceled"), do: "badge-error"
  defp status_badge_class(_), do: "badge-ghost"

  defp get_rewatch_status(log, media_type) do
    case media_type do
      "movie" -> log.is_rewatch
      "tv_show" -> log.is_rewatch
      "album" -> log.is_relisten
      "game" -> log.is_replay
    end
  end

  defp rewatch_label("movie"), do: "Rewatched"
  defp rewatch_label("tv_show"), do: "Rewatched"
  defp rewatch_label("album"), do: "Relistened"
  defp rewatch_label("game"), do: "Replayed"

  defp format_date(date) when is_struct(date, Date) do
    Calendar.strftime(date, "%b %d")
  end

  defp format_date(datetime) when is_struct(datetime, DateTime) do
    datetime
    |> DateTime.to_date()
    |> format_date()
  end

  defp format_date(_), do: "Unknown"

  defp time_since(date) when is_struct(date, Date) do
    now = Date.utc_today()
    days_ago = Date.diff(now, date)

    cond do
      days_ago == 0 -> "today"
      days_ago == 1 -> "yesterday"
      days_ago < 7 -> "#{days_ago}d ago"
      days_ago < 30 -> "#{div(days_ago, 7)}w ago"
      days_ago < 365 -> "#{div(days_ago, 30)}mo ago"
      true -> "#{div(days_ago, 365)}y ago"
    end
  end

  defp time_since(_), do: "unknown"

  defp format_average_rating(rating) when is_number(rating) do
    :erlang.float_to_binary(rating, decimals: 1)
  end
  defp format_average_rating(_), do: "—"

  defp render_stars_display(rating) when is_number(rating) do
    # Convert 1-10 scale to 1-5 stars for display
    stars = rating / 2
    full_stars = floor(stars)
    has_half = stars - full_stars >= 0.5

    Phoenix.HTML.raw([
      for(_ <- 1..full_stars, do: ~s(<input type="radio" class="mask mask-star-2 bg-warning" disabled />)),
      if(has_half, do: ~s(<input type="radio" class="mask mask-star-half bg-warning" disabled />), else: ""),
      for(_ <- 1..(5 - full_stars - (if has_half, do: 1, else: 0)), do: ~s(<input type="radio" class="mask mask-star-2 bg-base-content/20" disabled />))
    ])
  end

  defp render_stars_display(_), do: ""
end

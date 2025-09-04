defmodule StackdWeb.Media.Components.UserSidebar do
  use StackdWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <%= if @current_user && @user_logs != [] do %>
        <div class="card bg-base-200">
          <div class="card-body">
            <h3 class="card-title">Your <%= get_activity_title(@media_type) %></h3>
            <div class="space-y-2">
              <%= for log <- Enum.take(@user_logs, 3) do %>
                <div class="flex justify-between items-center">
                  <span class="text-sm"><%= format_date(log.logged_date) %></span>
                  <%= if log.rating do %>
                    <span class="badge badge-sm"><%= log.rating %>/10</span>
                  <% end %>
                </div>
              <% end %>

              <%= if length(@user_logs) > 3 do %>
                <div class="text-xs opacity-60 pt-2">
                  +<%= length(@user_logs) - 3 %> more <%= String.downcase(get_activity_title(@media_type)) %>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      <% end %>

      <!-- Media Details -->
      <div class="card bg-base-200">
        <div class="card-body">
          <h3 class="card-title">Details</h3>
          <div class="space-y-2 text-sm">
            <%= render_media_details(@media, @media_type) %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp get_activity_title(media_type) do
    case media_type do
      :movie -> "Watches"
      :tv_show -> "Watches"
      :game -> "Plays"
      :album -> "Listens"
    end
  end

  defp render_media_details(media, media_type) do
    case media_type do
      :movie -> movie_details(media)
      :tv_show -> tv_show_details(media)
      :game -> game_details(media)
      :album -> album_details(media)
    end
  end

  defp movie_details(movie) do
    assigns = %{movie: movie}
    ~H"""
    <div><strong>Genre:</strong> <%= @movie.genres |> Enum.map(& &1.name) |> Enum.join(", ") %></div>
    <div><strong>Runtime:</strong> <%= @movie.runtime %> minutes</div>
    <div><strong>Release:</strong> <%= @movie.release_date %></div>
    <%= if @movie.director do %>
      <div><strong>Director:</strong> <%= @movie.director %></div>
    <% end %>
    """
  end

  defp tv_show_details(show) do
    assigns = %{show: show}
    ~H"""
    <div><strong>Genre:</strong> <%= @show.genres |> Enum.map(& &1.name) |> Enum.join(", ") %></div>
    <div><strong>Seasons:</strong> <%= @show.number_of_seasons %></div>
    <div><strong>Episodes:</strong> <%= @show.number_of_episodes %></div>
    <div><strong>First Aired:</strong> <%= @show.first_air_date %></div>
    <%= if @show.status do %>
      <div><strong>Status:</strong> <%= @show.status %></div>
    <% end %>
    """
  end

  defp game_details(game) do
    assigns = %{game: game}
    ~H"""
    <div><strong>Platforms:</strong> <%= @game.platforms %></div>
    <div><strong>Developer:</strong> <%= @game.developer %></div>
    <div><strong>Release:</strong> <%= @game.release_date %></div>
    <%= if @game.genre do %>
      <div><strong>Genre:</strong> <%= @game.genre %></div>
    <% end %>
    """
  end

  defp album_details(album) do
    assigns = %{album: album}
    ~H"""
    <div><strong>Artist:</strong> <%= @album.artist_name %></div>
    <div><strong>Release:</strong> <%= @album.release_date %></div>
    <div><strong>Tracks:</strong> <%= @album.total_tracks %></div>
    <%= if @album.genre do %>
      <div><strong>Genre:</strong> <%= @album.genre %></div>
    <% end %>
    """
  end

  defp format_date(date) when is_struct(date, Date) do
    Date.to_string(date)
  end

  defp format_date(datetime) when is_struct(datetime, DateTime) do
    datetime
    |> DateTime.to_date()
    |> Date.to_string()
  end

  defp format_date(_), do: "Unknown"
end

defmodule StackdWeb.Media.Components.MediaInfo do
  use StackdWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-4">
      <!-- Title -->
      <div class="space-y-2">
        <h1 class="text-2xl md:text-4xl font-bold text-base-content">
          <%= media_title(@media, @media_type) %>
        </h1>

        <!-- Year and Type Badge -->
        <div class="flex items-center gap-2">
          <span class="text-lg text-base-content/70">
            <%= media_year(@media, @media_type) %>
          </span>
          <div class="badge badge-secondary badge-lg">
            <%= String.upcase(@media_type) %>
          </div>
        </div>
      </div>

      <!-- Genres -->
      <div class="flex flex-wrap gap-2" :if={@media.genres && length(@media.genres) > 0}>
        <div
          :for={genre <- @media.genres}
          class="badge badge-outline badge-lg"
        >
          <%= genre %>
        </div>
      </div>

      <!-- Description/Overview -->
      <div class="prose prose-base text-base-content/90 max-w-none" :if={description(@media, @media_type)}>
        <p><%= description(@media, @media_type) %></p>
      </div>

      <!-- Additional Details Card -->
      <div class="card bg-base-200 shadow-sm">
        <div class="card-body p-4">
          <h3 class="card-title text-lg">Details</h3>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <%= render_media_details(@media, @media_type) %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp media_title(media, "movie"), do: media.title
  defp media_title(media, _), do: media.name

  defp media_year(media, media_type) do
    case media_type do
      "movie" -> if media.release_date, do: media.release_date.year, else: "TBA"
      "tv_show" -> if media.first_air_date, do: media.first_air_date.year, else: "TBA"
      "album" -> if media.release_date, do: media.release_date.year, else: "TBA"
      "game" -> if media.released, do: media.released.year, else: "TBA"
    end
  end

  defp description(media, media_type) do
    case media_type do
      media_type when media_type in ["movie", "tv_show"] -> media.overview
      "game" -> media.description
      _ -> nil
    end
  end

  defp render_media_details(media, media_type) do
    case media_type do
      "movie" -> movie_details(media)
      "tv_show" -> tv_show_details(media)
      "album" -> album_details(media)
      "game" -> game_details(media)
    end
  end

  defp movie_details(movie) do
    assigns = %{movie: movie}

    ~H"""
    <%= if @movie.runtime do %>
      <div class="flex justify-between">
        <span class="text-base-content/70">Runtime:</span>
        <span class="font-medium"><%= @movie.runtime %> min</span>
      </div>
    <% end %>

    <%= if @movie.release_date do %>
      <div class="flex justify-between">
        <span class="text-base-content/70">Release Date:</span>
        <span class="font-medium"><%= Calendar.strftime(@movie.release_date, "%B %d, %Y") %></span>
      </div>
    <% end %>

    <%= if @movie.original_language do %>
      <div class="flex justify-between">
        <span class="text-base-content/70">Language:</span>
        <span class="font-medium"><%= String.upcase(@movie.original_language) %></span>
      </div>
    <% end %>

    <%= if @movie.budget && @movie.budget > 0 do %>
      <div class="flex justify-between">
        <span class="text-base-content/70">Budget:</span>
        <span class="font-medium">$<%= Number.Delimit.number_to_delimited(@movie.budget) %></span>
      </div>
    <% end %>
    """
  end

  defp tv_show_details(show) do
    assigns = %{show: show}

    ~H"""
    <%= if @show.number_of_seasons do %>
      <div class="flex justify-between">
        <span class="text-base-content/70">Seasons:</span>
        <span class="font-medium"><%= @show.number_of_seasons %></span>
      </div>
    <% end %>

    <%= if @show.number_of_episodes do %>
      <div class="flex justify-between">
        <span class="text-base-content/70">Episodes:</span>
        <span class="font-medium"><%= @show.number_of_episodes %></span>
      </div>
    <% end %>

    <%= if @show.first_air_date do %>
      <div class="flex justify-between">
        <span class="text-base-content/70">First Aired:</span>
        <span class="font-medium"><%= Calendar.strftime(@show.first_air_date, "%B %d, %Y") %></span>
      </div>
    <% end %>

    <%= if @show.status do %>
      <div class="flex justify-between">
        <span class="text-base-content/70">Status:</span>
        <div class={["badge", status_badge_class(@show.status)]}>
          <%= @show.status %>
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
        <span class="text-base-content/70">Artist:</span>
        <span class="font-medium"><%= @album.artist %></span>
      </div>
    <% end %>

    <%= if @album.release_date do %>
      <div class="flex justify-between">
        <span class="text-base-content/70">Release Date:</span>
        <span class="font-medium"><%= Calendar.strftime(@album.release_date, "%B %d, %Y") %></span>
      </div>
    <% end %>

    <%= if @album.total_tracks do %>
      <div class="flex justify-between">
        <span class="text-base-content/70">Tracks:</span>
        <span class="font-medium"><%= @album.total_tracks %></span>
      </div>
    <% end %>

    <%= if @album.label do %>
      <div class="flex justify-between">
        <span class="text-base-content/70">Label:</span>
        <span class="font-medium"><%= @album.label %></span>
      </div>
    <% end %>
    """
  end

  defp game_details(game) do
    assigns = %{game: game}

    ~H"""
    <%= if @game.platforms && length(@game.platforms) > 0 do %>
      <div class="col-span-2">
        <span class="text-base-content/70">Platforms:</span>
        <div class="flex flex-wrap gap-1 mt-1">
          <div
            :for={platform <- Enum.take(@game.platforms, 6)}
            class="badge badge-sm badge-neutral"
          >
            <%= platform %>
          </div>
        </div>
      </div>
    <% end %>

    <%= if @game.released do %>
      <div class="flex justify-between">
        <span class="text-base-content/70">Release Date:</span>
        <span class="font-medium"><%= Calendar.strftime(@game.released, "%B %d, %Y") %></span>
      </div>
    <% end %>

    <%= if @game.developers && length(@game.developers) > 0 do %>
      <div class="flex justify-between">
        <span class="text-base-content/70">Developer:</span>
        <span class="font-medium"><%= Enum.at(@game.developers, 0) %></span>
      </div>
    <% end %>

    <%= if @game.esrb_rating do %>
      <div class="flex justify-between">
        <span class="text-base-content/70">ESRB Rating:</span>
        <div class="badge badge-warning badge-sm">
          <%= @game.esrb_rating %>
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
end

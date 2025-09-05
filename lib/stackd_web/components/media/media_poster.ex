defmodule StackdWeb.Media.Components.MediaPoster do
  use StackdWeb, :live_component

  @impl true
  def render(assigns) do
    assigns = assign_new(assigns, :size, fn -> "medium" end)

    ~H"""
    <div class={poster_container_class(@size)}>
      <%= if poster_url(@media, @media_type) do %>
        <div class="relative group">
          <img
            src={poster_url(@media, @media_type)}
            alt={media_title(@media, @media_type)}
            class="w-full h-full object-cover rounded-lg shadow-xl transition-transform duration-300 group-hover:scale-105"
            loading="lazy"
          />

          <!-- Hover overlay with rating if available -->
          <%= if @media.average_rating do %>
            <div class="absolute inset-0 bg-black/60 opacity-0 group-hover:opacity-100 transition-opacity duration-300 rounded-lg flex items-center justify-center">
              <div class="text-center">
                <div class="text-2xl font-bold text-warning mb-1">
                  <%= format_average_rating(@media.average_rating) %>
                </div>
                <div class="text-xs text-base-100">
                  <%= @rating_count || 0 %> ratings
                </div>
              </div>
            </div>
          <% end %>
        </div>
      <% else %>
        <!-- Enhanced placeholder for missing poster -->
        <div class="w-full h-full bg-gradient-to-br from-base-300 to-base-200 rounded-lg shadow-xl flex items-center justify-center border-2 border-dashed border-base-content/20">
          <div class="text-center p-4">
            <div class="text-4xl mb-2 opacity-60">
              <%= media_icon(@media_type) %>
            </div>
            <div class="text-sm font-medium text-base-content/70 leading-tight">
              <%= media_title(@media, @media_type) %>
            </div>
            <div class="text-xs text-base-content/50 mt-1">
              No Image
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  # Size configurations with responsive design
  defp poster_container_class("small"), do: "w-16 h-24 flex-shrink-0"
  defp poster_container_class("medium"), do: "w-32 h-48 md:w-36 md:h-54 flex-shrink-0"
  defp poster_container_class("large"), do: "w-48 h-72 md:w-60 md:h-90 lg:w-64 lg:h-96 flex-shrink-0"

  defp poster_url(media, media_type) do
    case media_type do
      "movie" ->
        if media.poster_path, do: "https://image.tmdb.org/t/p/#{tmdb_poster_size(media_type)}#{media.poster_path}"

      "tv_show" ->
        if media.poster_path, do: "https://image.tmdb.org/t/p/#{tmdb_poster_size(media_type)}#{media.poster_path}"

      "album" ->
        # Spotify API returns full image URLs directly in the images array
        # Format: https://i.scdn.co/image/ab67616d00001e02...
        media.poster_path

      "game" ->
        # RAWG API provides full image URLs directly
        media.poster_path
    end
  end

  defp tmdb_poster_size("small"), do: "w185"
  defp tmdb_poster_size(_), do: "w500"

  defp media_title(media, "movie"), do: media.title
  defp media_title(media, _), do: media.name

  defp media_icon("movie"), do: "🎬"
  defp media_icon("album"), do: "🎵"
  defp media_icon("game"), do: "🎮"
  defp media_icon("tv_show"), do: "📺"

  defp format_average_rating(rating) when is_number(rating) do
    :erlang.float_to_binary(rating, decimals: 1)
  end
  defp format_average_rating(_), do: "—"
end

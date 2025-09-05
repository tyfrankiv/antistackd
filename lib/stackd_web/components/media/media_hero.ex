defmodule StackdWeb.Media.Components.MediaHero do
  use StackdWeb, :live_component

  alias StackdWeb.Media.Components.{MediaPoster, MediaInfo}

  @impl true
  def render(assigns) do
    ~H"""
    <div class="relative h-96 md:h-[500px] overflow-hidden">
      <!-- Backdrop Image -->
      <div class="absolute inset-0">
        <%= if backdrop_url(@media, @media_type) do %>
          <img
            src={backdrop_url(@media, @media_type)}
            alt=""
            class="w-full h-full object-cover"
            loading="lazy"
          />
        <% else %>
          <!-- Dynamic gradient fallback based on media type -->
          <div class={["w-full h-full", gradient_class(@media_type)]}></div>
        <% end %>
      </div>

      <!-- Dark overlay for text readability -->
      <div class="absolute inset-0 bg-gradient-to-t from-base-100 via-base-100/50 to-transparent"></div>

      <!-- Content -->
      <div class="relative h-full max-w-7xl mx-auto px-4 flex items-end pb-8">
        <div class="flex flex-col md:flex-row gap-6 w-full">
          <!-- Poster -->
          <div class="flex-shrink-0">
            <.live_component
              module={MediaPoster}
              id="hero-poster"
              media={@media}
              media_type={@media_type}
              size="large"
            />
          </div>

          <!-- Media Info with Average Rating -->
          <div class="flex-1 min-w-0 space-y-4">
            <!-- Title and Year -->
            <div>
              <h1 class="text-3xl md:text-5xl font-bold text-base-content mb-2">
                <%= media_title(@media, @media_type) %>
              </h1>
              <div class="text-lg text-base-content/70 mb-4">
                <%= media_year(@media, @media_type) %>
              </div>
            </div>

            <!-- Average Rating Display -->
            <%= if @media.average_rating do %>
              <div class="flex items-center gap-4 mb-4">
                <div class="stats stats-horizontal shadow-lg bg-base-200/80">
                  <div class="stat place-items-center">
                    <div class="stat-value text-2xl text-warning">
                      <%= format_average_rating(@media.average_rating) %>
                    </div>
                    <div class="stat-desc">Average Rating</div>
                    <div class="rating rating-sm">
                      <%= render_stars_display(@media.average_rating) %>
                    </div>
                  </div>
                </div>

                <!-- Rating Count Badge -->
                <div class="badge badge-lg badge-neutral">
                  <%= @rating_count || 0 %> ratings
                </div>
              </div>
            <% end %>

            <!-- Genres -->
            <div class="flex flex-wrap gap-2 mb-4" :if={@media.genres && length(@media.genres) > 0}>
              <div
                :for={genre <- Enum.take(@media.genres, 4)}
                class="badge badge-primary badge-lg"
              >
                <%= genre %>
              </div>
            </div>

            <!-- Overview/Description -->
            <div class="prose prose-sm text-base-content/90 max-w-3xl" :if={description(@media, @media_type)}>
              <p><%= String.slice(description(@media, @media_type), 0, 200) %><%= if String.length(description(@media, @media_type)) > 200, do: "..." %></p>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp backdrop_url(media, media_type) do
    case media_type do
      "movie" ->
        if media.backdrop_path, do: "https://image.tmdb.org/t/p/w1280#{media.backdrop_path}"

      "tv_show" ->
        if media.backdrop_path, do: "https://image.tmdb.org/t/p/w1280#{media.backdrop_path}"

      "album" ->
        media.backdrop_path

      "game" ->
        media.backdrop_path
    end
  end

  defp gradient_class("movie"), do: "bg-gradient-to-br from-red-900/30 via-purple-900/20 to-blue-900/30"
  defp gradient_class("tv_show"), do: "bg-gradient-to-br from-blue-900/30 via-indigo-900/20 to-purple-900/30"
  defp gradient_class("album"), do: "bg-gradient-to-br from-pink-900/30 via-violet-900/20 to-indigo-900/30"
  defp gradient_class("game"), do: "bg-gradient-to-br from-green-900/30 via-cyan-900/20 to-blue-900/30"

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
      "album" -> nil # Albums typically don't have descriptions
    end
  end

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

defmodule StackdWeb.Media.Components.MediaHero do
  use StackdWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="hero min-h-96 bg-gradient-to-r from-primary/20 to-secondary/20">
      <div class="hero-content flex-col lg:flex-row max-w-6xl mx-auto">
        <img
          src={@media.poster_path || "/images/no-poster.jpg"}
          class={[
            "rounded-lg shadow-2xl",
            if(@media_type == :album, do: "max-w-xs aspect-square object-cover", else: "max-w-sm")
          ]}
          alt={"#{get_title(@media)} poster"}
        />
        <div class="lg:ml-8">
          <h1 class="text-5xl font-bold"><%= get_title(@media) %></h1>
          <p class="py-2 text-lg opacity-75">
            <%= get_subtitle(@media, @media_type) %>
          </p>
          <p class="py-4 max-w-2xl">
            <%= get_description(@media) %>
          </p>

          <!-- Stats Row -->
          <div class="flex gap-6 my-4">
            <div class="text-center">
              <div class="text-2xl font-bold text-primary"><%= @stats.average_rating %></div>
              <div class="text-sm opacity-75">Average Rating</div>
            </div>
            <div class="text-center">
              <div class="text-2xl font-bold text-secondary"><%= @stats.total_logs %></div>
              <div class="text-sm opacity-75"><%= get_log_label(@media_type) %></div>
            </div>
            <div class="text-center">
              <div class="text-2xl font-bold text-accent"><%= @stats.total_reviews %></div>
              <div class="text-sm opacity-75">Reviews</div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # Helper functions to handle different media types
  defp get_title(media) do
    media.title || media.name || "Unknown Title"
  end

  defp get_subtitle(media, media_type) do
    case media_type do
      :movie -> "#{media.release_date} • #{media.runtime} min"
      :tv_show -> "#{media.first_air_date} • #{media.number_of_seasons} seasons"
      :game -> "#{media.release_date} • #{media.platforms}"
      :album -> "#{media.release_date} • #{media.artist_name}"
    end
  end

  defp get_description(media) do
    media.overview || media.description || media.summary || "No description available."
  end

  defp get_log_label(media_type) do
    case media_type do
      :movie -> "Watched"
      :tv_show -> "Watched"
      :game -> "Played"
      :album -> "Listened"
    end
  end
end

defmodule StackdWeb.Media.Components.MediaBackdrop do
  use StackdWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="relative">
      <!-- Backdrop Image -->
      <%= if backdrop_url(@media, @media_type) do %>
        <div class="absolute inset-0 bg-gradient-to-t from-base-100 via-transparent to-transparent z-10">
        </div>
        <img
          src={backdrop_url(@media, @media_type)}
          alt=""
          class="w-full h-96 object-cover opacity-30"
          loading="lazy"
        />
      <% else %>
        <!-- Fallback gradient when no backdrop available -->
        <div class="w-full h-96 bg-gradient-to-br from-primary/20 via-secondary/10 to-base-300"></div>
      <% end %>

      <!-- Content Overlay -->
      <div class="relative z-20 container mx-auto px-4 py-8">
        <div class="flex flex-col lg:flex-row gap-8 items-start">
          <%= render_slot(@inner_block) %>
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
        # Albums typically don't have backdrop images, might use artist photo if available
        media.backdrop_path

      "game" ->
        # RAWG API provides screenshot URLs directly
        media.backdrop_path
    end
  end
end

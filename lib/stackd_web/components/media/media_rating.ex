defmodule StackdWeb.Media.Components.MediaRating do
  use StackdWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="card bg-base-200 shadow-xl">
      <div class="card-body">
        <div class="flex flex-col lg:flex-row lg:items-center justify-between gap-6">
          <!-- Community Average Rating -->
          <div class="text-center lg:text-left">
            <h3 class="card-title text-base-content/70 text-sm mb-2">Community Rating</h3>

            <%= if @media.average_rating do %>
              <div class="flex items-center justify-center lg:justify-start gap-4">
                <div class="stat">
                  <div class="stat-value text-4xl text-warning">
                    <%= format_average_rating(@media.average_rating) %>
                  </div>
                  <div class="stat-desc">out of 10</div>
                </div>

                <div class="flex flex-col items-center">
                  <div class="rating rating-md mb-1">
                    <%= render_stars_display(@media.average_rating) %>
                  </div>
                  <div class="text-sm text-base-content/60">
                    <%= @rating_count || 0 %> <%= if (@rating_count || 0) == 1, do: "rating", else: "ratings" %>
                  </div>
                </div>
              </div>
            <% else %>
              <div class="text-center lg:text-left">
                <div class="text-2xl text-base-content/40 mb-2">No ratings yet</div>
                <div class="text-sm text-base-content/60">Be the first to rate!</div>
              </div>
            <% end %>
          </div>

          <!-- Divider -->
          <div class="divider lg:divider-horizontal"></div>

          <!-- User's Personal Rating -->
          <div class="text-center lg:text-right">
            <h3 class="card-title text-base-content/70 text-sm mb-2">Your Rating</h3>

            <%= if @current_user do %>
              <%= if @user_rating do %>
                <!-- User has rated -->
                <div class="flex flex-col items-center lg:items-end gap-2">
                  <div class="flex items-center gap-3">
                    <div class="text-3xl font-bold text-secondary">
                      <%= @user_rating %>
                    </div>
                    <div class="rating rating-md">
                      <%= render_user_stars(@user_rating) %>
                    </div>
                  </div>

                  <div class="flex gap-2">
                    <button
                      type="button"
                      phx-click="edit_rating"
                      phx-target={@myself}
                      class="btn btn-xs btn-outline btn-secondary"
                    >
                      Edit
                    </button>
                    <button
                      type="button"
                      phx-click="remove_rating"
                      phx-target={@myself}
                      class="btn btn-xs btn-outline btn-error"
                    >
                      Remove
                    </button>
                  </div>
                </div>
              <% else %>
                <!-- User hasn't rated -->
                <div class="space-y-3">
                  <div class="text-base-content/60 mb-3">Rate this <%= @media_type %></div>

                  <div class="flex justify-center lg:justify-end">
                    <div class="rating rating-lg gap-1">
                      <button
                        :for={i <- 1..10}
                        type="button"
                        phx-click="quick_rate"
                        phx-value-rating={i}
                        phx-target={@myself}
                        class="mask mask-star-2 bg-base-content/20 hover:bg-warning transition-colors duration-200"
                        title={"Rate #{i}/10"}
                      >
                      </button>
                    </div>
                  </div>

                  <div class="text-xs text-base-content/60">Click stars to rate</div>
                </div>
              <% end %>
            <% else %>
              <!-- Not signed in -->
              <div class="text-center lg:text-right">
                <div class="text-base-content/60 mb-3">Sign in to rate</div>
                <a href="/auth/sign-in" class="btn btn-primary btn-sm">
                  Sign In
                </a>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("quick_rate", %{"rating" => rating_str}, socket) do
    rating = String.to_integer(rating_str)

    # Send rating to parent LiveView
    send(self(), {:rate_media, rating})
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit_rating", _params, socket) do
    send(self(), :show_rating_modal)
    {:noreply, socket}
  end

  @impl true
  def handle_event("remove_rating", _params, socket) do
    send(self(), :remove_rating)
    {:noreply, socket}
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
end

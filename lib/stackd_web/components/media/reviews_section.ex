defmodule StackdWeb.Media.Components.ReviewsSection do
  use StackdWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <div class="card bg-base-200 shadow-xl">
        <div class="card-body">
          <!-- Header with Review Count -->
          <div class="flex items-center justify-between mb-6">
            <h2 class="card-title text-2xl">
              Reviews
              <%= if @total_reviews && @total_reviews > 0 do %>
                <div class="badge badge-primary badge-lg">
                  <%= @total_reviews %>
                </div>
              <% end %>
            </h2>

            <%= if @current_user && !@user_has_review do %>
              <button
                type="button"
                phx-click="show_review_modal"
                class="btn btn-primary btn-sm"
              >
                <span class="mr-1">✍️</span>
                Write Review
              </button>
            <% end %>
          </div>

          <!-- Tab Navigation -->
          <div class="tabs tabs-bordered mb-6">
            <button
              class={["tab tab-lg", if(@active_tab == "recent", do: "tab-active")]}
              phx-click="switch_tab"
              phx-value-tab="recent"
              phx-target={@myself}
            >
              <span class="mr-2">🕒</span>
              Recent Reviews
            </button>
            <button
              class={["tab tab-lg", if(@active_tab == "top", do: "tab-active")]}
              phx-click="switch_tab"
              phx-value-tab="top"
              phx-target={@myself}
            >
              <span class="mr-2">⭐</span>
              Top Reviews
            </button>
            <%= if @current_user do %>
              <button
                class={["tab tab-lg", if(@active_tab == "following", do: "tab-active")]}
                phx-click="switch_tab"
                phx-value-tab="following"
                phx-target={@myself}
              >
                <span class="mr-2">👥</span>
                Following
              </button>
            <% end %>
          </div>

          <!-- Review List -->
          <div class="space-y-6" id="reviews-list" phx-update="stream">
            <%= for review <- get_reviews_for_tab(@active_tab, assigns) do %>
              <div class="card bg-base-100 shadow-sm hover:shadow-md transition-shadow" id={"review-#{review.id}"}>
                <div class="card-body">
                  <div class="flex items-start gap-4">
                    <!-- User Avatar -->
                    <div class="avatar placeholder flex-shrink-0">
                      <div class="bg-primary text-primary-content rounded-full w-12 h-12">
                        <span class="text-lg font-semibold">
                          <%= String.first(review.user.username || "U") %>
                        </span>
                      </div>
                    </div>

                    <div class="flex-1 min-w-0">
                      <!-- Header with user info, rating, and meta -->
                      <div class="flex items-center flex-wrap gap-2 mb-3">
                        <span class="font-semibold text-base-content">
                          <%= review.user.username %>
                        </span>

                        <%= if review.rating do %>
                          <div class="flex items-center gap-1">
                            <div class="rating rating-sm">
                              <%= render_review_stars(review.rating) %>
                            </div>
                            <span class="badge badge-warning badge-sm font-medium">
                              <%= review.rating %>/10
                            </span>
                          </div>
                        <% end %>

                        <%= if review.spoiler do %>
                          <div class="badge badge-error badge-sm">
                            <span class="mr-1">⚠️</span>
                            Spoiler
                          </div>
                        <% end %>

                        <div class="flex items-center gap-1 text-sm text-base-content/60 ml-auto">
                          <span>🕒</span>
                          <%= format_review_date(review.created_at) %>
                        </div>
                      </div>

                      <!-- Review content with spoiler handling -->
                      <%= if review.spoiler && !Map.get(@revealed_spoilers || MapSet.new(), review.id) do %>
                        <div class="alert alert-warning">
                          <div class="flex items-center justify-between w-full">
                            <div class="flex items-center gap-2">
                              <span>⚠️</span>
                              <span>This review contains spoilers</span>
                            </div>
                            <button
                              class="btn btn-xs btn-outline"
                              phx-click="reveal_spoiler"
                              phx-value-review_id={review.id}
                              phx-target={@myself}
                            >
                              Show Review
                            </button>
                          </div>
                        </div>
                      <% else %>
                        <!-- Full review content -->
                        <div class="prose prose-sm max-w-none text-base-content/90">
                          <%= if String.length(review.content) > 400 && !Map.get(@expanded_reviews || %{}, review.id) do %>
                            <div class="space-y-3">
                              <p><%= String.slice(review.content, 0, 400) %>...</p>
                              <button
                                class="btn btn-sm btn-outline btn-primary"
                                phx-click="toggle_review"
                                phx-value-review_id={review.id}
                                phx-target={@myself}
                              >
                                Read More
                              </button>
                            </div>
                          <% else %>
                            <div class="space-y-3">
                              <p><%= review.content %></p>
                              <%= if String.length(review.content) > 400 do %>
                                <button
                                  class="btn btn-sm btn-outline btn-ghost"
                                  phx-click="toggle_review"
                                  phx-value-review_id={review.id}
                                  phx-target={@myself}
                                >
                                  Show Less
                                </button>
                              <% end %>
                            </div>
                          <% end %>
                        </div>

                        <!-- Review Actions -->
                        <div class="flex items-center justify-between mt-4 pt-3 border-t border-base-content/10">
                          <div class="flex items-center gap-4">
                            <!-- Like/Helpful button (future feature) -->
                            <button class="btn btn-xs btn-ghost opacity-50" disabled>
                              <span class="mr-1">👍</span>
                              Helpful (<%= review.helpful_count || 0 %>)
                            </button>

                            <!-- Reply button (future feature) -->
                            <button class="btn btn-xs btn-ghost opacity-50" disabled>
                              <span class="mr-1">💬</span>
                              Reply
                            </button>
                          </div>

                          <!-- User's own review actions -->
                          <%= if @current_user && review.user.id == @current_user.id do %>
                            <div class="flex gap-2">
                              <button
                                class="btn btn-xs btn-outline"
                                phx-click="edit_review"
                                phx-value-review_id={review.id}
                              >
                                Edit
                              </button>
                              <button
                                class="btn btn-xs btn-outline btn-error"
                                phx-click="delete_review"
                                phx-value-review_id={review.id}
                                data-confirm="Are you sure you want to delete this review?"
                              >
                                Delete
                              </button>
                            </div>
                          <% end %>
                        </div>
                      <% end %>
                    </div>
                  </div>
                </div>
              </div>
            <% end %>
          </div>

          <!-- Empty State -->
          <%= if reviews_empty?(get_reviews_for_tab(@active_tab, assigns)) do %>
            <div class="text-center py-16">
              <div class="text-6xl mb-4 opacity-40">
                <%= empty_state_icon(@active_tab) %>
              </div>
              <h3 class="text-xl font-semibold mb-2 text-base-content/70">
                <%= empty_state_title(@active_tab) %>
              </h3>
              <p class="text-base-content/60 mb-6">
                <%= empty_state_description(@active_tab, @media_type) %>
              </p>
              <%= if @current_user && @active_tab != "following" do %>
                <button
                  type="button"
                  phx-click="show_review_modal"
                  class="btn btn-primary"
                >
                  Write the First Review
                </button>
              <% end %>
            </div>
          <% end %>

          <!-- Load More Button -->
          <%= if show_load_more?(get_reviews_for_tab(@active_tab, assigns), @active_tab) do %>
            <div class="text-center pt-6">
              <button
                class="btn btn-outline btn-wide"
                phx-click="load_more_reviews"
                phx-value-tab={@active_tab}
                phx-target={@myself}
              >
                Load More Reviews
              </button>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("switch_tab", %{"tab" => tab}, socket) do
    send(self(), {:switch_reviews_tab, tab})
    {:noreply, assign(socket, :active_tab, tab)}
  end

  @impl true
  def handle_event("toggle_review", %{"review_id" => review_id}, socket) do
    send(self(), {:toggle_review, review_id})
    {:noreply, socket}
  end

  @impl true
  def handle_event("reveal_spoiler", %{"review_id" => review_id}, socket) do
    send(self(), {:reveal_spoiler, review_id})
    {:noreply, socket}
  end

  @impl true
  def handle_event("load_more_reviews", %{"tab" => tab}, socket) do
    send(self(), {:load_more_reviews, tab})
    {:noreply, socket}
  end

  defp get_reviews_for_tab("recent", assigns), do: assigns[:recent_reviews] || []
  defp get_reviews_for_tab("top", assigns), do: assigns[:top_reviews] || []
  defp get_reviews_for_tab("following", assigns), do: assigns[:following_reviews] || []

  defp reviews_empty?(reviews) when is_list(reviews), do: length(reviews) == 0
  defp reviews_empty?(_), do: true

  defp show_load_more?(reviews, _tab) when is_list(reviews), do: length(reviews) >= 10
  defp show_load_more?(_, _), do: false

  defp empty_state_icon("recent"), do: "🕒"
  defp empty_state_icon("top"), do: "⭐"
  defp empty_state_icon("following"), do: "👥"

  defp empty_state_title("recent"), do: "No Recent Reviews"
  defp empty_state_title("top"), do: "No Top Reviews"
  defp empty_state_title("following"), do: "No Reviews from Following"

  defp empty_state_description("recent", media_type), do: "Be the first to review this #{media_type}!"
  defp empty_state_description("top", media_type), do: "No highly-rated reviews for this #{media_type} yet."
  defp empty_state_description("following", _), do: "Follow other users to see their reviews here."

  defp render_review_stars(rating) when is_integer(rating) do
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

  defp render_review_stars(_), do: ""

  defp format_review_date(%DateTime{} = datetime) do
    now = DateTime.utc_now()
    diff_seconds = DateTime.diff(now, datetime, :second)

    cond do
      diff_seconds < 60 -> "just now"
      diff_seconds < 3600 -> "#{div(diff_seconds, 60)}m ago"
      diff_seconds < 86400 -> "#{div(diff_seconds, 3600)}h ago"
      diff_seconds < 604800 -> "#{div(diff_seconds, 86400)}d ago"
      true -> Calendar.strftime(datetime, "%b %d, %Y")
    end
  end

  defp format_review_date(_), do: ""
end

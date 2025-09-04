defmodule StackdWeb.Media.Components.ReviewsSection do
  use StackdWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h2 class="text-2xl font-bold mb-4">Recent Reviews</h2>

      <%= if @recent_reviews == [] do %>
        <div class="text-center py-8 opacity-75">
          <p>No reviews yet. Be the first to review this <%= @media_type %>!</p>
        </div>
      <% else %>
        <div class="space-y-4">
          <%= for review <- @recent_reviews do %>
            <div class="card bg-base-200 shadow-sm">
              <div class="card-body">
                <div class="flex items-start justify-between">
                  <div class="flex items-center gap-3">
                    <div class="avatar">
                      <div class="w-10 h-10 rounded-full bg-primary text-primary-content flex items-center justify-center">
                        <%= String.first(review.user.username) %>
                      </div>
                    </div>
                    <div>
                      <h4 class="font-semibold">@<%= review.user.username %></h4>
                      <p class="text-sm opacity-75"><%= format_date(review.created_at) %></p>
                    </div>
                  </div>
                  <%= if review.rating do %>
                    <div class="badge badge-primary"><%= review.rating %>/10</div>
                  <% end %>
                </div>
                <p class="mt-3"><%= review.content %></p>

                <%= if review.log_attached do %>
                  <div class="text-xs opacity-60 mt-2">
                    📝 Attached to log from <%= format_date(review.log_date) %>
                  </div>
                <% end %>
              </div>
            </div>
          <% end %>
        </div>
      <% end %>
    </div>
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

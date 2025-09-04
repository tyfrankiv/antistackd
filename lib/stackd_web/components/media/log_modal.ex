defmodule StackdWeb.Media.Components.LogModal do
  use StackdWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <%= if @show do %>
      <div class="modal modal-open">
        <div class="modal-box">
          <h3 class="font-bold text-lg">Log <%= get_title(@media) %></h3>
          <p class="py-4">Track when you <%= get_activity_verb(@media_type) %> this <%= @media_type %>.</p>

          <form phx-submit="create_log" phx-target={@myself}>
            <div class="form-control">
              <label class="label">
                <span class="label-text">Date <%= get_activity_verb(@media_type) |> String.capitalize() %></span>
              </label>
              <input
                type="date"
                name="logged_date"
                class="input input-bordered"
                value={Date.utc_today()}
                required
              />
            </div>

            <div class="form-control">
              <label class="label">
                <span class="label-text">Rating (optional)</span>
              </label>
              <div class="rating">
                <%= for i <- 1..10 do %>
                  <input
                    type="radio"
                    name="rating"
                    value={i}
                    class="mask mask-star-2 bg-orange-400"
                  />
                <% end %>
              </div>
            </div>

            <div class="form-control">
              <label class="label">
                <span class="label-text">Notes (optional)</span>
              </label>
              <textarea
                name="notes"
                class="textarea textarea-bordered"
                placeholder={"Your thoughts about this #{@media_type}..."}
              ></textarea>
            </div>

            <div class="form-control">
              <label class="cursor-pointer label">
                <span class="label-text"><%= get_rewatch_label(@media_type) %>?</span>
                <input type="checkbox" name={get_rewatch_field(@media_type)} class="checkbox" />
              </label>
            </div>

            <div class="modal-action">
              <button type="button" class="btn" phx-click="hide_log_modal" phx-target={@myself}>Cancel</button>
              <button type="submit" class="btn btn-primary">Save Log</button>
            </div>
          </form>
        </div>
      </div>
    <% end %>
    """
  end

  @impl true
  def handle_event("create_log", log_params, socket) do
    send(self(), {:create_log, log_params})
    {:noreply, socket}
  end

  @impl true
  def handle_event("hide_log_modal", _params, socket) do
    send(self(), {:hide_log_modal})
    {:noreply, socket}
  end

  defp get_title(media) do
    media.title || media.name || "Unknown Title"
  end

  defp get_activity_verb(media_type) do
    case media_type do
      :movie -> "watched"
      :tv_show -> "watched"
      :game -> "played"
      :album -> "listened to"
    end
  end

  defp get_rewatch_label(media_type) do
    case media_type do
      :movie -> "Rewatch"
      :tv_show -> "Rewatch"
      :game -> "Replay"
      :album -> "Relisten"
    end
  end

  defp get_rewatch_field(media_type) do
    case media_type do
      :movie -> "is_rewatch"
      :tv_show -> "is_rewatch"
      :game -> "is_replay"
      :album -> "is_relisten"
    end
  end
end

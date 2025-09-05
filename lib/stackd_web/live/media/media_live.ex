defmodule StackdWeb.Media.MediaLive do
  use StackdWeb, :live_view

  alias StackdWeb.Media.Components.{
    MediaHero,
    MediaInfo,
    MediaRating,
    MediaStats,
    ReviewsSection,
    UserActions,
    UserSidebar
  }
  alias StackdWeb.Components.Media.MediaInteractionForm

  @impl true
  def mount(params, _session, socket) do
    %{"type" => media_type, "id" => media_id} = params

    case load_media_data(media_type, media_id, socket.assigns.current_user) do
      {:ok, data} ->
        socket =
          socket
          |> assign(:media_type, media_type)
          |> assign(:media, data.media)
          |> assign(:rating_count, data.rating_count)
          |> assign(:user_rating, data.user_rating)
          |> assign(:user_stats, data.user_stats)
          |> assign(:user_logs, data.user_logs)
          |> assign(:user_has_review, data.user_has_review)
          |> assign(:recent_reviews, data.recent_reviews)
          |> assign(:top_reviews, data.top_reviews)
          |> assign(:following_reviews, data.following_reviews)
          |> assign(:total_reviews, data.total_reviews)
          |> assign(:active_reviews_tab, "recent")
          |> assign(:show_interaction_modal, false)
          |> assign(:show_rating_modal, false)
          |> assign(:show_review_modal, false)
          |> assign(:expanded_reviews, %{})
          |> assign(:revealed_spoilers, MapSet.new())
          |> assign(:page_title, page_title(data.media, media_type))

        {:ok, socket}

      {:error, :not_found} ->
        {:ok,
         socket
         |> put_flash(:error, "#{String.capitalize(media_type)} not found")
         |> redirect(to: ~p"/dashboard")}

      {:error, error} ->
        {:ok,
         socket
         |> put_flash(:error, "Error loading #{media_type}: #{inspect(error)}")
         |> redirect(to: ~p"/dashboard")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-base-100">
      <!-- Hero Section -->
      <.live_component
        module={MediaHero}
        id="media-hero"
        media={@media}
        media_type={@media_type}
        rating_count={@rating_count}
      />

      <!-- Main Content -->
      <div class="max-w-7xl mx-auto px-4 py-8">
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <!-- Main Content Column -->
          <div class="lg:col-span-2 space-y-8">
            <!-- Rating Section -->
            <.live_component
              module={MediaRating}
              id="media-rating"
              media={@media}
              media_type={@media_type}
              rating_count={@rating_count}
              user_rating={@user_rating}
              current_user={@current_user}
            />

            <!-- User Actions -->
            <.live_component
              module={UserActions}
              id="user-actions"
              media={@media}
              media_type={@media_type}
              user_stats={@user_stats}
              current_user={@current_user}
            />

            <!-- Media Info (detailed) -->
            <.live_component
              module={MediaInfo}
              id="media-info"
              media={@media}
              media_type={@media_type}
            />

            <!-- Reviews Section -->
            <.live_component
              module={ReviewsSection}
              id="reviews-section"
              media={@media}
              media_type={@media_type}
              current_user={@current_user}
              user_has_review={@user_has_review}
              recent_reviews={@recent_reviews}
              top_reviews={@top_reviews}
              following_reviews={@following_reviews}
              total_reviews={@total_reviews}
              active_tab={@active_reviews_tab}
              expanded_reviews={@expanded_reviews}
              revealed_spoilers={@revealed_spoilers}
            />
          </div>

          <!-- Sidebar -->
          <div class="lg:col-span-1">
            <.live_component
              module={UserSidebar}
              id="user-sidebar"
              media={@media}
              media_type={@media_type}
              current_user={@current_user}
              user_logs={@user_logs}
              rating_count={@rating_count}
            />

            <!-- Stats Component -->
            <div class="mt-6">
              <.live_component
                module={MediaStats}
                id="media-stats"
                media={@media}
                media_type={@media_type}
                user_stats={@user_stats}
                rating_count={@rating_count}
              />
            </div>
          </div>
        </div>
      </div>

      <!-- Modals -->
      <%= if @show_interaction_modal do %>
        <div class="modal modal-open">
          <div class="modal-box max-w-2xl">
            <.live_component
              module={MediaInteractionForm}
              id="interaction-form"
              media={@media}
              media_type={@media_type}
              current_user={@current_user}
            />
          </div>
          <div class="modal-backdrop" phx-click="hide_interaction_modal"></div>
        </div>
      <% end %>

      <%= if @show_rating_modal do %>
        <div class="modal modal-open">
          <div class="modal-box">
            <div class="p-6">
              <h3 class="font-bold text-lg mb-4">
                Rate "<%= media_title(@media, @media_type) %>"
              </h3>

              <div class="text-center mb-6">
                <div class="rating rating-lg gap-2 justify-center">
                  <button
                    :for={i <- 1..10}
                    type="button"
                    phx-click="rate_media"
                    phx-value-rating={i}
                    class="mask mask-star-2 bg-base-content/20 hover:bg-warning transition-colors duration-200"
                    title={"Rate #{i}/10"}
                  >
                  </button>
                </div>
                <div class="text-sm text-base-content/60 mt-2">
                  Click stars to rate (1-10)
                </div>
              </div>

              <div class="modal-action">
                <button class="btn btn-ghost" phx-click="hide_rating_modal">
                  Cancel
                </button>
              </div>
            </div>
          </div>
          <div class="modal-backdrop" phx-click="hide_rating_modal"></div>
        </div>
      <% end %>

      <%= if @show_review_modal do %>
        <div class="modal modal-open">
          <div class="modal-box max-w-3xl">
            <div class="p-6">
              <h3 class="font-bold text-lg mb-4">
                Write a Review for "<%= media_title(@media, @media_type) %>"
              </h3>

              <form phx-submit="submit_review">
                <div class="form-control mb-4">
                  <label class="label">
                    <span class="label-text">Your Review</span>
                  </label>
                  <textarea
                    name="content"
                    rows="8"
                    placeholder="Share your thoughts about this #{@media_type}..."
                    class="textarea textarea-bordered resize-none"
                    required
                  ></textarea>
                </div>

                <div class="form-control mb-4">
                  <label class="label">
                    <span class="label-text">Rating (optional)</span>
                  </label>
                  <select name="rating" class="select select-bordered">
                    <option value="">No rating</option>
                    <option :for={i <- 1..10} value={i}><%= i %>/10</option>
                  </select>
                </div>

                <div class="form-control mb-6">
                  <label class="flex items-center space-x-3 cursor-pointer">
                    <input
                      type="checkbox"
                      name="spoiler"
                      value="true"
                      class="checkbox checkbox-error"
                    />
                    <span class="label-text">Contains spoilers</span>
                  </label>
                </div>

                <div class="modal-action">
                  <button type="button" class="btn btn-ghost" phx-click="hide_review_modal">
                    Cancel
                  </button>
                  <button type="submit" class="btn btn-primary">
                    Publish Review
                  </button>
                </div>
              </form>
            </div>
          </div>
          <div class="modal-backdrop" phx-click="hide_review_modal"></div>
        </div>
      <% end %>
    </div>
    """
  end

  # Handle messages from child components
  @impl true
  def handle_info({:rate_media, rating}, socket) do
    case create_or_update_rating(socket.assigns.media, socket.assigns.media_type, rating, socket.assigns.current_user) do
      {:ok, _rating} ->
        {:noreply,
         socket
         |> put_flash(:info, "Rating saved!")
         |> assign(:user_rating, rating)
         |> refresh_media_data()}

      {:error, error} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to save rating: #{inspect(error)}")}
    end
  end

  def handle_info(:remove_rating, socket) do
    case remove_user_rating(socket.assigns.media, socket.assigns.media_type, socket.assigns.current_user) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Rating removed")
         |> assign(:user_rating, nil)
         |> refresh_media_data()}

      {:error, error} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to remove rating: #{inspect(error)}")}
    end
  end

  def handle_info(:show_rating_modal, socket) do
    {:noreply, assign(socket, :show_rating_modal, true)}
  end

  def handle_info(:share_media, socket) do
    # Copy URL to clipboard (handled by JavaScript)
    {:noreply,
     socket
     |> put_flash(:info, "Share link copied to clipboard!")
     |> push_event("copy_to_clipboard", %{text: get_media_url(socket)})}
  end

  def handle_info({:interaction_saved, _result}, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "Entry saved successfully!")
     |> assign(:show_interaction_modal, false)
     |> refresh_media_data()}
  end

  def handle_info({:switch_reviews_tab, tab}, socket) do
    {:noreply, assign(socket, :active_reviews_tab, tab)}
  end

  def handle_info({:toggle_review, review_id}, socket) do
    review_id_int = String.to_integer(review_id)
    expanded_reviews =
      if Map.get(socket.assigns.expanded_reviews, review_id_int),
        do: Map.delete(socket.assigns.expanded_reviews, review_id_int),
        else: Map.put(socket.assigns.expanded_reviews, review_id_int, true)

    {:noreply, assign(socket, :expanded_reviews, expanded_reviews)}
  end

  def handle_info({:reveal_spoiler, review_id}, socket) do
    review_id_int = String.to_integer(review_id)
    revealed_spoilers = MapSet.put(socket.assigns.revealed_spoilers, review_id_int)
    {:noreply, assign(socket, :revealed_spoilers, revealed_spoilers)}
  end

  def handle_info({:load_more_reviews, tab}, socket) do
    # Implement pagination for reviews
    {:noreply, socket}
  end

  # Handle direct events
  @impl true
  def handle_event("show_interaction_modal", _params, socket) do
    {:noreply, assign(socket, :show_interaction_modal, true)}
  end

  def handle_event("hide_interaction_modal", _params, socket) do
    {:noreply, assign(socket, :show_interaction_modal, false)}
  end

  def handle_event("hide_rating_modal", _params, socket) do
    {:noreply, assign(socket, :show_rating_modal, false)}
  end

  def handle_event("show_review_modal", _params, socket) do
    {:noreply, assign(socket, :show_review_modal, true)}
  end

  def handle_event("hide_review_modal", _params, socket) do
    {:noreply, assign(socket, :show_review_modal, false)}
  end

  def handle_event("rate_media", %{"rating" => rating_str}, socket) do
    rating = String.to_integer(rating_str)
    send(self(), {:rate_media, rating})
    {:noreply, assign(socket, :show_rating_modal, false)}
  end

  def handle_event("submit_review", params, socket) do
    review_attrs = %{
      "#{socket.assigns.media_type}_id" => socket.assigns.media.id,
      "content" => params["content"],
      "rating" => if(params["rating"] != "", do: String.to_integer(params["rating"]), else: nil),
      "spoiler" => params["spoiler"] == "true"
    }

    case create_review(socket.assigns.media_type, review_attrs, socket.assigns.current_user) do
      {:ok, _review} ->
        {:noreply,
         socket
         |> put_flash(:info, "Review published!")
         |> assign(:show_review_modal, false)
         |> assign(:user_has_review, true)
         |> refresh_media_data()}

      {:error, error} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to save review: #{inspect(error)}")}
    end
  end

  # Helper functions
  defp load_media_data(media_type, media_id, current_user) do
    with {:ok, media} <- get_media(media_type, media_id),
         {:ok, rating_count} <- get_rating_count(media_type, media.id),
         {:ok, user_data} <- get_user_data(media_type, media.id, current_user),
         {:ok, review_data} <- get_review_data(media_type, media.id, current_user) do
      {:ok, %{
        media: media,
        rating_count: rating_count,
        user_rating: user_data.rating,
        user_stats: user_data.stats,
        user_logs: user_data.logs,
        user_has_review: user_data.has_review,
        recent_reviews: review_data.recent,
        top_reviews: review_data.top,
        following_reviews: review_data.following,
        total_reviews: review_data.total
      }}
    end
  end

  defp get_media("movie", id), do: Stackd.Media.Movie |> Ash.get(id)
  defp get_media("tv_show", id), do: Stackd.Media.TvShow |> Ash.get(id)
  defp get_media("album", id), do: Stackd.Media.Album |> Ash.get(id)
  defp get_media("game", id), do: Stackd.Media.Game |> Ash.get(id)

  defp get_rating_count(media_type, media_id) do
    rating_resource = get_rating_resource(media_type)
    count = rating_resource
    |> Ash.Query.filter(^ref(:"#{media_type}_id") == ^media_id)
    |> Ash.count!()
    {:ok, count}
  rescue
    error -> {:error, error}
  end

  defp get_user_data(_media_type, _media_id, nil), do: {:ok, %{rating: nil, stats: %{}, logs: [], has_review: false}}
  defp get_user_data(media_type, media_id, user) do
    # Get user's current rating
    rating_resource = get_rating_resource(media_type)
    user_rating = rating_resource
    |> Ash.Query.filter(^ref(:"#{media_type}_id") == ^media_id and user_id == ^user.id)
    |> Ash.read_one()
    |> case do
      {:ok, rating} -> if rating, do: rating.rating, else: nil
      {:error, _} -> nil
    end

    # Get user's logs
    log_resource = get_log_resource(media_type)
    user_logs = log_resource
    |> Ash.Query.filter(^ref(:"#{media_type}_id") == ^media_id and user_id == ^user.id)
    |> Ash.Query.sort(logged_date: :desc)
    |> Ash.read!()

    # Get user stats
    stats = %{
      rating: user_rating,
      log_count: length(user_logs),
      last_logged: List.first(user_logs)
    }

    # Check if user has review
    review_resource = get_review_resource(media_type)
    has_review = review_resource
    |> Ash.Query.filter(^ref(:"#{media_type}_id") == ^media_id and user_id == ^user.id)
    |> Ash.exists?()

    {:ok, %{rating: user_rating, stats: stats, logs: user_logs, has_review: has_review}}
  rescue
    error -> {:error, error}
  end

  defp get_review_data(media_type, media_id, current_user) do
    review_resource = get_review_resource(media_type)
    base_query = review_resource
    |> Ash.Query.filter(^ref(:"#{media_type}_id") == ^media_id)
    |> Ash.Query.load(:user)

    # Recent reviews
    recent_reviews = base_query
    |> Ash.Query.sort(created_at: :desc)
    |> Ash.Query.limit(10)
    |> Ash.read!()

    # Top reviews (by rating, then by creation date)
    top_reviews = base_query
    |> Ash.Query.filter(not is_nil(rating))
    |> Ash.Query.sort([rating: :desc, created_at: :desc])
    |> Ash.Query.limit(10)
    |> Ash.read!()

    # Following reviews (if user is logged in)
    following_reviews = if current_user do
      # This would need to be implemented with a following system
      []
    else
      []
    end

    # Total count
    total_reviews = review_resource
    |> Ash.Query.filter(^ref(:"#{media_type}_id") == ^media_id)
    |> Ash.count!()

    {:ok, %{
      recent: recent_reviews,
      top: top_reviews,
      following: following_reviews,
      total: total_reviews
    }}
  rescue
    error -> {:error, error}
  end

  defp create_or_update_rating(media, media_type, rating, user) do
    rating_resource = get_rating_resource(media_type)
    rating_resource
    |> Ash.Changeset.for_create(:create, %{
      "#{media_type}_id" => media.id,
      "rating" => rating
    })
    |> Ash.create(actor: user)
  end

  defp remove_user_rating(media, media_type, user) do
    rating_resource = get_rating_resource(media_type)
    rating_resource
    |> Ash.Query.filter(^ref(:"#{media_type}_id") == ^media.id and user_id == ^user.id)
    |> Ash.read_one!()
    |> case do
      {:ok, rating} when not is_nil(rating) ->
        Ash.destroy(rating, actor: user)
      _ ->
        {:ok, nil}
    end
  end

  defp create_review(media_type, attrs, user) do
    review_resource = get_review_resource(media_type)
    review_resource
    |> Ash.Changeset.for_create(:create, attrs)
    |> Ash.create(actor: user)
  end

  defp get_rating_resource("movie"), do: Stackd.Media.MovieRating
  defp get_rating_resource("tv_show"), do: Stackd.Media.TvShowRating
  defp get_rating_resource("album"), do: Stackd.Media.AlbumRating
  defp get_rating_resource("game"), do: Stackd.Media.GameRating

  defp get_log_resource("movie"), do: Stackd.Media.MovieLog
  defp get_log_resource("tv_show"), do: Stackd.Media.TvShowLog
  defp get_log_resource("album"), do: Stackd.Media.AlbumLog
  defp get_log_resource("game"), do: Stackd.Media.GameLog

  defp get_review_resource("movie"), do: Stackd.Media.MovieReview
  defp get_review_resource("tv_show"), do: Stackd.Media.TvShowReview
  defp get_review_resource("album"), do: Stackd.Media.AlbumReview
  defp get_review_resource("game"), do: Stackd.Media.GameReview

  defp refresh_media_data(socket) do
    case load_media_data(socket.assigns.media_type, socket.assigns.media.id, socket.assigns.current_user) do
      {:ok, data} ->
        socket
        |> assign(:media, data.media)
        |> assign(:rating_count, data.rating_count)
        |> assign(:user_rating, data.user_rating)
        |> assign(:user_stats, data.user_stats)
        |> assign(:user_logs, data.user_logs)
        |> assign(:user_has_review, data.user_has_review)

      {:error, _} ->
        socket
    end
  end

  defp media_title(media, "movie"), do: media.title
  defp media_title(media, _), do: media.name

  defp page_title(media, media_type) do
    "#{media_title(media, media_type)} - #{String.capitalize(media_type)}"
  end

  defp get_media_url(socket) do
    StackdWeb.Router.Helpers.live_url(
      socket,
      StackdWeb.Media.MediaLive,
      socket.assigns.media_type,
      socket.assigns.media.id
    )
  end
end

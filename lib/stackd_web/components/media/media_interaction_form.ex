defmodule StackdWeb.Components.Media.MediaInteractionForm do
  use StackdWeb, :live_component

  def mount(socket) do
    socket =
      socket
      |> assign(:form_data, %{
        "create_log" => "false",
        "logged_date" => Date.to_string(Date.utc_today()),
        "is_rewatch" => "false",
        "notes" => "",
        "review_content" => "",
        "spoiler" => "false",
        "rating" => nil,
        "review_rating" => nil
      })
      |> assign(:show_modal, true)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="p-6">
      <!-- Header -->
      <div class="flex items-center justify-between mb-6">
        <h3 class="text-lg font-semibold">
          Log Your Experience
        </h3>
        <button
          type="button"
          phx-click="hide_interaction_modal"
          class="btn btn-ghost btn-sm btn-circle"
        >
          ✕
        </button>
      </div>

      <!-- Media Info -->
      <div class="flex items-center space-x-4 mb-6 p-4 bg-base-200 rounded-lg">
        <div class="w-12 h-18 bg-base-300 rounded flex-shrink-0 flex items-center justify-center">
          <span class="text-2xl"><%= media_icon(@media_type) %></span>
        </div>
        <div>
          <div class="font-semibold text-base-content">
            <%= media_title(@media, @media_type) %>
          </div>
          <div class="text-sm text-base-content/70">
            <%= media_year(@media, @media_type) %>
          </div>
        </div>
      </div>

      <!-- Form -->
      <form phx-submit="submit_interaction" phx-target={@myself}>
        <!-- Log Section -->
        <div class="mb-6">
          <label class="flex items-center space-x-3 mb-4 cursor-pointer">
            <input
              type="checkbox"
              name="create_log"
              value="true"
              class="checkbox checkbox-primary"
              phx-click="toggle_log_section"
              phx-target={@myself}
            />
            <span class="font-medium">Create Log Entry</span>
          </label>

          <div id="log-section" class="space-y-4 pl-7" style="display: none;">
            <!-- Date -->
            <div class="form-control">
              <label class="label">
                <span class="label-text">Date</span>
              </label>
              <input
                type="date"
                name="logged_date"
                value={@form_data["logged_date"]}
                class="input input-bordered w-full"
              />
            </div>

            <!-- Rewatch/Relisten Toggle -->
            <label class="flex items-center space-x-3 cursor-pointer">
              <input
                type="checkbox"
                name="is_rewatch"
                value="true"
                class="checkbox checkbox-primary"
              />
              <span class="label-text">
                <%= rewatch_label(@media_type) %>
              </span>
            </label>

            <!-- Notes -->
            <div class="form-control">
              <label class="label">
                <span class="label-text">Notes (optional)</span>
              </label>
              <textarea
                name="notes"
                rows="3"
                placeholder="Private notes about your experience..."
                class="textarea textarea-bordered resize-none"
                maxlength="300"
              ><%= @form_data["notes"] %></textarea>
              <div class="label">
                <span class="label-text-alt">
                  <span id="notes-counter">0</span>/300 characters
                </span>
              </div>
            </div>
          </div>
        </div>

        <!-- Rating Section -->
        <div class="mb-6">
          <label class="label">
            <span class="label-text">Rating (optional)</span>
          </label>
          <div class="rating rating-lg gap-2">
            <input
              :for={i <- 1..10}
              type="radio"
              name="rating"
              value={i}
              id={"rating-#{i}"}
              class="rating-hidden"
              phx-click="update_rating"
              phx-value-rating={i}
              phx-target={@myself}
              checked={@form_data["rating"] == to_string(i)}
            />
            <label
              :for={i <- 1..10}
              for={"rating-#{i}"}
              class="mask mask-star-2 w-8 h-8 cursor-pointer text-warning hover:text-warning/80 transition-colors duration-150"
              data-rating={i}
            >
            </label>
          </div>
          <div class="label">
            <span class="label-text-alt">Click stars to rate (1-10)</span>
          </div>
        </div>

        <!-- Review Section -->
        <div class="mb-6">
          <div class="form-control">
            <label class="label">
              <span class="label-text">Review (optional)</span>
            </label>
            <textarea
              name="review_content"
              rows="6"
              placeholder="Share your thoughts about this #{@media_type}..."
              class="textarea textarea-bordered resize-none"
            ><%= @form_data["review_content"] %></textarea>
          </div>

          <!-- Review Options -->
          <div class="mt-4 space-y-4">
            <!-- Spoiler Toggle -->
            <label class="flex items-center space-x-3 cursor-pointer">
              <input
                type="checkbox"
                name="spoiler"
                value="true"
                class="checkbox checkbox-error"
              />
              <span class="label-text">Contains spoilers</span>
            </label>

            <!-- Review Rating -->
            <div class="form-control">
              <label class="label">
                <span class="label-text">Review Rating (optional)</span>
              </label>
              <select
                name="review_rating"
                class="select select-bordered w-full max-w-xs"
              >
                <option value="">No rating</option>
                <option :for={i <- 1..10} value={i}><%= i %>/10</option>
              </select>
            </div>
          </div>
        </div>

        <!-- Submit Button -->
        <div class="flex justify-end space-x-3">
          <button
            type="button"
            phx-click="hide_interaction_modal"
            class="btn btn-ghost"
          >
            Cancel
          </button>
          <button
            type="submit"
            class="btn btn-primary"
          >
            Save
          </button>
        </div>
      </form>
    </div>

    <script>
      // Character counter for notes
      document.addEventListener('DOMContentLoaded', function() {
        const notesTextarea = document.querySelector('textarea[name="notes"]');
        const notesCounter = document.getElementById('notes-counter');

        if (notesTextarea && notesCounter) {
          const updateCounter = () => {
            notesCounter.textContent = notesTextarea.value.length;
          };

          notesTextarea.addEventListener('input', updateCounter);
          updateCounter(); // Initial count
        }

        // Log section toggle
        const logCheckbox = document.querySelector('input[name="create_log"]');
        const logSection = document.getElementById('log-section');

        if (logCheckbox && logSection) {
          const toggleLogSection = () => {
            logSection.style.display = logCheckbox.checked ? 'block' : 'none';
          };

          logCheckbox.addEventListener('change', toggleLogSection);
          toggleLogSection(); // Initial state
        }

        // Rating stars interaction
        const ratingStars = document.querySelectorAll('label[data-rating]');
        let selectedRating = 0;
        const checkedInput = document.querySelector('input[name="rating"]:checked');
        if (checkedInput) {
          selectedRating = parseInt(checkedInput.value);
        }

        ratingStars.forEach(star => {
          const rating = parseInt(star.dataset.rating);

          star.addEventListener('mouseenter', () => {
            highlightStars(rating);
          });

          star.addEventListener('click', () => {
            selectedRating = rating;
            highlightStars(rating, true);
          });
        });

        const ratingContainer = document.querySelector('.rating');
        if (ratingContainer) {
          ratingContainer.addEventListener('mouseleave', () => {
            if (selectedRating > 0) {
              highlightStars(selectedRating, true);
            } else {
              clearStars();
            }
          });
        }

        function highlightStars(rating, permanent = false) {
          ratingStars.forEach(star => {
            const starRating = parseInt(star.dataset.rating);
            if (starRating <= rating) {
              star.classList.add('bg-warning');
              star.classList.remove('bg-base-300');
            } else {
              star.classList.add('bg-base-300');
              star.classList.remove('bg-warning');
            }
          });
        }

        function clearStars() {
          ratingStars.forEach(star => {
            star.classList.add('bg-base-300');
            star.classList.remove('bg-warning');
          });
        }

        // Initialize stars based on current rating
        if (selectedRating > 0) {
          highlightStars(selectedRating, true);
        }
      });
    </script>
    """
  end

  def handle_event("toggle_log_section", _, socket) do
    {:noreply, socket}
  end

  def handle_event("update_rating", %{"rating" => rating}, socket) do
    form_data = Map.put(socket.assigns.form_data, "rating", rating)
    {:noreply, assign(socket, :form_data, form_data)}
  end

  def handle_event("submit_interaction", params, socket) do
    case create_interaction(params, socket.assigns) do
      {:ok, result} ->
        send(self(), {:interaction_saved, result})
        {:noreply, assign(socket, :show_modal, false)}

      {:error, error} ->
        {:noreply, put_flash(socket, :error, "Failed to save: #{inspect(error)}")}
    end
  end

  defp media_title(media, "movie"), do: media.title
  defp media_title(media, _), do: media.name

  defp media_year(media, "movie") do
    if media.release_date, do: media.release_date.year, else: "TBA"
  end

  defp media_year(media, "album") do
    if media.release_date, do: media.release_date.year, else: "TBA"
  end

  defp media_year(media, "game") do
    if media.release_date, do: media.release_date.year, else: "TBA"
  end

  defp media_year(media, "tv_show") do
    if media.first_air_date, do: media.first_air_date.year, else: "TBA"
  end

  # PRIVATE FUNCTIONS (all defp functions grouped at bottom)
  defp create_interaction(params, assigns) do
    %{media: media, media_type: media_type, current_user: current_user} = assigns

    # Create log if requested
    with {:ok, results} <- maybe_create_log(params, media, media_type, current_user),
         {:ok, results} <- maybe_create_standalone_rating(params, results, media, media_type, current_user),
         {:ok, results} <- maybe_create_review(params, results, media, media_type, current_user) do
      {:ok, results}
    end
  end

  defp maybe_create_log(params, media, media_type, current_user) do
    if params["create_log"] == "true" do
      log_attrs = %{
        "#{media_type}_id" => media.id,
        "rating" => params["rating"] && String.to_integer(params["rating"]),
        "logged_date" => Date.from_iso8601!(params["logged_date"]),
        "notes" => params["notes"],
        "is_#{rewatch_database_field(media_type)}" => params["is_rewatch"] == "true"
      }

      case create_log(media_type, log_attrs, current_user) do
        {:ok, log} -> {:ok, %{log: log}}
        {:error, error} -> {:error, error}
      end
    else
      {:ok, %{}}
    end
  end

  defp maybe_create_standalone_rating(params, results, media, media_type, current_user) do
    # Only create standalone rating if no log was created and rating is provided
    if params["rating"] && !Map.has_key?(results, :log) do
      rating_attrs = %{
        "#{media_type}_id" => media.id,
        "rating" => String.to_integer(params["rating"])
      }

      case create_rating(media_type, rating_attrs, current_user) do
        {:ok, rating} -> {:ok, Map.put(results, :rating, rating)}
        {:error, error} -> {:error, error}
      end
    else
      {:ok, results}
    end
  end

  defp maybe_create_review(params, results, media, media_type, current_user) do
    if params["review_content"] && String.trim(params["review_content"]) != "" do
      review_attrs = %{
        "#{media_type}_id" => media.id,
        "#{media_type}_log_id" => results[:log] && results[:log].id,
        "content" => params["review_content"],
        "rating" => params["review_rating"] && String.to_integer(params["review_rating"]),
        "spoiler" => params["spoiler"] == "true"
      }

      case create_review(media_type, review_attrs, current_user) do
        {:ok, review} -> {:ok, Map.put(results, :review, review)}
        {:error, error} -> {:error, error}
      end
    else
      {:ok, results}
    end
  end

  defp create_log("movie", attrs, user),
    do: Stackd.Media.MovieLog |> Ash.Changeset.for_create(:create, attrs) |> Ash.create(actor: user)

  defp create_log("tv_show", attrs, user),
    do: Stackd.Media.TvShowLog |> Ash.Changeset.for_create(:create, attrs) |> Ash.create(actor: user)

  defp create_log("album", attrs, user),
    do: Stackd.Media.AlbumLog |> Ash.Changeset.for_create(:create, attrs) |> Ash.create(actor: user)

  defp create_log("game", attrs, user),
    do: Stackd.Media.GameLog |> Ash.Changeset.for_create(:create, attrs) |> Ash.create(actor: user)

  defp create_rating("movie", attrs, user),
    do: Stackd.Media.MovieRating |> Ash.Changeset.for_create(:create, attrs) |> Ash.create(actor: user)

  defp create_rating("tv_show", attrs, user),
    do: Stackd.Media.TvShowRating |> Ash.Changeset.for_create(:create, attrs) |> Ash.create(actor: user)

  defp create_rating("album", attrs, user),
    do: Stackd.Media.AlbumRating |> Ash.Changeset.for_create(:create, attrs) |> Ash.create(actor: user)

  defp create_rating("game", attrs, user),
    do: Stackd.Media.GameRating |> Ash.Changeset.for_create(:create, attrs) |> Ash.create(actor: user)

  defp create_review("movie", attrs, user),
    do: Stackd.Media.MovieReview |> Ash.Changeset.for_create(:create, attrs) |> Ash.create(actor: user)

  defp create_review("tv_show", attrs, user),
    do: Stackd.Media.TvShowReview |> Ash.Changeset.for_create(:create, attrs) |> Ash.create(actor: user)

  defp create_review("album", attrs, user),
    do: Stackd.Media.AlbumReview |> Ash.Changeset.for_create(:create, attrs) |> Ash.create(actor: user)

  defp create_review("game", attrs, user),
    do: Stackd.Media.GameReview |> Ash.Changeset.for_create(:create, attrs) |> Ash.create(actor: user)

  defp media_icon("movie"), do: "🎬"
  defp media_icon("album"), do: "🎵"
  defp media_icon("game"), do: "🎮"
  defp media_icon("tv_show"), do: "📺"

  defp rewatch_label("movie"), do: "Rewatch"
  defp rewatch_label("tv_show"), do: "Rewatch"
  defp rewatch_label("album"), do: "Relisten"
  defp rewatch_label("game"), do: "Replay"

  defp rewatch_database_field("movie"), do: "rewatch"
  defp rewatch_database_field("tv_show"), do: "rewatch"
  defp rewatch_database_field("album"), do: "relisten"
  defp rewatch_database_field("game"), do: "replay"
end

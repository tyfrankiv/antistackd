defmodule StackdWeb.Components.Profile.ProfileEditModal do
  use StackdWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <!-- Edit Profile Modal -->
      <div
        :if={@show_modal}
        class="modal modal-open"
      >
        <div class="modal-box max-w-2xl" phx-click-away="hide_edit_modal" phx-target={@myself}>
          <button
            phx-click="hide_edit_modal"
            phx-target={@myself}
            class="btn btn-sm btn-circle btn-ghost absolute right-2 top-2"
          >
            <.icon name="hero-x-mark" class="w-4 h-4" />
          </button>

          <h2 class="text-xl font-bold mb-6">Edit Profile</h2>

          <!-- Profile Form -->
          <.form
            for={@profile_form}
            phx-submit="save_profile"
            phx-target={@myself}
            class="space-y-4"
            id="profile-edit-form"
          >
            <div class="form-control">
              <.input
                field={@profile_form[:display_name]}
                type="text"
                label="Display Name"
                placeholder="Your display name"
                class="input input-bordered"
              />
            </div>

            <div class="form-control">
              <.input
                field={@profile_form[:bio]}
                type="textarea"
                label="Bio"
                placeholder="Tell us about yourself..."
                class="textarea textarea-bordered h-24"
              />
            </div>

            <div class="form-control">
              <.input
                field={@profile_form[:avatar_url]}
                type="url"
                label="Avatar URL"
                placeholder="https://example.com/avatar.jpg"
                class="input input-bordered"
              />
            </div>

            <div class="modal-action">
              <button type="submit" class="btn btn-primary">
                Save Changes
              </button>
              <button
                type="button"
                phx-click="hide_edit_modal"
                phx-target={@myself}
                class="btn btn-ghost"
              >
                Cancel
              </button>
            </div>
          </.form>

          <!-- Username Change Form (if allowed) -->
          <div :if={@can_change_username} class="divider">Change Username</div>

          <.form
            :if={@can_change_username}
            for={@username_form}
            phx-submit="save_username"
            phx-target={@myself}
            class="space-y-4"
            id="username-edit-form"
          >
            <div class="form-control">
              <.input
                field={@username_form[:username]}
                type="text"
                label="Username"
                placeholder="Your username"
                class="input input-bordered"
              />
              <div class="label">
                <span class="label-text-alt text-warning">
                  Username can only be changed once per week
                </span>
              </div>
            </div>

            <div class="modal-action">
              <button type="submit" class="btn btn-warning">
                Change Username
              </button>
            </div>
          </.form>

          <div :if={!@can_change_username} class="divider">Change Username</div>

          <div :if={!@can_change_username} class="alert alert-info">
            <.icon name="hero-information-circle" class="w-5 h-5" />
            <span>You can change your username again in a few days.</span>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("hide_edit_modal", _params, socket) do
    send(self(), :hide_edit_modal)
    {:noreply, socket}
  end

  @impl true
  def handle_event("save_profile", %{"form" => params}, socket) do
    send(self(), {:save_profile, params})
    {:noreply, socket}
  end

  @impl true
  def handle_event("save_username", %{"form" => params}, socket) do
    send(self(), {:save_username, params})
    {:noreply, socket}
  end
end

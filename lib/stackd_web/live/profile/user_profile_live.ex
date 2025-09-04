defmodule StackdWeb.Profile.UserProfileLive do
  use StackdWeb, :live_view
  alias AshPhoenix.Form
  alias StackdWeb.Components.Profile.ProfileEditModal
  import Ash.Query

  on_mount {StackdWeb.LiveUserAuth, :live_user_optional}

  @impl true
  def mount(params, _session, socket) do
    case params do
      %{"username" => username} ->
        # Viewing a user's profile via /@username
        case Stackd.Accounts.User
             |> filter(username == ^username)
             |> filter(not is_nil(profile_completed_at))
             |> filter(is_nil(banned_at))
             |> Ash.read_one() do
          {:ok, user} when not is_nil(user) ->
            current_user = socket.assigns[:current_user]
            is_own_profile = current_user && current_user.id == user.id

            socket =
              socket
              |> assign(:user, user)
              |> assign(:page_title, "@#{user.username}")
              |> assign(:is_own_profile, is_own_profile)
              |> assign(:show_edit_modal, false)

            # Only create forms if it's the user's own profile
            socket =
              if is_own_profile do
                socket
                |> assign(:can_change_username, can_change_username?(user))
                |> assign_fresh_forms(user)
              else
                socket
              end

            {:ok, socket}

          {:ok, nil} ->
            {:ok,
             socket
             |> put_flash(:error, "User not found")
             |> redirect(to: ~p"/")}

          {:error, _} ->
            {:ok,
             socket
             |> put_flash(:error, "Error loading profile")
             |> redirect(to: ~p"/")}
        end

      _ ->
        # No username param - redirect to own profile if logged in
        current_user = socket.assigns[:current_user]

        case current_user do
          nil ->
            {:ok, redirect(socket, to: ~p"/sign-in")}

          user ->
            if user.username do
              {:ok, redirect(socket, to: ~p"/@#{user.username}")}
            else
              # User hasn't completed profile setup
              {:ok, redirect(socket, to: ~p"/complete-profile")}
            end
        end
    end
  end

  @impl true
  def handle_event("show_edit_modal", _params, socket) do
    # Only allow editing own profile
    if socket.assigns.is_own_profile do
      user = socket.assigns.user

      {:noreply,
       socket
       |> assign_fresh_forms(user)
       |> assign(:show_edit_modal, true)}
    else
      {:noreply, socket}
    end
  end

  # Handle messages from the ProfileEditModal component
  @impl true
  def handle_info(:hide_edit_modal, socket) do
    {:noreply, assign(socket, :show_edit_modal, false)}
  end

  @impl true
  def handle_info({:save_profile, params}, socket) do
    user = socket.assigns.user

    case user
         |> Form.for_update(:update_profile, actor: user, params: params)
         |> Form.submit() do
      {:ok, updated_user} ->
        {:noreply,
         socket
         |> assign(:user, updated_user)
         |> assign(:show_edit_modal, false)
         |> put_flash(:info, "Profile updated successfully!")}

      {:error, form} ->
        {:noreply, assign(socket, :profile_form, to_form(form))}
    end
  end

  @impl true
  def handle_info({:save_username, params}, socket) do
    user = socket.assigns.user

    case user
         |> Form.for_update(:change_username, actor: user, params: params)
         |> Form.submit() do
      {:ok, updated_user} ->
        # Redirect to new username URL
        {:noreply,
         socket
         |> put_flash(:info, "Username changed successfully!")
         |> redirect(to: ~p"/@#{updated_user.username}")}

      {:error, form} ->
        {:noreply, assign(socket, :username_form, to_form(form))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={@current_user}>
      <div class="min-h-screen bg-base-100">
        <div class="container mx-auto px-4 py-8 max-w-4xl">
          <!-- Profile Header -->
          <div class="bg-base-200 rounded-lg p-8 mb-6">
            <div class="flex flex-col md:flex-row items-start md:items-center gap-6">
              <!-- Avatar -->
              <div class="avatar">
                <div class="w-24 h-24 rounded-full">
                  <img
                    src={@user.avatar_url || "https://via.placeholder.com/150"}
                    alt={"#{@user.display_name}'s avatar"}
                  />
                </div>
              </div>

              <!-- Profile Info -->
              <div class="flex-1">
                <div class="flex flex-col md:flex-row md:items-center gap-4 mb-4">
                  <div>
                    <h1 class="text-3xl font-bold">{@user.display_name}</h1>
                    <p class="text-base-content/70 text-lg">@{@user.username}</p>
                  </div>

                  <!-- Edit Button (only show for own profile) -->
                  <button
                    :if={@is_own_profile}
                    phx-click="show_edit_modal"
                    class="btn btn-outline btn-primary"
                  >
                    <.icon name="hero-pencil" class="w-4 h-4" />
                    Edit Profile
                  </button>
                </div>

                <!-- Bio -->
                <div :if={@user.bio} class="prose max-w-none">
                  <p class="text-base-content/80">{@user.bio}</p>
                </div>
                <div :if={!@user.bio && @is_own_profile} class="text-base-content/50">
                  <p>Add a bio to tell people about yourself!</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Profile Content -->
          <div class="bg-base-200 rounded-lg p-8">
            <h2 class="text-2xl font-bold mb-4">Posts</h2>
            <div class="text-center py-12 text-base-content/50">
              <.icon name="hero-document-text" class="w-12 h-12 mx-auto mb-4 opacity-50" />
              <p>No posts yet.</p>
              <p :if={@is_own_profile} class="text-sm mt-2">Start sharing your thoughts!</p>
            </div>
          </div>
        </div>

        <!-- Profile Edit Modal Component (only render if own profile) -->
        <.live_component
          :if={@is_own_profile}
          module={ProfileEditModal}
          id="profile-edit-modal"
          show_modal={@show_edit_modal}
          profile_form={assigns[:profile_form]}
          username_form={assigns[:username_form]}
          can_change_username={assigns[:can_change_username] || false}
        />
      </div>
    </Layouts.app>
    """
  end

  # Helper function to create fresh forms
  defp assign_fresh_forms(socket, user) do
    profile_form = user
      |> Form.for_update(:update_profile,
          actor: user,
          params: %{
            "display_name" => user.display_name || "",
            "bio" => user.bio || "",
            "avatar_url" => user.avatar_url || ""
          })
      |> to_form()

    username_form = user
      |> Form.for_update(:change_username,
          actor: user,
          params: %{"username" => user.username || ""})
      |> to_form()

    socket
    |> assign(:profile_form, profile_form)
    |> assign(:username_form, username_form)
  end

  # Helper function to check if user can change username
  defp can_change_username?(user) do
    case user.username_last_changed_at do
      nil -> true
      last_changed ->
        DateTime.diff(DateTime.utc_now(), last_changed, :day) >= 7
    end
  end
end

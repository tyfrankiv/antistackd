defmodule StackdWeb.ProfileSetupLive do
  use StackdWeb, :live_view

  on_mount {StackdWeb.LiveUserAuth, :live_user_required}

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    if user && user.profile_completed_at do
      {:ok, push_navigate(socket, to: ~p"/")}
    else
      form =
        user
        |> AshPhoenix.Form.for_update(:complete_profile, actor: user)
        |> to_form()

      {:ok, assign(socket, form: form)}
    end
  end

  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("save", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> assign(:current_user, user)
         |> put_flash(:info, "Profile completed!")
         |> push_navigate(to: ~p"/")}

      {:error, form} ->
        {:noreply, assign(socket, :form, form)}
    end
  end
end

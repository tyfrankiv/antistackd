defmodule StackdWeb.PageController do
  use StackdWeb, :controller

  def home(conn, _params) do
    case conn.assigns[:current_user] do
      nil ->
        # Not signed in, show landing page
        render(conn, :home)
      
      user ->
        if is_nil(user.profile_completed_at) do
          # Signed in but profile not complete
          redirect(conn, to: ~p"/complete-profile")
        else
          # Signed in with complete profile
          redirect(conn, to: ~p"/dashboard")
        end
    end
  end
end

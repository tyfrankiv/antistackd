defmodule Stackd.Accounts.Roles do
  @moduledoc """
  Role and permission management utilities for the Stackd application.
  """

  @roles [:admin, :moderator, :user]
  @permissions [
    # Future permissions - not implemented yet but defined for extensibility
    "manage_users",
    "ban_users", 
    "moderate_content",
    "view_admin_panel",
    "delete_content",
    "edit_content"
  ]

  @doc """
  Returns all available roles.
  """
  def all_roles, do: @roles

  @doc """
  Returns all available permissions.
  """
  def all_permissions, do: @permissions

  @doc """
  Checks if a user has a specific role.
  """
  def has_role?(%{role: role}, required_role) when role in @roles do
    role == required_role
  end
  def has_role?(_, _), do: false

  @doc """
  Checks if a user has admin privileges.
  """
  def admin?(%{role: :admin}), do: true
  def admin?(_), do: false

  @doc """
  Checks if a user has moderator or admin privileges.
  """
  def moderator_or_admin?(%{role: role}) when role in [:admin, :moderator], do: true
  def moderator_or_admin?(_), do: false

  @doc """
  Checks if a user has a specific permission.
  """
  def has_permission?(%{permissions: permissions}, permission) when is_list(permissions) do
    permission in permissions
  end
  def has_permission?(_, _), do: false

  @doc """
  Checks if a user is banned.
  """
  def banned?(%{banned_at: nil}), do: false
  def banned?(%{banned_at: banned_at}) when not is_nil(banned_at), do: true
  def banned?(_), do: false

  @doc """
  Gets the default permissions for a role.
  """
  def default_permissions_for_role(:admin) do
    @permissions
  end

  def default_permissions_for_role(:moderator) do
    ["ban_users", "moderate_content", "delete_content", "edit_content"]
  end

  def default_permissions_for_role(:user) do
    []
  end

  @doc """
  Checks if a role can perform an action on another role.
  For example, admins can manage anyone, moderators can manage users but not admins.
  """
  def can_manage_role?(:admin, _target_role), do: true
  def can_manage_role?(:moderator, :user), do: true
  def can_manage_role?(:moderator, :moderator), do: false
  def can_manage_role?(:moderator, :admin), do: false
  def can_manage_role?(:user, _), do: false
  def can_manage_role?(_, _), do: false

  @doc """
  Returns a human-readable string for a role.
  """
  def role_display_name(:admin), do: "Administrator"
  def role_display_name(:moderator), do: "Moderator"
  def role_display_name(:user), do: "User"
  def role_display_name(_), do: "Unknown"
end

defmodule Stackd.Accounts.Validations.ProfileNotCompletedValidation do
  use Ash.Resource.Validation

  @impl true
  def validate(changeset, _opts, _context) do
    case changeset.data do
      %{profile_completed_at: nil} -> :ok
      _ -> {:error, "Profile already completed"}
    end
  end

  @impl true
  def atomic?(), do: false
end

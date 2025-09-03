defmodule Stackd.Accounts.Validations.UsernameFormatValidation do
  use Ash.Resource.Validation

  @impl true
  def validate(changeset, _opts, _context) do
    case Ash.Changeset.get_argument(changeset, :username) do
      nil -> :ok
      username when is_binary(username) ->
        if Regex.match?(~r/^[a-zA-Z0-9_]+$/, username) do
          :ok
        else
          {:error, "Username can only contain letters, numbers, and underscores"}
        end
      _ -> {:error, "Invalid username format"}
    end
  end

  @impl true
  def atomic?(), do: false
end

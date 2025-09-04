defmodule Stackd.Accounts.Validations.UsernameChangeRateLimitValidation do
  use Ash.Resource.Validation

  @impl true
  def validate(changeset, opts, _context) do
    days = Keyword.get(opts, :days, 7)

    case changeset.data do
      %{username_last_changed_at: nil} ->
        :ok

      %{username_last_changed_at: last_changed} ->
        cutoff = DateTime.add(DateTime.utc_now(), -days * 24 * 60 * 60, :second)

        if DateTime.compare(last_changed, cutoff) == :lt do
          :ok
        else
          {:error, "Username can only be changed once every #{days} days"}
        end

      _ ->
        :ok
    end
  end

  @impl true
  def atomic?(), do: false
end

defmodule Stackd.Accounts.Validations.UrlValidation do
  use Ash.Resource.Validation

  @impl true
  def validate(changeset, opts, _context) do
    field = Keyword.get(opts, :field, :avatar_url)

    case Ash.Changeset.get_argument_or_attribute(changeset, field) do
      nil ->
        :ok

      "" ->
        :ok

      url when is_binary(url) ->
        validate_url(url)

      _ ->
        {:error, "Invalid URL format"}
    end
  end

  defp validate_url(url) do
    # Basic URL validation
    case URI.parse(url) do
      %URI{scheme: scheme, host: host} when scheme in ["http", "https"] and not is_nil(host) ->
        # Additional security checks
        cond do
          # Block localhost/internal IPs for security
          host in ["localhost", "127.0.0.1", "0.0.0.0"] ->
            {:error, "Localhost URLs are not allowed"}

          # Block private IP ranges
          is_private_ip?(host) ->
            {:error, "Private IP addresses are not allowed"}

          # Block common malicious patterns
          String.contains?(url, ["javascript:", "data:", "vbscript:", "<script"]) ->
            {:error, "Invalid URL format"}

          # URL too long (prevent DoS)
          String.length(url) > 500 ->
            {:error, "URL too long (max 500 characters)"}

          true ->
            :ok
        end

      _ ->
        {:error, "Invalid URL format - must be a valid HTTP or HTTPS URL"}
    end
  end

  defp is_private_ip?(host) do
    case :inet.parse_address(String.to_charlist(host)) do
      {:ok, {10, _, _, _}} -> true
      {:ok, {172, b, _, _}} when b >= 16 and b <= 31 -> true
      {:ok, {192, 168, _, _}} -> true
      {:ok, {169, 254, _, _}} -> true  # Link-local
      _ -> false
    end
  end

  @impl true
  def atomic?(), do: false
end

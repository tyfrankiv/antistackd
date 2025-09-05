defmodule Stackd.Accounts.Validations.TextSanitizationValidation do
  use Ash.Resource.Validation

  @impl true
  def validate(changeset, opts, _context) do
    field = Keyword.get(opts, :field)

    case Ash.Changeset.get_argument_or_attribute(changeset, field) do
      nil ->
        :ok

      "" ->
        :ok

      text when is_binary(text) ->
        validate_text_content(text, field)

      _ ->
        {:error, "Invalid text format"}
    end
  end

  defp validate_text_content(text, field) do
    cond do
      # Check for HTML/script injection attempts
      contains_html_tags?(text) ->
        {:error, "HTML tags are not allowed"}

      # Check for potentially malicious content
      contains_malicious_patterns?(text) ->
        {:error, "Invalid content detected"}

      # Check for excessive whitespace (potential DoS)
      excessive_whitespace?(text) ->
        {:error, "Excessive whitespace detected"}

      # Field-specific validation
      field == :display_name and contains_special_chars?(text) ->
        {:error, "Display name contains invalid characters"}

      true ->
        :ok
    end
  end

  defp contains_html_tags?(text) do
    # Check for common HTML tags and entities
    html_patterns = [
      # HTML tags
      ~r/<[^>]*>/,
      # HTML entities
      ~r/&[a-zA-Z0-9#]+;/,
      # JavaScript protocol
      ~r/javascript:/i,
      # Data URLs
      ~r/data:/i,
      # VBScript protocol
      ~r/vbscript:/i,
      # Event handlers
      ~r/on\w+\s*=/i
    ]

    Enum.any?(html_patterns, &Regex.match?(&1, text))
  end

  defp contains_malicious_patterns?(text) do
    # Check for common injection patterns
    malicious_patterns = [
      ~r/<script/i,
      ~r/<iframe/i,
      ~r/<object/i,
      ~r/<embed/i,
      ~r/<form/i,
      ~r/<input/i,
      ~r/eval\s*\(/i,
      ~r/expression\s*\(/i,
      ~r/url\s*\(/i
    ]

    Enum.any?(malicious_patterns, &Regex.match?(&1, text))
  end

  defp excessive_whitespace?(text) do
    # Check if more than 50% of the text is whitespace
    whitespace_count = String.length(text) - String.length(String.trim(text))
    total_length = String.length(text)

    total_length > 0 and whitespace_count / total_length > 0.5
  end

  defp contains_special_chars?(text) do
    # For display names, only allow letters, numbers, spaces, and basic punctuation
    not Regex.match?(~r/^[a-zA-Z0-9\s\-_'.]+$/, text)
  end

  @impl true
  def atomic?(), do: false
end

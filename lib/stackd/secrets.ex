defmodule Stackd.Secrets do
  use AshAuthentication.Secret

  def secret_for(
        [:authentication, :tokens, :signing_secret],
        Stackd.Accounts.User,
        _opts,
        _context
      ) do
    Application.fetch_env(:stackd, :token_signing_secret)
  end
end

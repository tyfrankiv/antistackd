defmodule Stackd.Accounts do
  use Ash.Domain, otp_app: :stackd, extensions: [AshAdmin.Domain]

  admin do
    show? true
  end

  resources do
    resource Stackd.Accounts.Token
    resource Stackd.Accounts.User
  end
end

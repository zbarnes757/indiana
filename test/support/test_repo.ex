defmodule Indiana.TestRepo do
  use Ecto.Repo, otp_app: :indiana
  use Indiana.Integrations.Ecto
end

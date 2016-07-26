use Mix.Config

import_config "dev.secret.exs"

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

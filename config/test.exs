use Mix.Config

import_config "test.secret.exs"
# Print only warnings and errors during test
config :logger, level: :warn

import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :multi_chain, MultiChainWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "w+OL6xESFPzStL/Z0cQIj+0H2v8A/raNWmvlfzuiqW+7Jej2fj//O6rDJxrZraOo",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

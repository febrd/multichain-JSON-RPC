# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :multi_chain,
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :multi_chain, MultiChainWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [json: MultiChainWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: MultiChain.PubSub,
  live_view: [signing_salt: "zUs9dQUh"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

#config multichain
config :multi_chain,
  protocol: [
    dev: "http",
    prod: "https"
  ],
  port: [
    dev: 0000,
    prod: 0000
  ],
  host: [
    prod: "",
    dev: ""
  ],
  username: "",
  password: "",
  chain: "",
  apps_env: [
    status: Mix.env() # or :prod
  ]
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

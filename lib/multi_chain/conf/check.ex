
defmodule MultiChain.Conf.Check do
  def check_config do
    config = get_config()

    case validate_config(config) do
      {:ok, validated_config} -> {:ok, validated_config}
      {:error, message} -> {:error, message}
    end
  end

  defp get_config do
    port_key = :port
    host_key = :host
    username_key = :username
    password_key = :password
    chain_key = :chain
    protocol_key = :protocol
        %{
          env: Mix.env(),
          port: Application.get_env(:multi_chain, port_key)[Mix.env()],
          host: Application.get_env(:multi_chain, host_key)[Mix.env()],
          username: Application.get_env(:multi_chain, username_key),
          password: Application.get_env(:multi_chain, password_key),
          chain: Application.get_env(:multi_chain, chain_key),
          protocol: Application.get_env(:multi_chain, protocol_key)[Mix.env()]
        }
  end

  defp validate_config(config) do
    required_keys = ~w(port host username password chain protocol)a

    case Enum.all?(required_keys, &Map.has_key?(config, &1)) do
      true -> {:ok, config}
      false -> {:error, "aduh Some of the config parameters are not available. Check your config file"}
    end
  end
end

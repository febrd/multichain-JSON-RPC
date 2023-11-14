defmodule MultiChain.Method.Http do
  @moduledoc """
  document for http protokol
  """
  alias MultiChain.Ping
  alias MultiChain.Conf.Check

  def rpc_call(method, param) do
    params = %{
      method: method,
      params: param

    }
    case Check.check_config do

      {:ok, config} ->
        host = Map.get(config, :host, "")
        protocol = Map.get(config, :protocol, "")
        port = Map.get(config, :port,"")
        chain = Map.get(config, :chain, "")
        username = Map.get(config, :username, "")
        password = Map.get(config, :password, "")

        case Ping.host(host) do
          nil ->

            {:error, "Host is not reachable. Please ensure your host address"}

            # Additional actions if the host is not reachable

          host ->
            url = "#{protocol}://#{host}:#{port}"
            headers = [{"Content-type", "application/json"}]
            body = Poison.encode!(params |> Map.put("chain_name", chain))
            options = [hackney: [basic_auth: {username, password}]]

            case HTTPoison.post(url, body, headers, options) do
              # check the status code
              {:ok, result} ->
                case result.status_code do
                  200 -> Poison.decode(result.body)
                  401 -> {:error, "Unauthorized. The supplied credential is incorrect"}
                  error -> {:error, "Error code: #{error}. Reason: #{get_error_msg(result.body)}"}
                end

              _ ->
                {:error, "Cannot connect to Multichain node. Check the server address and port."}
            end
            end
      {:error, message} ->
        {:error, message}
    end
  end


  def rpc_call!(method, param) do
    params = %{
      method: method,
      params: param
    }
    case Check.check_config do
      {:ok, config} ->
        host = Map.get(config, :host, "")
        protocol = Map.get(config, :protocol, "")
        port = Map.get(config, :port)
        chain = Map.get(config, :chain, "")
        username = Map.get(config, :username, "")
        password = Map.get(config, :password, "")
        case Ping.host(host) do
          nil ->

            {:error, "Host is not reachable. Please ensure your host address"}
            # Additional actions if the host is not reachable

            host ->
             url = "#{protocol}://#{host}:#{port}"
            headers = [{"Content-type", "application/json"}]
            body = Poison.encode!(params |> Map.put("chain_name", chain))
            options = [hackney: [basic_auth: {username, password}]]

            case HTTPoison.post(url, body, headers, options) do
              # check the status code
              {:ok, result} ->
                case result.status_code do
                  200 -> Poison.decode(result.body)
                  401 -> {:error, "Unauthorized. The supplied credential is incorrect"}
                  error -> {:error, "Error code: #{error}. Reason: #{get_error_msg(result.body)}"}
                end
              _ ->
                {:error, "Cannot connect to Multichain node. Check the server address and port."}
            end
            end
      {:error, message} ->
        {:error, message}
    end
  end


  def get_error_msg(body) do
    case Poison.decode(body) do
      {:ok, result} -> result["error"]["message"]
    end
  end
end

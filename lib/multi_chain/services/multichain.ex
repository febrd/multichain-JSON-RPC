defmodule MultiChain.Services.Multichain do

  alias MultiChain.Method.Http

  def get_api(method, params) do
    Http.rpc_call(method, params)
  end


  def balances(address) do
    Http.rpc_call("getaddressbalances", [address, 1, true])
  end

  @doc """
  This function will return spesific balance. It will always return number.

  Any other problem such as wrong address and even connection problem will be translated to zero (0).

  ```
  iex(1)> Multichain.balance("1DEd7MqSxLgpDs9uUipcmfXqWxxpzwiJ8SojmY", "176-266-23437")
  1.0e3
  ```

  """
  def balance(address, assetcode) do
    # TODO do lock unspent! read the api docs and include the locked unspent.
    case Http.rpc_call("getaddressbalances", [address, 1, true]) do
      {:ok, result} -> find_asset(result["result"], assetcode)
      _ -> 0
    end
  end

  @doc """
  This function will return spesific balance. It will return tuple with atom and result.

  While `balance/2` will always return number, `balance!/2` will tell you if error happened.

  ```
  iex(1)> Multichain.balance!("1DEd7MqSxLgpDs9uUipcmfXqWxxpzwiJ8SojcmY", "176-266-23437")
  {:error,
  "Error code: 500. Reason: Invalid address: 1DEd7MqSxLgpDs9uUipcmfXqWxxpzwiJ8SojcmY"
  iex(2)> Multichain.balance!("1DEd7MqSxLgpDs9uUipcmfXqWxxpzwiJ8SojmY", "176-266-23437")
  {:ok, 1.0e3}
  ```

  """
  def balance!(address, assetcode) do
    case Http.rpc_call("getaddressbalances", [address, 1, true]) do
      {:ok, result} -> find_asset!(result["result"], assetcode)
      other -> other
    end
  end

  @doc """
  This function will return list of all asset own by the node's wallet where is_mine is true.

  ```
  iex(1)> Multichain.nodebalance
  {:ok,
   [
     %{"assetref" => "6196-266-29085", "name" => "MMKP", "qty" => 9.0e7},
     %{"assetref" => "176-266-23437", "name" => "MMK", "qty" => 1.74e5},
     %{"assetref" => "60-266-6738", "name" => "GET", "qty" => 9970.0}
   ]}
  ```

  """
  def nodebalance do
    case Http.rpc_call("gettotalbalances", []) do
      {:ok, result} -> {:ok, result["result"]}
      error -> error
    end
  end

  @doc """
  This function will return configuration of run time parameter of the multichain.

  """
  def getruntimeparams do
    case Http.rpc_call("getruntimeparams", []) do
      {:ok, result} -> {:ok, result["result"]}
      error -> error
    end
  end

  @doc """
  Get the list of Multichain api.

  """
  def help do
    case Http.rpc_call("help", []) do
      {:ok, result} -> {:ok, result["result"]}
      error -> error
    end
  end

  @doc """
  This function will return information about the connected Multichain's node.

  Usually this is used to check the connection.

  """
  def getinfo do
    case Http.rpc_call("getinfo", []) do
      {:ok, result} -> {:ok, result["result"]}
      error -> error
    end
  end

  @doc """
  This function will return list of all address own by the Node's wallet including each asset list.

  ```
  iex(1)> Multichain.allbalances
  {:ok,
   %{
     "1MRUjzje91QBpnBqkhAdrnCDKHikXFhsPQ4rA2" => [
       %{"assetref" => "6196-266-29085", "name" => "MMKP", "qty" => 9.0e7},
       %{"assetref" => "176-266-23437", "name" => "MMK", "qty" => 1.74e5},
       %{"assetref" => "60-266-6738", "name" => "GET", "qty" => 9970.0}
     ],
     "total" => [
       %{"assetref" => "6196-266-29085", "name" => "MMKP", "qty" => 9.0e7},
       %{"assetref" => "176-266-23437", "name" => "MMK", "qty" => 1.74e5},
       %{"assetref" => "60-266-6738", "name" => "GET", "qty" => 9970.0}
     ]
   }}
  ```

  """
  def allbalances do
    case Http.rpc_call("getmultibalances", []) do
      {:ok, result} -> {:ok, result["result"]}
      error -> error
    end
  end

  # ------------------------------------------------Private Area ----------------------------------

  defp find_asset(list, assetcode) do
    case Enum.filter(list, fn x -> x["assetref"] == assetcode end) do
      [] -> 0
      [ada] -> ada["qty"]
      _ -> 0
    end
  end

  defp find_asset!(list, assetcode) do
    case Enum.filter(list, fn x -> x["assetref"] == assetcode end) do
      [] -> {:ok, 0}
      [ada] -> {:ok, ada["qty"]}
      _ -> {:error, "Unknown Error"}
    end
  end

end

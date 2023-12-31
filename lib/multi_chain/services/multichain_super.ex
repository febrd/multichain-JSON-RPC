defmodule MultiChain.Services.MultichainSuper do


  alias MultiChain.Method.Http
  alias MultiChain.Services.Multichain
  def create_external_address do
    # 1 create keypair
    case Http.rpc_call("createkeypairs", [1]) do
      {:ok, result} ->
        [keypair] = result["result"]
        # 2. import address
        case Http.rpc_call("importaddress", [keypair["address"], "", false]) do
          # 3. grant permission sent
          {:ok, _result2} ->
            case Http.rpc_call("grant", [keypair["address"], "send,receive"]) do
              {:ok, _result4} -> {:ok, keypair}
              other -> other
            end

          other ->
            other
        end

      other ->
        other
    end
  end

  @doc """
  This function will return a list of all address who have issue permission.

  This address can issue any new asset.
  """

  def who_can_issue() do
    case Http.rpc_call("listpermissions", ["issue"]) do
      {:ok, result} -> {:ok, result["result"]}
      error -> error
    end
  end

  @doc """
  This function will reissue another quantity from existing assets.

  If you want to create new type of asset, use `Multichain.api/2` and its respective parameter based on Multichain API documentation.
  """

  def print_money(assetname, qty) do
    case who_can_issue() do
      {:ok, result} ->
        if length(result) == 0 do
          {:error, "No issuer founded"}
        else
          [first | _] = result
          issuer = first["address"]

          case Http.rpc_call("issuemorefrom", [issuer, issuer, assetname, qty, 0]) do
            {:ok, result} -> {:ok, result}
            error -> error
          end
        end

      error ->
        error
    end
  end

  @doc """
  This function is used to transfer asset from external address, owning the private key.

  If the key is handled externally, you can transfer asset from one address to another using this method. If it is internal address, use `transfer/3` instead.
  """
  def transfer(assetcode, from, to, qty, privkey) do
    case Http.rpc_call("createrawsendfrom", [from, %{to => %{assetcode => qty}}]) do
      {:ok, %{"error" => nil, "id" => nil, "result" => result}} ->
        case Http.rpc_call("signrawtransaction", [result, [], [privkey]]) do
          {:ok, %{"error" => nil, "id" => nil, "result" => %{"complete" => true, "hex" => hex}}} ->
            case Http.rpc_call("sendrawtransaction", [hex]) do
              {:ok, %{"error" => nil, "id" => nil, "result" => trxid}} -> {:ok, trxid}
              other -> other
            end

          other ->
            other
        end

      other ->
        other
    end
  end

  @doc """
  This function is used to transfer asset from internal address.

  If the address is exist on `list_internal_address/0` then we can use this function to transfer asset.
  """
  def transfer(assetcode, from, to, qty) do
    case Http.rpc_call("sendassetfrom", [from, to, assetcode, qty]) do
      {:ok, result} -> {:ok, result["result"]}
      error -> error
    end
  end

  @doc """
  This function will return all address manage and owned by this node.

  If you want to see all address watched by this node but owned by external, use `list_external_address/0`

  """
  def list_internal_address() do
    case Multichain.get_api("getaddresses", [true]) do
      {:ok, result} ->
        hasil = result["result"] |> Enum.filter(fn x -> x["ismine"] == true end)
        {:ok, %{"count" => length(hasil), "result" => hasil}}

      other ->
        other
    end
  end

  @doc """
  This function will return all address watched by this node but not belong to node's wallet, which means we cannot transfer any asset unless we know the private key

  If you want to see all address which can be used without private key, use `list_internal_address/0`

  """
  def list_external_address() do
    case Multichain.get_api("getaddresses", [true]) do
      {:ok, result} ->
        hasil = result["result"] |> Enum.filter(fn x -> x["ismine"] == false end)
        {:ok, %{"count" => length(hasil), "result" => hasil}}

      other ->
        other
    end
  end

  @doc """
  This function generate internal address which can be used without private key. This will also give send and receive permission to the address.

  If you want to create address without permission you can use `Multichain.api("getnewaddress", [])`

  """
  def create_internal_address() do
    case Http.rpc_call("getnewaddress", []) do
      {:ok, result} ->
        case grant_send_receive(result["result"]) do
          {:ok, _} -> {:ok, result["result"]}
          other -> other
        end

      error ->
        error
    end
  end

  @doc """
  This function top up any code from primary Node's wallet. Also the address which usually have issue permission.

  """
  def topup(address, assetcode, qty) do
    case Http.rpc_call("sendasset", [address, assetcode, qty]) do
      {:ok, result} -> {:ok, result["result"]}
      error -> error
    end
  end

  @doc """
  This function is used to revoke send permission of a particular address.
  """
  def block(address) do
    case Http.rpc_call("revoke", [address, "send"]) do
      {:ok, result} -> {:ok, result["result"]}
      error -> error
    end
  end

  @doc """
  This function is used to give send permission to address which previously has been blocked.
  """
  def unblock(address) do
    case Http.rpc_call("grant", [address, "send"]) do
      {:ok, result} -> {:ok, result["result"]}
      error -> error
    end
  end

  @doc """
  This is a helper to grant_send and receive to particular address.
  """
  def grant_send_receive(address) do
    case Http.rpc_call("grant", [address, "send,receive"]) do
      {:ok, result} -> {:ok, result["result"]}
      error -> error
    end
  end

  @doc """
  This is a helper function to check whether an address have send permission or not.

  You can unblock (give send permission) by using `unblock/1`
  """
  def blockstatus(address) do
    case Multichain.get_api("listpermissions", ["*", address]) do
      {:ok, result} -> find_send_permission(result["result"])
      error -> error
    end
  end

  @doc """
  This is a helper function to check whether an address have send permission or not.

  You can unblock (give send permission) by using `unblock/1`
  """
  def publish_stream(addr, streamname, key, value, privkey) do

      case Multichain.get_api("createrawsendfrom", [
             addr,
             %{},
             [%{"for" => streamname, "key" => key, "data" => Base.encode16(value)}]
           ]) do
        {:ok, %{"error" => _error, "id" => _id, "result" => result}} ->
          case Multichain.get_api("signrawtransaction", [result, [], [privkey], nil]) do
            {:ok, %{"error" => nil, "id" => nil, "result" => %{"complete" => true, "hex" => hex}}} ->
              Multichain.get_api("sendrawtransaction", [hex])

            other ->
              other
          end

        other ->
          other
      end
  end

  def get_stream_data!(stream, txid) do
    case Multichain.get_api("getstreamitem", [stream, txid]) do
      {:ok, %{"error" => nil, "id" => nil, "result" => result}} -> result
      other -> other
    end
  end

  def get_stream_data(stream, txid) do
    case Multichain.get_api("getstreamitem", [stream, txid]) do
      {:ok, %{"error" => nil, "id" => nil, "result" => result}} ->
        case Base.decode16(result["data"], case: :lower) do
          {:ok, string} -> string
          _ -> :error
        end

      other ->
        other
    end
  end

  # ------------------------------------------------Private Area ----------------------------------

  defp find_send_permission(list) do
    case Enum.filter(list, fn x -> x["type"] == "send" end) do
      [] -> true
      _ -> false
    end
  end

end

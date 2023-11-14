# Comprehensive Documentation for Multichain Elixir Integration
This is a thin Elixir wrapper for Multichain JSON RPC.



## Installation
Specification
```elixir
 def project do
    [
     ...
      elixir: "~> 1.15"
     ...
    ]
  end
```
List the Hex package in your application dependencies.

```elixir
def deps do
  [
      {:httpoison, "~> 1.2"},
      {:poison, "~> 3.1"}
  ]
end
```


## Configuration

Setup Multichain RPC

```shell
┌──(github㉿febrd)-[~]
└─$ multichain-util create <desired-chain>
                                                   
┌──(github㉿febrd)-[~]
└─$ multichaind <desired-chain> -daemon -rpcuser=yourdesireduser -rpcpassword=yourstrongestpassword

                                                    
┌──(github㉿febrd)-[~]
└─$ multichain-cli <desired-chain> -rpcuser=yourdesireduser -rpcpassword=yourstrongestpassword                         

```

Setup configuration variables in your `config/config.exs` file:

```elixir
 config :multi_chain,
  protocol: [
    dev: "http",
    prod: "https"
  ],
  port: [
    dev: 0000, #default : 9238
    prod: 0000
  ],
  host: [
    prod: "",
    dev: "" #default : 127.0.0.1
  ],
  username: "<yourstrongestpassword>",
  password: "<yourdesireduser>",
  chain: "<desired-chain>",
  apps_env: [
    status: Mix.env() # :dev or :prod
  ]
```

Run

```shell
• mix deps.get
• mix compile
• iex -S mix run 
```


##Example Usage

Interactive Elixir (1.15.7) :
```shell
#aliases
iex(1)> alias MultiChain.Services.Multichain
MultiChain.Services.Multichain
iex(2)> alias MultiChain.Services.MultichainSuper
MultiChain.Services.MultichainSuper
iex(3)> alias MultiChain.Conf.Check
MultiChain.Conf.Check

# Check Config
iex(4)> Check.check_config
{:ok,
 %{                                                 
   env: :dev, #default :dev                                      
   port: 9238, #default : 9283                                         
   protocol: "http",                                
   host: "127.0.0.1",                                        
   username: "yourusername",                                    
   password: "yourpassword",                                    
   chain: "yourchain"                                        
 }}
#Multichain
iex(5)> Multichain.get_api("validateaddress", ["15fSeis7r7wwhNTU6h3S88qVcnGQ6ay9ZHuqNH"])              
{:ok,
 %{                                                 
   "error" => nil,                                  
   "id" => nil,                                     
   "result" => %{                                   
     "account" => "",                               
     "address" => "15fSeis7r7wwhNTU6h3S88qVcnGQ6ay9ZHuqNH",                                             
     "iscompressed" => true,                        
     "ismine" => true,                              
     "isscript" => false,                           
     "isvalid" => true,                             
     "iswatchonly" => false,                        
     "pubkey" => "02d1b0f8142acff73be8f822b58f8f932cd48a86f307b4ecf2c4020c0990f2572a",                  
     "synchronized" => true                         
   }                                                
 }}                       

```

#Command Reference
1. **Ping Module:**
   - Description: Module for checking the reachability of a host using the ping command.
   - Functionality:
     - `host/1`: Checks the reachability of the specified host.

2. **Conf.Check Module:**
   - Description: Module for checking and validating configuration settings.
   - Functionality:
     - `check_config/0`: Checks and validates the configuration settings.
     - `get_config/0`: Retrieves configuration settings.
     - `validate_config/1`: Validates the configuration settings.

3. **Method.Http Module:**
   - Description: Module for making HTTP RPC calls.
   - Functionality:
     - `rpc_call/2`: Makes an RPC call to the specified method with parameters.
     - `rpc_call!/2`: Similar to `rpc_call/2` but raises an exception on error.
     - `get_error_msg/1`: Extracts error messages from the HTTP response.

4. **Services.MultichainSuper Module:**
   - Description: Module providing higher-level functions for Multichain operations.
   - Functionality:
     - `create_external_address/0`: Creates an external address with key pair.
     - `who_can_issue/0`: Returns a list of addresses with issue permission.
     - `print_money/2`: Reissues a quantity of an existing asset.
     - `transfer/5`: Transfers assets from one address to another.
     - `list_internal_address/0`: Returns all addresses managed by the node.
     - `list_external_address/0`: Returns all addresses watched by the node but not owned.
     - `create_internal_address/0`: Generates an internal address without a private key.
     - `topup/3`: Tops up an address with a specified asset and quantity.
     - `block/1`: Revokes send permission for a particular address.
     - `unblock/1`: Grants send permission to an address.
     - `grant_send_receive/1`: Grants send and receive permission to an address.
     - `blockstatus/1`: Checks whether an address has send permission or not.
     - `publish_stream/5`: Publishes data to a stream on the blockchain.
     - `get_stream_data!/2`: Gets data from a stream with error handling.
     - `get_stream_data/2`: Gets data from a stream.

5. **Services.Multichain Module:**
   - Description: Module providing basic Multichain operations.
   - Functionality:
     - `get_api/2`: Makes a generic API call to Multichain.
     - `balances/1`: Returns the balances of a specified address.
     - `balance/2`: Returns the balance of a specific asset for a given address.
     - `balance!/2`: Similar to `balance/2` but raises an exception on error.
     - `nodebalance/0`: Returns a list of all assets owned by the node's wallet.
     - `getruntimeparams/0`: Returns the runtime parameters of Multichain.
     - `help/0`: Returns the list of Multichain API methods.
     - `getinfo/0`: Returns information about the connected Multichain node.
     - `allbalances/0`: Returns a list of all addresses owned by the node's wallet with their associated assets.

6. **Private Area:**
   - Description: Contains private helper functions used internally.
   - Functionality:
     - Various private functions used for asset and permission checks.



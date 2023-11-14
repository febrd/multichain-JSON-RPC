defmodule MultiChain.Ping do


  def host(host) do
    case System.cmd("ping", ["-c", "1", host]) do
      {_, 0} -> host
      _ -> nil
    end
  end

end

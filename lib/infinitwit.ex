defmodule Infinitwit do

  def read do
    {:ok, pid} = Infinitwit.Server.start_link
    ExTwitter.stream_sample(language: "en")
    |> Stream.map(fn tweet -> Infinitwit.Server.process(pid, tweet.text) end)
    |> Enum.to_list
  end

end

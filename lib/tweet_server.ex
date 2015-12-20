defmodule Infinitwit.Server do
  @doc """
  A server for processing tweets
  """

  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link __MODULE__, :ok, opts
  end

  def process(pid, tweet) do
    spawn_link fn -> do_process(pid, tweet) end
  end

  defp do_process(pid, tweet) do
    cur = GenServer.call(pid, {:get_cur})
    tweet = tweet |> String.downcase |> String.replace("#", " ")
    cond do
      cur === :none -> send_tweet(0, pid, tweet, cur)
      String.match?(tweet, ~r"\s#{cur}\s") ->
        get_index(tweet, cur)
        |> send_tweet(pid, tweet, cur)
      :otherwise -> :ok
    end
  end

  defp send_tweet(i, pid, tweet, cur) do
    text = tweet
    |> String.replace(~r/[@#](\w*):?\s/, "\\g{1} ")
    |> String.replace(~r/\shttp.*\s/, "")
    |> String.split
    |> Enum.reject(fn(x) -> String.match?(x, ~r/[^\w\s-_]/) end)
    |> Enum.reject(fn(x) -> String.match?(x, ~r/http/) end)
    |> Enum.slice(i, 5)

    if length(text) > 1 do
        GenServer.cast(pid, {:check, text, cur})
    end
  end

  defp get_index(tweet, cur) do
    tweet
    |> String.split
    |> Enum.find_index(&(&1 === cur))
  end

  def init(:ok) do
    {:ok, %{cur: :none}}
  end

  def handle_call({:get_cur}, _from, state) do
    {:reply, state.cur, state}
  end


  def handle_cast({:check, text, cur}, state) do
    if cur === state.cur do
      new_cur = List.last(text)
      state = Map.put(state, :cur, new_cur)

      print(text)
    end

    {:noreply, state}
  end

  defp print(text) do
    text
    |> tl
    |> Enum.join(" ")
    |> IO.write
    IO.write " "
  end

end

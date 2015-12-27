defmodule Sinclair do
  use GenServer
  alias Sinclair.Tweets

  def start_link(opts \\ []) do
    GenServer.start_link __MODULE__, :ok, opts
  end

  def process(pid, tweet) do
    words = tweet
    |> String.downcase
    |> String.split
    GenServer.cast(pid, {:process, words})
  end

  # Server
  def init(:ok) do
    {:ok, stream} = Tweets.create_stream(:initial, self)
    {:ok, %{cur: :none, stream: stream}}
  end

  def handle_call({:get_cur}, state), do: {:reply, state.cur, state}
  def handle_cast({:process, words}, state = %{cur: :none}), do: send_tweet(0, words, state)
  def handle_cast({:process, words}, state) do
    if(state.cur in words) do
      Enum.find_index(words, &(&1 === state.cur))
      |> send_tweet(words, state)
    else
      {:noreply, state}
    end
  end

  defp send_tweet(i, words, state) do
    words
    |> Sinclair.Parser.filter_words(i)
    |> check(state)
  end

  defp check(:nomatch, state), do: {:noreply, state}
  defp check(words, state) when length(words) < 2, do: {:noreply, state}
  defp check(words, state) do
    if state.cur === :none do
      Tweets.end_stream(state.stream)
    end
    words
    |> tl
    |> Enum.join(" ")
    |> IO.puts
    {:ok, stream} = Tweets.create_stream(List.last(words), self)
    {:noreply, %{cur: List.last(words), stream: stream}}
  end


end

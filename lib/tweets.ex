defmodule Sinclair.Tweets do
  def create_stream(word, pid) do
    Task.start(fn ->
      stream_for_word(word)
      |> process_stream(pid)
    end)
  end

  def end_stream(pid) do
    ExTwitter.stream_control(pid, :stop)
  end

  defp stream_for_word(:initial), do: ExTwitter.stream_sample(language: "en")
  # defp stream_for_word(word), do: ExTwitter.stream_filter(language: "en", track: word)
  defp stream_for_word(word), do: ExTwitter.search(word, count: 20, language: "en")


  defp process_stream(stream, pid) do
    for tweet <- stream do
      Sinclair.process(pid, tweet.text)
    end
  end
end

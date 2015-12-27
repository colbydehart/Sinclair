defmodule Sinclair.Parser do
  def filter_words(words, i) do
    words
    |> Enum.map(&replace_links(&1))
    |> take_some(i, 5)
  end

  defp replace_links(word) do
    cond do
      String.contains?(word, "http") -> "<link>"
      String.match?(word, ~r/[^\w-_<>#@]/) -> nil
      :otherwise -> word
    end
  end

  defp take_some(words, i, num) when (i + num) > length(words), do: :nomatch
  defp take_some(words, i, num) do
    last_word = Enum.at words, i + num - 1
    cond do
      is_bitstring(last_word) and String.match?(last_word, ~r/^[a-zA-Z]*$/) ->
        words
        |> Enum.slice(i, num)
        |> Enum.filter(&(&1))
      :otherwise -> take_some(words, i, num + 1)
    end
  end
end

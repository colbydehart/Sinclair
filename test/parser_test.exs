defmodule SinclairTest.Parser do
  use ExUnit.Case
  alias Sinclair.Parser

  test "normal tweet" do
   assert get_result("this is a normal tweet") === ~w(this is a normal tweet)
  end

  test "remove links" do
    assert get_result("hey check out http://google.com this") === ~w(hey check out <link> this)
  end

  test "don't end in hashtags" do
   assert get_result("this is a really #normal tweet") === ~w(this is a really #normal tweet)
  end

  test "don't end in usernames" do
   assert get_result("this is a really @normal tweet") === ~w(this is a really @normal tweet)
  end

  test "don't end in links" do
   assert get_result("this is a really https://normal.com tweet") === ~w(this is a really <link> tweet)
  end

  test "get offset list" do
   assert get_result("offset of three this is a normal tweet", 3) === ~w(this is a normal tweet)
  end

  test "too short of string" do
   assert get_result("this is four words") === :nomatch
  end

  test "too short of string for offset" do
   assert get_result("this string is only six words", 2) === :nomatch
  end

  test "too short of string without ending on hashtag" do
   assert get_result("this string is only six #words", 1) === :nomatch
  end

  defp get_result(string, i \\ 0) do
    string
    |> String.split
    |> Parser.filter_words(i)
  end

end

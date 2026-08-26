defmodule Stlipsum.Generator do
  @moduledoc """
  Generates nonsense "STL ipsum" text from the word lists in priv/info,
  and lists the categories those word lists represent.
  """

  @info_dir "priv/info"

  def categories do
    :stlipsum
    |> Application.app_dir(@info_dir)
    |> File.ls!()
    |> Enum.sort()
    |> Enum.map(fn slug ->
      label = slug |> String.split("-") |> Enum.map_join(" ", &String.capitalize/1)
      {slug, label}
    end)
  end

  @doc """
  Generates `paragraphs` paragraphs, each with `sentences` sentences of
  `names` names, drawn from the given category slugs. Returns a list of
  `{heading, paragraph}` tuples; `heading` is `nil` when `headings?` is false.
  """
  def generate(opts) do
    pool = word_pool(opts[:categories] || [])
    names = max(opts[:names] || 15, 1)
    sentences = max(opts[:sentences] || 5, 1)
    paragraphs = max(opts[:paragraphs] || 5, 1)
    headings? = !!opts[:headings?]

    for _ <- 1..paragraphs do
      heading = if headings?, do: phrase(pool, Enum.random(3..6))
      body = Enum.map_join(1..sentences, " ", fn _ -> sentence(pool, names) end)
      {heading, body}
    end
  end

  defp word_pool([]), do: ["stlipsum"]

  defp word_pool(slugs) do
    slugs
    |> Enum.flat_map(fn slug ->
      :stlipsum
      |> Application.app_dir(Path.join(@info_dir, slug))
      |> File.read()
      |> case do
        {:ok, contents} -> String.split(contents, "\n", trim: true)
        {:error, _} -> []
      end
    end)
    |> case do
      [] -> ["stlipsum"]
      names -> names
    end
  end

  defp phrase(pool, count) do
    1..count
    |> Enum.map_join(" ", fn _ -> Enum.random(pool) end)
    |> capitalize_first()
  end

  defp sentence(pool, count) do
    punctuation = if :rand.uniform(7) == 1, do: "!", else: "."
    phrase(pool, count) <> punctuation
  end

  defp capitalize_first(<<first::utf8, rest::binary>>), do: String.upcase(<<first::utf8>>) <> rest
  defp capitalize_first(other), do: other
end

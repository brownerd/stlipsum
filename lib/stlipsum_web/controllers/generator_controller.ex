defmodule StlipsumWeb.GeneratorController do
  use StlipsumWeb, :controller

  alias Stlipsum.Generator

  @default_names 7
  @default_sentences 4
  @default_paragraphs 1

  # @max_names 50
  # @max_sentences 50
  # @max_paragraphs 50

  @max_names 15
  @max_sentences 10
  @max_paragraphs 5


  def index(conn, params) do
    valid_slugs = MapSet.new(Generator.categories(), fn {slug, _label} -> slug end)

    names = int_param(params, "names", @default_names, 1, @max_names)
    sentences = int_param(params, "sentences", @default_sentences, 1, @max_sentences)
    paragraphs = int_param(params, "paragraphs", @default_paragraphs, 1, @max_paragraphs)
    headings? = bool_param(params, "headings", true)
    categories = category_param(params, valid_slugs)

    entries =
      Generator.generate(
        names: names,
        sentences: sentences,
        paragraphs: paragraphs,
        headings?: headings?,
        categories: categories
      )

    json(conn, %{
      paragraphs: Enum.map(entries, fn {heading, body} -> %{heading: heading, body: body} end),
      meta: %{
        names: names,
        sentences: sentences,
        paragraphs: paragraphs,
        headings: headings?,
        categories: categories
      }
    })
  end

  defp int_param(params, key, default, min, max) do
    case Integer.parse(Map.get(params, key, "")) do
      {int, _} -> int |> max(min) |> min(max)
      :error -> default
    end
  end

  defp bool_param(params, key, default) do
    case Map.get(params, key) do
      nil -> default
      value -> value in ["true", "1", "on"]
    end
  end

  defp category_param(params, valid_slugs) do
    case Map.get(params, "categories") do
      nil ->
        MapSet.to_list(valid_slugs)

      value ->
        value
        |> String.split(",", trim: true)
        |> Enum.filter(&MapSet.member?(valid_slugs, &1))
    end
  end
end

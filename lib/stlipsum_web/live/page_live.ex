defmodule StlipsumWeb.PageLive do
  use StlipsumWeb, :live_view

  alias Stlipsum.Generator

  @default_names 9
  @default_sentences 5
  @default_paragraphs 1

  @max_names 15
  @max_sentences 10
  @max_paragraphs 5


  def mount(_params, _session, socket) do
    categories = Generator.categories()
    selected = MapSet.new(categories, fn {slug, _label} -> slug end)

    socket =
      socket
      |> assign(
        categories: categories,
        selected_categories: selected,
        names: @default_names,
        sentences: @default_sentences,
        paragraphs: @default_paragraphs,
        max_names: @max_names,
        max_sentences: @max_sentences,
        max_paragraphs: @max_paragraphs,
        headings?: true,
        theme: "stl"
      )
      |> regenerate()

    {:ok, socket}
  end

  def handle_event("update", params, socket) do
    selected =
      params
      |> Map.get("categories", [])
      |> MapSet.new()

    socket =
      socket
      |> assign(
        names: int_param(params, "names", socket.assigns.names),
        sentences: int_param(params, "sentences", socket.assigns.sentences),
        paragraphs: int_param(params, "paragraphs", socket.assigns.paragraphs),
        headings?: Map.get(params, "headings", "on") == "on",
        theme: Map.get(params, "theme", socket.assigns.theme),
        selected_categories: selected
      )
      |> regenerate()

    {:noreply, socket}
  end

  defp regenerate(socket) do
    entries =
      Generator.generate(
        names: socket.assigns.names,
        sentences: socket.assigns.sentences,
        paragraphs: socket.assigns.paragraphs,
        headings?: socket.assigns.headings?,
        categories: MapSet.to_list(socket.assigns.selected_categories)
      )

    assign(socket, entries: entries)
  end

  defp int_param(params, key, default) do
    case Integer.parse(Map.get(params, key, "")) do
      {int, _} -> int
      :error -> default
    end
  end
end

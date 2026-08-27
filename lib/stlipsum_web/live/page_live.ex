defmodule StlipsumWeb.PageLive do
  use StlipsumWeb, :live_view

  alias Stlipsum.Generator

  @default_names 7
  @default_sentences 4
  @default_paragraphs 1

  @max_names 15
  @max_sentences 10
  @max_paragraphs 5

  @theme %{
    "default" => %{
      "primary" => "#333333",
      "secondary" => "#ffffff",
      "accent" => "#00ffcc",
      "text" => "#333333"
    },
    "cardinals" => %{
      "primary" => "#C41E3A",
      "secondary" => "#0C2340",
      "accent" => "#FEDB00",
      "text" => "#ffffff"
    },
    "stlsc" => %{
      "primary" => "#DD004A",
      "secondary" => "#0C2340",
      "accent" => "#ffffff",
      "text" => "#ffffff"
    },
    "blues" => %{
      "primary" => "#002F87",
      "secondary" => "#041E42",
      "accent" => "#FCB514",
      "text" => "#ffffff"
    },
   "slu" => %{
      "primary" => "#264396",
      "secondary" => "#c9c9c7",
      "accent" => "#ffffff",
      "text" => "#264396"
    },
    "washu" => %{
      "primary" => "#b12435",
      "secondary" => "#ffffff",
      "accent" => "#000000",
      "text" => "#2a634a"
    }
  }


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
        theme: "default",
        theme_colors: colors_for("default")
      )
      |> regenerate()

    {:ok, socket}
  end

  def handle_event("update", params, socket) do
    selected =
      params
      |> Map.get("categories", [])
      |> MapSet.new()

    theme = Map.get(params, "theme", socket.assigns.theme)

    socket =
      socket
      |> assign(
        names: int_param(params, "names", socket.assigns.names),
        sentences: int_param(params, "sentences", socket.assigns.sentences),
        paragraphs: int_param(params, "paragraphs", socket.assigns.paragraphs),
        headings?: Map.get(params, "headings", "on") == "on",
        theme: theme,
        theme_colors: colors_for(theme),
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

  defp colors_for(theme), do: Map.get(@theme, theme, @theme["default"])
end

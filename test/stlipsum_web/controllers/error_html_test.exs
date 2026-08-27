defmodule StlipsumWeb.ErrorHTMLTest do
  use StlipsumWeb.ConnCase, async: true

  # Bring render_to_string/4 for testing custom views
  import Phoenix.Template, only: [render_to_string: 4]

  test "renders 404.html" do
    html = render_to_string(StlipsumWeb.ErrorHTML, "404", "html", [])
    assert html =~ "404"
    assert html =~ "background-color: #333333"
    assert html =~ "color: #ffffff"
  end

  test "renders 500.html" do
    assert render_to_string(StlipsumWeb.ErrorHTML, "500", "html", []) == "Internal Server Error"
  end
end

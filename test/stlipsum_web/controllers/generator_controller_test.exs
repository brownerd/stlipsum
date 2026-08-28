defmodule StlipsumWeb.GeneratorControllerTest do
  use StlipsumWeb.ConnCase, async: true

  test "GET /api/generate returns the requested counts", %{conn: conn} do
    conn = get(conn, ~p"/api/generate?names=3&sentences=2&paragraphs=2")

    assert %{
             "paragraphs" => paragraphs,
             "meta" => %{"names" => 3, "sentences" => 2, "paragraphs" => 2}
           } = json_response(conn, 200)

    assert length(paragraphs) == 2

    for %{"body" => body} <- paragraphs do
      assert is_binary(body) and body != ""
    end
  end

  test "GET /api/generate defaults invalid integers and clamps out-of-range ones", %{conn: conn} do
    conn = get(conn, ~p"/api/generate?names=abc&paragraphs=9999")

    assert %{"meta" => %{"names" => 7, "paragraphs" => 5}} = json_response(conn, 200)
  end

  test "GET /api/generate ignores unknown or malicious category slugs", %{conn: conn} do
    conn = get(conn, ~p"/api/generate?categories=blues,../../etc/passwd")

    assert %{"meta" => %{"categories" => ["blues"]}} = json_response(conn, 200)
  end

  test "GET /api/generate omits headings when disabled", %{conn: conn} do
    conn = get(conn, ~p"/api/generate?headings=false")

    assert %{"paragraphs" => [%{"heading" => nil} | _]} = json_response(conn, 200)
  end
end

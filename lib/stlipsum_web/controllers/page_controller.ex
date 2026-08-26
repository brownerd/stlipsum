defmodule StlipsumWeb.PageController do
  use StlipsumWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end

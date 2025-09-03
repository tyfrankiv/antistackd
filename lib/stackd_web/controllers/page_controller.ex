defmodule StackdWeb.PageController do
  use StackdWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end

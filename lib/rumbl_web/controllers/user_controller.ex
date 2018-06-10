defmodule RumblWeb.UserController do
  use RumblWeb, :controller
  alias Rumbl.Account
  alias Rumbl.Account.User

  def index(conn, _params) do
    users = Account.list_users()
    render(conn, "index.html", users: users)
  end

  def show(conn, %{"id" => id}) do
    user = Account.get_user(id)
    render(conn, "show.html", user: user)
  end

  def new(conn, _params) do
    changeset = Account.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end
end

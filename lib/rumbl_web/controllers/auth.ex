defmodule RumblWeb.Auth do
  import Plug.Conn
  alias Rumbl.Account

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user = user_id && Account.get_user(user_id)
    assign(conn, :current_user, user)
  end
end

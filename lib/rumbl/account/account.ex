defmodule Rumbl.Account do
  @moduledoc """
  The Account context.
  """

  alias Rumbl.Account.User
  alias Rumbl.Repo

  def list_users do
    User
    |> Repo.all()
  end

  def get_user(id) do
    User
    |> Repo.get(id)
  end

  def get_user_by(params) do
    User
    |> Repo.get_by(params)
  end
end

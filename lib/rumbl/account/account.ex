defmodule Rumbl.Account do
  @moduledoc """
  The Account context.
  """

  alias Rumbl.Account.User
  alias Rumbl.Repo
  alias Rumbl.Account.Credential

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

  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def register_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end
end

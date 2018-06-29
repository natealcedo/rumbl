defmodule Rumbl.AccountTest do
  use Rumbl.DataCase

  alias Rumbl.Account
  alias Rumbl.Account.User

  describe "register_user/2" do
    @valid_attrs %{
      name: "User",
      username: "eva",
      credential: %{email: "eva@test.com", password: "secret"}
    }
    @invalid_attrs %{}

    test "with valid data, inserts user" do
      assert {:ok, %User{id: id} = user} = Account.register_user(@valid_attrs)
      assert user.name == "User"
      assert user.username == "eva"
      assert user.credential.email == "eva@test.com"
      assert [%User{id: ^id}] = Account.list_users()
    end

    test "with invalid data, does not insert user" do
      assert {:error, _changeset} = Account.register_user(@invalid_attrs)
      assert Account.list_users() == []
    end

    test "enforces unique usernames" do
      assert {:ok, %User{id: id}} = Account.register_user(@valid_attrs)
      assert {:error, changeset} = Account.register_user(@valid_attrs)
      assert %{username: ["has already been taken"]} = errors_on(changeset)
      assert [%User{id: ^id}] = Account.list_users()
    end

    test "does not accept long usersnames" do
      attrs = Map.put(@valid_attrs, :username, String.duplicate("a", 30))
      {:error, changeset} = Account.register_user(attrs)
      assert %{username: ["should be at most 20 character(s)"]} = errors_on(changeset)
      assert Account.list_users() == []
    end

    test "requires password to be at least 6 chars long" do
      attrs = put_in(@valid_attrs, [:credential, :password], "12345")
      {:error, changeset} = Account.register_user(attrs)

      assert %{password: ["should be at least 6 character(s)"]} =
               errors_on(changeset)[:credential]

      assert Account.list_users() == []
    end
  end

  describe "authenticate_by_email_and_pass/2" do
    @email "user@localhost"
    @pass "123456"

    setup do
      {:ok, user: user_fixture(%{credential: %{password: @pass, email: @email}})}
    end

    test "returns user with correct password", %{user: %User{id: id}} do
      assert {:ok, %User{id: ^id}} = Account.authenticate_by_email_and_pass(@email, @pass)
    end

    test "returns unauthorized error with invalid password" do
      assert {:error, :unauthorized} = Account.authenticate_by_email_and_pass(@email, "badpass")
    end

    test "returns not found error with no matching user for email" do
      assert {:error, :not_found} =
               Account.authenticate_by_email_and_pass("badEmail@localhost", @pass)
    end
  end
end

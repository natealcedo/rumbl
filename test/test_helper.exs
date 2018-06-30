ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Rumbl.Repo, :manual)

defmodule Rumbl.TestHelpers do
  alias Rumbl.{
    Account,
    Multimedia
  }

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        name: "Some User",
        username: "user#{System.unique_integer([:positive])}",
        credential: %{
          email: "random@localhost",
          password: "supersecret"
        }
      })
      |> Account.register_user()

    user
  end

  def video_fixture(%Account.User{} = user, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        url: "http://example.com",
        description: "a description",
        title: "some title"
      })

    {:ok, video} = Multimedia.create_video(user, attrs)
    video
  end
end

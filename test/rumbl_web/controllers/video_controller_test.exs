defmodule RumblWeb.VideoControllerTest do
  use RumblWeb.ConnCase
  alias Rumbl.Multimedia

  @create_attrs %{url: "http://youtu.be", description: "a video", title: "valid title"}
  @invalid_attrs %{description: "invalid"}

  defp video_count, do: Enum.count(Multimedia.list_videos())

  describe "with a logged in user" do
    setup %{conn: conn, login_as: username} do
      user = user_fixture(username: username)
      conn = assign(conn, :current_user, user)
      {:ok, conn: conn, user: user}
    end

    @tag login_as: "max"
    test "lists all user's videos on index", %{conn: conn, user: user} do
      user_video = video_fixture(user, title: "funny cats")

      other_video =
        user_fixture(
          username: "other",
          credential: create_credential()
        )
        |> video_fixture(title: "another video")

      conn = get(conn, video_path(conn, :index))
      assert html_response(conn, 200) =~ ~r/Listing Videos/
      assert String.contains?(conn.resp_body, user_video.title)
      refute String.contains?(conn.resp_body, other_video.title)
    end

    @tag login_as: "max"
    test "creates user video and redirects", %{conn: conn, user: user} do
      create_conn = post(conn, video_path(conn, :create), video: @create_attrs)

      assert %{id: id} = redirected_params(create_conn)
      assert redirected_to(create_conn) == video_path(create_conn, :show, id)

      conn = get(conn, video_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Video"

      assert Multimedia.get_user_video!(user, id).user_id == user.id
    end

    @tag login_as: "max"
    test "does not create video and renders errors when invalid", %{conn: conn, user: user} do
      count_before = video_count()
      conn = post(conn, video_path(conn, :create), video: @invalid_attrs)
      assert html_response(conn, 200) =~ "check the errors"
      assert video_count() == count_before
    end
  end

  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each(
      [
        get(conn, video_path(conn, :new)),
        get(conn, video_path(conn, :index)),
        get(conn, video_path(conn, :show, "123")),
        get(conn, video_path(conn, :edit, "123")),
        put(conn, video_path(conn, :update, "123", %{})),
        post(conn, video_path(conn, :create, %{})),
        delete(conn, video_path(conn, :delete, "123"))
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end
    )
  end

  test "authorizes actions against access by other users", %{conn: conn} do
    owner =
      user_fixture(
        username: "owner",
        credential: create_credential(email: "random_email@localhost")
      )

    video = video_fixture(owner, @create_attrs)

    non_owner =
      user_fixture(
        username: "non_owner",
        credential: create_credential(email: "non_owner@localhost")
      )

    conn = assign(conn, :current_user, non_owner)

    assert_error_sent(:not_found, fn ->
      get(conn, video_path(conn, :show, video))
    end)

    assert_error_sent(:not_found, fn ->
      get(conn, video_path(conn, :edit, video))
    end)

    assert_error_sent(:not_found, fn ->
      put(conn, video_path(conn, :update, video, video: @create_attrs))
    end)

    assert_error_sent(:not_found, fn ->
      delete(conn, video_path(conn, :delete, video))
    end)
  end
end

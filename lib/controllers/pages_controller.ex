defmodule FeedRegression.PagesController do
  @doc """
  Gets the information related to the page_id.
  This info includes: id, fan count and about.
  """
  def page_info(conn, page_id) do
    { :ok, access_token } = facebook_access_token(conn)

    { _, content } = Facebook.page(page_id, access_token, "id,fan_count,about")

    content
  end

  @doc """
  Gets the posts of a Facebook page.
  """
  def page_posts(conn, page_id) do
      { :ok, access_token } = facebook_access_token(conn)

      response = Facebook.pageFeed(:posts,
          page_id,
          access_token,
          100,
          "id,message,link")

      response["data"]
  end

  def post_statistics(conn, post_id) do
    { :ok, access_token } = facebook_access_token(conn)

    comments = fn map ->
        IO.inspect map

      count = Facebook.objectCount(:comments, post_id, access_token)

      Map.put map, :comments, count
    end

    likes = fn map ->
        IO.inspect map

      count = Facebook.objectCount(:likes, post_id, access_token)

      Map.put map, :likes, count
    end

    wows = fn map ->
        IO.inspect map

      count = Facebook.objectCount(:reaction, :wow, post_id, access_token)

      Map.put map, :wow, count
    end

    comments.(%{})
      |> likes.()
      |> count_reaction(:wow, post_id, access_token)
      |> count_reaction(:haha, post_id, access_token)
      |> count_reaction(:sad, post_id, access_token)
      |> count_reaction(:thankful, post_id, access_token)
      |> count_reaction(:angry, post_id, access_token)
      |> count_reaction(:love, post_id, access_token)
  end

  def count_reaction(map, reaction, post_id, access_token) when is_atom(reaction)  do
    count = Facebook.objectCount(:reaction, reaction, post_id, access_token)

    Map.put(map, reaction, count)
  end

  def statistics_map(statistic, map, scope) do
    case scope do
      :comments -> %{ map | :comments => statistic }
      :likes -> %{ map | :likes => statistic }
      _ -> map
    end
  end

  # Gets the 'access_token' header from the request headers in the connection.
  defp facebook_access_token(conn) do
    header = fn
      [{"access_token", auth_header}] -> { :ok, auth_header }
      [] -> { :error, "Facebook access token was not provided" }
    end

    IO.inspect conn.req_headers
      |> Enum.filter(fn ({key, _}) -> key == "access_token" end)
      |> header.()
  end
end

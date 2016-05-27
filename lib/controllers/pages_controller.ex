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
          10,
          "id,message,link,created_time")

      response["data"]
  end

  @doc """
  Gets the posts of a Facebook page and add the statistics for each post.
  Statistics stands for the number of likes, comments and reactions a post has.
  """
  def page_posts_with_statistics(conn, page_id) do
    page_posts(conn, page_id)
      |> Enum.map(fn (post) -> add_post_statistics(conn, post) end)
  end

  def add_post_statistics(conn, post) do
    post_id = post["id"]
    statistics = post_statistics(conn, post_id)

    Map.put post, :statistics, statistics
  end

  @doc """
  Gets the statistics of a given post.
  Statistics stands for the number of likes, comments and reactions a post has.
  """
  def post_statistics(conn, post_id) do
    { :ok, access_token } = facebook_access_token(conn)

    %{}
      |> count_reaction(:likes, post_id, access_token)
      |> count_reaction(:comments, post_id, access_token)
      |> count_reaction(:wow, post_id, access_token)
      |> count_reaction(:haha, post_id, access_token)
      |> count_reaction(:sad, post_id, access_token)
      |> count_reaction(:thankful, post_id, access_token)
      |> count_reaction(:angry, post_id, access_token)
      |> count_reaction(:love, post_id, access_token)
  end

  @doc """
  Gets the count of a given reaction of a post.
  """
  def count_reaction(map, reaction, post_id, access_token) when is_atom(reaction)  do
    count = case reaction do
      :likes -> Facebook.objectCount(:likes, post_id, access_token)
      :comments -> Facebook.objectCount(:comments, post_id, access_token)
      _ -> Facebook.objectCount(:reaction, reaction, post_id, access_token)
    end

    Map.put(map, reaction, count)
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

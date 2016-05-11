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

defmodule FeedRegression.API do
  use Maru.Router

  mount FeedRegression.Router.Page

  rescue_from :all do
    conn
      |> put_status(500)
      |> text("Server Error")
  end
end

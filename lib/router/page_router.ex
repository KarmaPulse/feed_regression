defmodule FeedRegression.Router.Page do
  use Maru.Router

  get do
    json(conn, %{ hello: :world })
  end
end

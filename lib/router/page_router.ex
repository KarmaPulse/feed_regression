defmodule FeedRegression.Router.Page do
  use Maru.Router

  namespace :pages do
    route_param :page_id do
      get do
        json(conn, %{ hello: "#{params[:page_id]}" })
      end
    end
  end
end

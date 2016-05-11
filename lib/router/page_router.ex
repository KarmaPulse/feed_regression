defmodule FeedRegression.Router.Page do
  use Maru.Router

  namespace :pages do
    route_param :page_id do
      get do
        info = conn
          |> FeedRegression.PagesController.page_info(params[:page_id])

        conn
          |> json(info)
      end
    end
  end
end

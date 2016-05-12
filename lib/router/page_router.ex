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

      namespace :posts do
        route_param :post_id do
          namespace :statistics do
            get do
              statistics = conn
                |> FeedRegression.PagesController.post_statistics(params[:post_id])

              conn |> json(statistics)
            end
          end
        end


        get do
          posts = conn
            |> FeedRegression.PagesController.page_posts(params[:page_id])

          conn
            |> json(posts)
        end
      end
    end
  end
end

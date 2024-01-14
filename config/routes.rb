Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      get '/kline', to: 'api_data#kline'
      get '/openinterest', to: 'api_data#openinterest'
    end
  end
end
Rails.application.routes.draw do
  get 'api_data/entries'
  namespace :api do
    namespace :v1 do
      get '/kline', to: 'api_data#entries'
      get '/openinterest', to: 'api_data#openinterest'
    end
  end
end

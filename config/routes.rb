Rails.application.routes.draw do
  get 'api_data/entries'
  namespace :api do
    namespace :v1 do
      get '/entries', to: 'api_data#entries'
    end
  end
end

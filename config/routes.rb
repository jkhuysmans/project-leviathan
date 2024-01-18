Rails.application.routes.draw do
  # Define the routes directly at the top level without namespacing
  get '/kline', to: 'api/v1/api_data#kline', defaults: { format: :json }
  get '/openinterest', to: 'api/v1/api_data#openinterest', defaults: { format: :json }
end
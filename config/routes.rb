Rails.application.routes.draw do
  # Define the routes directly at the top level without namespacing
  get '/kline', to: 'api/v1/api_data#kline', defaults: { format: :json }
  get '/open_interest', to: 'api/v1/api_data#open_interest', defaults: { format: :json }
end
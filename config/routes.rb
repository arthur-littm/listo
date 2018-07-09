Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  get '/auth/spotify/callback', to: 'users#spotify'
end

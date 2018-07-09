Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  root to: 'pages#home'
  get '/auth/spotify/callback', to: 'users/omniauth_callbacks#spotify'
end

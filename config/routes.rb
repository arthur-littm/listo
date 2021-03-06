require "sidekiq/web"

Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  root to: 'pages#home'

  get '/search', to: "pages#search", as: :search

  get '/auth/spotify/callback', to: 'users/omniauth_callbacks#spotify'

  get '/:id/successful', to: 'pages#successful', as: :successful

  post '/playlist_create', to: 'pages#playlist_create', as: :playlist

  get '/:festival_id/artists', to: 'pages#artists', as: :artists

  authenticate :user, lambda { |u| u.admin } do
    mount Sidekiq::Web => '/sidekiq'
  end

end

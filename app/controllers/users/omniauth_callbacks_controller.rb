class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :authenticate_user!, only: [:spotify]

  def spotify
    spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
    user = User.from_omniauth(request.env["omniauth.auth"])
    user.spotify_hash = spotify_user.to_hash
    user.save

    if user.persisted?
      sign_in_and_redirect user, event: :authentication
      set_flash_message(:notice, :success, kind: 'Spotify') if is_navigational_format?
    else
      session['devise.spotify_data'] = request.env['omniauth.auth']
      redirect_to new_user_registration_url
    end
  end
end

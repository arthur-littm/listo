class User < ApplicationRecord
  serialize :spotify_hash, JSON
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
     :recoverable, :rememberable, :trackable, :validatable,
  :omniauthable, :omniauth_providers => [:spotify]

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = auth.info.email
      user.name = auth.info.display_name
      user.spotify_photo_url = auth.info.images.first.url
      user.password = Devise.friendly_token[0,20]
    end
  end

  def name_or_email
    self.name || self.email
  end
end

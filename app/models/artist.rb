class Artist < ApplicationRecord
  has_many :festival_artists
  has_many :festival, through: :festival_artists
end

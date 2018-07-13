class Artist < ApplicationRecord
  has_many :festival_artists
  has_many :festival, through: :festival_artists

  validates :name, uniqueness: true
  validates :name, presence: true
end

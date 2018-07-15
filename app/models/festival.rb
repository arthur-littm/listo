class Festival < ApplicationRecord
  include PgSearch
  pg_search_scope :search_by_festival_name,
    against: [ :name ],
    using: {
      tsearch: { prefix: true }
    }
  has_many :festival_artists
  has_many :artists, through: :festival_artists
  belongs_to :city

  validates :name, uniqueness: { scope: :year }
  validates :name, :year, presence: true
end

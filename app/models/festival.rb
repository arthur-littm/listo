class Festival < ApplicationRecord
  include PgSearch
  pg_search_scope :search_by_festival_name,
    against: [ :name ],
    using: {
      tsearch: { prefix: true }
    }
  has_many :festival_artists
  has_many :artists, through: :festival_artists
end

class FestivalArtist < ApplicationRecord
  belongs_to :artist
  belongs_to :festival
end

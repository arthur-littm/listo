require "open-uri"

class City < ApplicationRecord
  has_many :festival

  validates :name, uniqueness: true
  validates :name, :country, :lng, :lat, presence: true

  after_save :async_update # Run on create & update

  def async_update
    RefreshFestivalsJob.perform_later
  end

  def refresh_festivals
    search_festivals
  end

  private

  def search_festivals
    # Call API
    page_num = 1
    api = "https://api.songkick.com/api/3.0/events.json?apikey=#{ENV['songkick_api_key']}&type=Festival&location=geo:#{lat},#{lng}&page=#{page_num}"
    response = JSON.parse(open(api).read)
    found = response["resultsPage"]["totalEntries"]
    pages = (found / response["resultsPage"]["perPage"]).to_i
    puts "Found #{found} results on Songkick - #{pages} pages"
    if pages > 1
      pages.times do
        call_api(page_num)
        page_num += 1
      end
    else
      call_api(page_num)
    end
  end

  def call_api(page_num)
    api = "https://api.songkick.com/api/3.0/events.json?apikey=#{ENV['songkick_api_key']}&type=Festival&location=geo:#{lat},#{lng}&page=#{page_num}"
    response = JSON.parse(open(api).read)

    # List of events found
    events = response["resultsPage"]["results"]["event"]
    events.each do |event|
      name = event["displayName"]
      festival = Festival.where("name iLIKE ?", "%#{name}%").first
      # If new festival create it
      if festival.nil? && event["performance"].length > 2
        year = Date.parse(event["start"]["date"]).year
        festival = Festival.new(name: name, year: year)
        puts "Created #{festival.name} 🎉" if festival.save
      end

      if !festival.nil? && festival.city.nil?
        festival.update(city: self)
      end
      # Load the artists from that festival
      get_artists_of(festival, event)
    end
  end

  def get_artists_of(festival, event_from_songkick)
    artists = event_from_songkick["performance"].map { |h| h["displayName"] }
    artists.each do |artist_name|
      artist = Artist.where("name iLIKE ?", "%#{artist_name}%").first
      if artist.nil?
        artist = Artist.create(name: artist_name)
        new_one = "- [🆕 ARTIST]"
      end
      puts " - with #{artist.name} 🎤 #{new_one}"
      # Link the artist with that festival
      FestivalArtist.create(artist: artist, festival: festival)
    end
  end

end

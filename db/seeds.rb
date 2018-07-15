require "open-uri"
require "json"

def get_festivals_of(city)
  # Call API
  page_num = 1
  api = "https://api.songkick.com/api/3.0/events.json?apikey=#{ENV['songkick_api_key']}&type=Festival&location=geo:#{city.lat},#{city.lng}&page=#{page_num}"
  response = JSON.parse(open(api).read)
  found = response["resultsPage"]["totalEntries"]
  pages = (found / response["resultsPage"]["perPage"]).to_i
  puts "Found #{found} results on Songkick - #{pages} pages"
  if pages > 1
    pages.times do
      call_api(city, page_num)
      page_num += 1
    end
  else
    call_api(city, page_num)
  end
end

def call_api(city, page_num)
  api = "https://api.songkick.com/api/3.0/events.json?apikey=#{ENV['songkick_api_key']}&type=Festival&location=geo:#{city.lat},#{city.lng}&page=#{page_num}"
  response = JSON.parse(open(api).read)

  # List of events found
  events = response["resultsPage"]["results"]["event"]
  events.each do |event|
    name = event["displayName"]
    festival = Festival.where("name iLIKE ?", "%#{name}%").first
    # If new festival create it
    if festival.nil? && event["performance"].length > 2
      year = Date.parse(event["start"]["date"]).year
      festival = Festival.new(name: name, year: year, city: city)
      puts "Created #{festival.name} 🎉" if festival.save
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

# LONDON ✅
london = City.create(name: "London", country: "United Kingdom", lat: "51.50", lng: "-0.11")
# get_festivals_of(london)

# PARIS ✅
paris = City.create(name: "Paris", country: "France", lat: "48.85", lng: "2.34")
# get_festivals_of(paris)

# BERLIN ✅
berlin = City.create(name: "Berlin", country: "Germany", lat: "52.52", lng: "13.40")
# get_festivals_of(berlin)

# MARSEILLE
marseille = City.create(name: "Marseille", country: "France", lat: "43.30", lng: "5.40")
# get_festivals_of(marseille)

# EDINBURGH
edinburgh = City.create(name: "Edinburgh", country: "United Kingdom", lat: "55.95", lng: "-3.18")
# get_festivals_of(edinburgh)

# LIVERPOOL
liverpool = City.create(name: "Liverpool", country: "United Kingdom", lat: "53.41", lng: "-2.97")
# get_festivals_of(liverpool)

# MANCHESTER
manchester = City.create(name: "Manchester", country: "United Kingdom", lat: "53.48", lng: "-2.24")
# get_festivals_of(manchester)

# NEW ORLEANS
new_orleans = City.create(name: "New Orleans", country: "United States", lat: "29.95", lng: "-90.07")
# get_festivals_of(new_orleans)

# AUSTIN
austin = City.create(name: "Austin", country: "United States", lat: "30.14", lng: "-97.83")
# get_festivals_of(austin)

# BRISTOL
bristol = City.create(name: "Bristol", country: "United Kingdom", lat: "51.45", lng: "-2.58")
# get_festivals_of(bristol)

# CLEANING METHODS
def clean_festival_with_low_number_of_artists
  puts "Clean DB of useless festivals"
  Festival.all.each do |festival|
    if festival.artists.count <= 2
      name = festival.name
      festival.festival_artists.destroy_all
      festival.destroy
      puts " - #{name} 👋"
    end
  end
end

# clean_festival_with_low_number_of_artists


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

def create_city(name, country)
  api = "https://api.songkick.com/api/3.0/search/locations.json?query=#{name}&apikey=#{ENV['songkick_api_key']}"
  response = JSON.parse(open(api).read)

  return "No results" if response["resultsPage"]["results"].empty?

  city_hash = response["resultsPage"]["results"]["location"].find do |city_songkick|
    city_songkick["city"]["country"]["displayName"] == country
  end

  if city_hash.nil?
    puts "CITY info not found"
  else
    city = City.where(name: city_hash["city"]["displayName"]).first
    if city.nil?
      # binding.pry
      city = City.create(name: city_hash["city"]["displayName"], country: city_hash["city"]["country"]["displayName"], lat: city_hash["city"]["lat"], lng: city_hash["city"]["lng"])
      puts "Create new city #{city.name}"
      get_festivals_of(city)
    end
  end
end

def get_city_info(name)
  api = "https://api.songkick.com/api/3.0/search/locations.json?query=#{name}&apikey=#{ENV['songkick_api_key']}"
  response = JSON.parse(open(api).read)

  p response
end

# get_city_info("melbourne")

cities = [
  { name: "London", country: "UK" },
  { name: "Bristol", country: "UK" },
  { name: "Manchester", country: "UK" },
  { name: "Liverpool", country: "UK" },
  { name: "Sheffield", country: "UK" },
  { name: "Edinburgh", country: "UK" },
  { name: "Birghton", country: "UK" },
  { name: "Leeds", country: "UK" },
  { name: "Glasgow", country: "UK" },
  { name: "Leicester", country: "UK" },
  { name: "Nottingham", country: "UK" },
  { name: "Hackney", country: "UK" },
  { name: "Paris", country: "France" },
  { name: "Marseille", country: "France" },
  { name: "Bordeaux", country: "France" },
  { name: "Berlin", country: "Germany" },
  { name: "New Orleans", country: "US" },
  { name: "Austin", country: "US" },
  { name: "New York", country: "US" },
  { name: "Miami", country: "US" },
  { name: "Boston", country: "US" },
  { name: "Nashville", country: "US" },
  { name: "Atlanta", country: "US" },
  { name: "Milan", country: "Italy" },
  { name: "Torino", country: "Italy" },
  { name: "Melbourne", country: "Australia" },
  { name: "Perth", country: "Australia" },
  { name: "Sydney", country: "Australia" }
]

cities.each do |city_info|
  create_city(city_info[:name], city_info[:country])
end

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

clean_festival_with_low_number_of_artists


# def get_artists(search)
#   festival = Festival.search_by_festival_name(search).first
#   if festival.nil?
#     festival = create_festival_from_songkick(search)
#   end
#   return festival.artists
# end

# def create_festival_from_songkick(name)
#   require 'open-uri'
#   base_url = "https://www.songkick.com"
#   url = "#{base_url}/search?page=1&query=#{name}&type=upcoming"
#   doc = Nokogiri::HTML(open(url))
#   festival = doc.search(".event.festival-instance").first
#   festival_url = base_url + festival.search(".summary > a").attr("href")
#   festival_doc = Nokogiri::HTML(open(festival_url))
#   festival_name = festival_doc.search('h1').text.strip
#   festival_year = festival_name[/\d{4}/, 1] || Date.today.year
#   f = Festival.create(name: festival_name, year: festival_year)
#   puts "Created: #{f.name} #{f.year}"
#   festival_doc.search("#lineup .festival li").first(10).each do |list_item|
#     a = Artist.find_or_create_by(name: list_item.text.strip)
#     puts " - #{a.name} 🎤"
#     FestivalArtist.create(artist: a, festival: f)
#   end
#   return f
# end

# get_artists("lovebox")
# get_artists("mad cool")
# get_artists("dgtl 2018")
require "open-uri"
require "json"

def get_festivals_of(lat,long)
  # Call API
  page_num = 1
  api = "https://api.songkick.com/api/3.0/events.json?apikey=#{ENV['songkick_api_key']}&type=Festival&location=geo:#{lat},#{long}&page=#{page_num}"
  response = JSON.parse(open(api).read)
  found = response["resultsPage"]["totalEntries"]
  pages = (found / response["resultsPage"]["perPage"]).to_i
  puts "Found #{found} results on Songkick"

  pages.times do
    api = "https://api.songkick.com/api/3.0/events.json?apikey=#{ENV['songkick_api_key']}&type=Festival&location=geo:#{lat},#{long}&page=#{page_num}"
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
      # Load the artists from that festival
      get_artists_of(festival, event)
    end
    page_num += 1
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

get_festivals_of(51.50, -0.11)





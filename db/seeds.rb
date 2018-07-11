def get_artists(search)
  festival = Festival.search_by_festival_name(search).first
  if festival.nil?
    festival = create_festival_from_songkick(search)
  end
  return festival.artists
end

def create_festival_from_songkick(name)
  require 'open-uri'
  base_url = "https://www.songkick.com"
  url = "#{base_url}/search?page=1&query=#{name}&type=upcoming"
  doc = Nokogiri::HTML(open(url))
  festival = doc.search(".event.festival-instance").first
  festival_url = base_url + festival.search(".summary > a").attr("href")
  festival_doc = Nokogiri::HTML(open(festival_url))
  festival_name = festival_doc.search('h1').text.strip
  festival_year = festival_name[/\d{4}/, 1] || Date.today.year
  f = Festival.create(name: festival_name, year: festival_year)
  puts "Created: #{f.name} #{f.year}"
  festival_doc.search("#lineup .festival li").first(10).each do |list_item|
    a = Artist.find_or_create_by(name: list_item.text.strip)
    puts " - #{a.name} 🎤"
    FestivalArtist.create(artist: a, festival: f)
  end
  return f
end

get_artists("lovebox")
get_artists("mad cool")
get_artists("dgtl 2018")

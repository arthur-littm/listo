def scrape_songkick(search)
  base_url = "https://www.songkick.com"
  url = "#{base_url}/search?page=1&query=#{search}&type=upcoming"
  doc = Nokogiri::HTML(open(url).read)
  festival = doc.search(".event.festival-instance").first
  festival_url = base_url + festival.search(".summary > a").attr("href")
  festival_doc = Nokogiri::HTML(open(festival_url).read)
  artists = []
  festival_doc.search("#lineup .festival li").each do |list_item|
    artists << list_item.text.strip
  end
  return artists
end

p scrape_songkick("lovebox")

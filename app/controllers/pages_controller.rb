class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
  end

  def artists
    load_artists(scrape_songkick(params[:searched_event]))
  end

  def playlist_create
    spotify_user = RSpotify::User.new(current_user.spotify_hash)
    name = "#{params[:festival_name].capitalize} - listo"
    playlist = spotify_user.create_playlist!(name)

    songs = []
    artists_count = params[:artist_names].count
    songs_per_artists = 40 / artists_count

    params[:artist_names].each do |artist|
      artist = RSpotify::Artist.search(artist).first
      if artist
        top_songs = artist.top_tracks(:US).sample(songs_per_artists)
        songs << top_songs
      end
    end

    playlist.add_tracks!(songs.flatten.shuffle)

  end

  private

  def scrape_songkick(search)
    require 'open-uri'
    base_url = "https://www.songkick.com"
    url = "#{base_url}/search?page=1&query=#{search}&type=upcoming"
    doc = Nokogiri::HTML(open(url))
    festival = doc.search(".event.festival-instance").first
    festival_url = base_url + festival.search(".summary > a").attr("href")
    festival_doc = Nokogiri::HTML(open(festival_url))
    artists = []
    festival_doc.search("#lineup .festival li").first(5).each do |list_item|
      artists << list_item.text.strip
    end
    return artists
  end

  def load_artists(artists)
    @artists = []
    artists.each do |artist|
      begin
        s_artist = RSpotify::Artist.search(artist).first
        @artists << s_artist if s_artist
      rescue
        puts "-------- ERROR! --------"
      end
    end
  end
end

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
  end

  def successful
    @festival = Festival.find(params[:id])
  end

  def artists
    @festival = Festival.search_by_festival_name(params[:searched_event]).first
    spotify_artists(get_artists(params[:searched_event]))
  end

  def playlist_create
    @festival = Festival.search_by_festival_name(params[:searched_event]).first
    spotify_user = RSpotify::User.new(current_user.spotify_hash)
    name = "#{@festival.name} (by listo 🔈)"
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
    redirect_to successful_path(@festival)
  end

  private

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

    redirect_to root_path alert: "No festival found 😢" if festival.nil?

    festival_url = base_url + festival.search(".summary > a").attr("href")
    festival_doc = Nokogiri::HTML(open(festival_url))
    festival_name = festival_doc.search('h1').text.strip || name.capitalize
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

  def spotify_artists(artist_array)
    @artists = []
    artist_array.each do |artist|
      s_artist = RSpotify::Artist.search(artist.name).first
      @artists << s_artist if s_artist
    end
  end
end

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
  end

  def search
    if params[:searched_event]
      @found_festivals = Festival.search_by_festival_name(params[:searched_event])
    end
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js
    end
  end

  def successful
    @festival = Festival.find(params[:id])
  end

  def artists
    @festival = Festival.find(params[:festival_id])
    spotify_artists(@festival.artists)
  end

  def playlist_create
    @festival = Festival.search_by_festival_name(params[:festival_name]).first
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

  def spotify_artists(artist_array)
    @artists = []
    artist_array.each do |artist|
      begin
        s_artist = RSpotify::Artist.search(artist.name).first
      rescue RestClient::BadGateway
        s_artist = false
      end
      @artists << s_artist if s_artist
    end
  end
end

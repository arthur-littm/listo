class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home

    songkick = {
      "resultsPage": {
        "results": {
          "event": [
            {
              "type": "Festival",
              "displayName": "Lovebox 2018",
              "venue": {
                "displayName": "Gunnersbury Park, London",
                "id": 17522
              },
              "location": {
                city: "London, UK",
                lat: nil,
                lng: nil
              },
              "start": {
                "date": "2018-07-13",
                "time": "19:00:00"
              },
              "performance": [
                {
                "displayName": "Childish Gambino",
                "id": 3681591
                },
                {
                "displayName": "Skepta",
                "id": 3681591
                },
                {
                "displayName": "Wu-tang clan",
                "id": 3681591
                },
                {
                "displayName": "Bonobo",
                "id": 3681591
                },
                {
                "displayName": "Loco dice",
                "id": 3681591
                }
              ],
              "uri": "http://www.songkick.com/concerts/2342061-pixies-at-o2-academy-brixton",
              "id": 2342061
            },
          ]
        },
        "totalEntries": 2,
        "perPage": 50,
        "page": 1
      }
    }

    load_artists(songkick[:resultsPage][:results][:event][0][:performance])
    # raise
  end

  def playlist_create
    # spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
    # playlist = spotify_user.create_playlist!('my-awesome-playlist')
    raise
  end
  private

  def load_artists(songkick_results)
    @artists = []
    songkick_results.each do |artist|
      @artists << RSpotify::Artist.search(artist[:displayName]).first
    end
  end
end

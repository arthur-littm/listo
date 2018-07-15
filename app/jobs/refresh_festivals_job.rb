class RefreshFestivalsJob < ApplicationJob
  queue_as :default

  def perform()
    cities = City.all

    cities.each do |city|
      city.refresh_festivals
    end
  end


end

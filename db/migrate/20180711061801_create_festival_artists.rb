class CreateFestivalArtists < ActiveRecord::Migration[5.2]
  def change
    create_table :festival_artists do |t|
      t.references :artist, foreign_key: true
      t.references :festival, foreign_key: true

      t.timestamps
    end
  end
end

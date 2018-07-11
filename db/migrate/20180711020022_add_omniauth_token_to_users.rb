class AddOmniauthTokenToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :name, :string
    add_column :users, :spotify_photo_url, :string
  end
end

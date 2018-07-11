class CreateFestivals < ActiveRecord::Migration[5.2]
  def change
    create_table :festivals do |t|
      t.string :name
      t.integer :year

      t.timestamps
    end
  end
end

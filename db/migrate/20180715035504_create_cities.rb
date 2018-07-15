class CreateCities < ActiveRecord::Migration[5.2]
  def change
    create_table :cities do |t|
      t.string :name
      t.string :country
      t.string :lat
      t.string :lng
    end

    add_reference :festivals, :city, index: true
  end
end

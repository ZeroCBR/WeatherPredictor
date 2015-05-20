class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.text :name
      t.text :latitude
      t.text :longitude

      t.timestamps null: false
    end
  end
end

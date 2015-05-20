class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.text :name
      t.text :latitude
      t.text :longitude
      t.text :pcode

      t.timestamps null: false
    end
  end
end

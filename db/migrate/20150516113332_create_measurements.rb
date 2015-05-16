class CreateMeasurements < ActiveRecord::Migration
  def change
    create_table :measurements do |t|
      t.datetime :time
      t.text :temp
      t.text :precip
      t.text :windDir
      t.text :windSpeed
      t.text :condition

      t.timestamps null: false
    end
  end
end

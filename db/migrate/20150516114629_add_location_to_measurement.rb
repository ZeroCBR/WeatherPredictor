class AddLocationToMeasurement < ActiveRecord::Migration
  def change
    add_reference :measurements, :location, index: true
    add_foreign_key :measurements, :locations
  end
end

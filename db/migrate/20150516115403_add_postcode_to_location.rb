class AddPostcodeToLocation < ActiveRecord::Migration
  def change
    add_reference :locations, :postcode, index: true
    add_foreign_key :locations, :postcodes
  end
end

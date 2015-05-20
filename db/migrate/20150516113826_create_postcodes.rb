class CreatePostcodes < ActiveRecord::Migration
  def change
    create_table :postcodes do |t|
      t.text :postcode
      t.timestamps null: false
    end
  end
end

class RemovePcodeFromLocation < ActiveRecord::Migration
  def change
    remove_column :locations, :pcode, :text
  end
end

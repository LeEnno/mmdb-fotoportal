class AddPrimaryKeysToJoinTables < ActiveRecord::Migration
  def change
    add_column :keywords_pictures, :id, :primary_key
    add_column :appearances, :id, :primary_key
  end
end

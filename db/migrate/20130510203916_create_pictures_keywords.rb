class CreatePicturesKeywords < ActiveRecord::Migration
  def change
    create_table :pictures_keywords, :id => false do |t|
      t.integer :picture_id, :null => false
      t.integer :keyword_id, :null => false
    end

    add_index :pictures_keywords, [:picture_id, :keyword_id]
  end
end

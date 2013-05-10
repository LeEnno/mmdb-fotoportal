# n:m for pictures and persons
class CreateAppearances < ActiveRecord::Migration
  def change
    create_table :appearances, :id => false do |t|
      t.integer :picture_id, :null => false
      t.integer :person_id, :null => false
    end

    add_index :appearances, [:picture_id, :person_id]
  end
end

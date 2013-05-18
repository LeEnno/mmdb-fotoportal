class AddFilenameToPictures < ActiveRecord::Migration
  def change
    add_column :pictures, :filename, :string
  end
end

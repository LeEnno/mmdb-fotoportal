class ChangeColorSpaceToIntInPictures < ActiveRecord::Migration
  def up
    change_column :pictures, :focal_length, :integer
  end

  def down
    change_column :pictures, :focal_length, :string
  end
end

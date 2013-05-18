class ChangeFocalLengthToFloatInPictures < ActiveRecord::Migration
  def up
    change_column :pictures, :focal_length, :float
  end

  def down
    change_column :pictures, :focal_length, :integer
  end
end

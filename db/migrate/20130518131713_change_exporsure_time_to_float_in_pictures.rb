class ChangeExposureTimeToFloatInPictures < ActiveRecord::Migration
  def up
    change_column :pictures, :exposure_time, :float
  end

  def down
    change_column :pictures, :exposure_time, :integer
  end
end

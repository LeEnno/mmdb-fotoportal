class RemoveMeanBrownFromPictures < ActiveRecord::Migration
  def change
    remove_column :pictures, :mean_brown
  end
end
